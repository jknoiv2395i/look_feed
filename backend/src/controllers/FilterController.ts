import { Request, Response } from 'express';
import logger from '@config/logger';
import { asyncHandler } from '@middleware/errorHandler';
import { validate, classificationRequestSchema, filterConfigSchema } from '@utils/validators';
import { ValidationError } from '@utils/errors';
import { ClassificationRequest, ClassificationResponse, CreateFilterLogDTO, UpdateFilterConfigDTO } from '@types/index';
import FilterDecisionEngine from '@services/FilterDecisionEngine';
import CacheService from '@services/CacheService';
import AnalyticsService from '@services/AnalyticsService';
import RateLimitService from '@services/RateLimitService';

/**
 * Filter Controller
 * Handles post classification and filtering
 */
export class FilterController {
  private filterEngine = new FilterDecisionEngine();
  private cacheService = new CacheService();
  private analyticsService = new AnalyticsService();
  private rateLimitService = new RateLimitService();

  /**
   * Classify post content
   * POST /api/v1/filter/classify
   */
  classify = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Classification request received', { userId: req.userId });

      // Validate input
      const request = validate<ClassificationRequest>(req.body, classificationRequestSchema);

      // Check rate limit
      // TODO: Get user tier from Firebase
      const userTier = 'free';
      await this.rateLimitService.checkAndEnforce(req.userId!, userTier as any);

      // Check cache
      const cachedScore = await this.cacheService.getCachedScore(
        request.postData.id,
        request.keywords
      );

      if (cachedScore !== null) {
        logger.debug('Cache hit for classification', {
          userId: req.userId,
          postId: request.postData.id,
        });

        const response: ClassificationResponse = {
          relevanceScore: cachedScore,
          method: 'cached',
          processingTimeMs: 10,
        };

        res.status(200).json({
          success: true,
          data: response,
          timestamp: new Date().toISOString(),
        });
        return;
      }

      // Get filter config
      // TODO: Get from Firebase
      const strategy = 'moderate';
      const enableAI = true;

      // Make filtering decision
      const startTime = Date.now();
      const decision = await this.filterEngine.decide(
        request.postData,
        request.keywords,
        strategy as any,
        enableAI
      );
      const processingTime = Date.now() - startTime;

      // Cache result
      await this.cacheService.setCachedScore(
        request.postData.id,
        request.keywords,
        decision.score
      );

      // Log event (async)
      this.analyticsService.logFilterEvent({
        userId: req.userId!,
        postId: request.postData.id,
        eventType: decision.decision === 'SHOW' ? 'POST_SHOWN' : 'POST_FILTERED',
        relevanceScore: decision.score,
        matchedKeywords: decision.matchedKeywords,
        filterMethod: decision.method,
        processingTimeMs: processingTime,
      }).catch(err => logger.error('Error logging filter event:', err));

      logger.info('Classification completed', {
        userId: req.userId,
        postId: request.postData.id,
        decision: decision.decision,
        score: decision.score,
        processingTime,
      });

      const response: ClassificationResponse = {
        relevanceScore: decision.score,
        method: decision.method === 'hybrid' ? 'ai' : 'cached',
        processingTimeMs: processingTime,
      };

      res.status(200).json({
        success: true,
        data: response,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Classification error:', error);
      throw error;
    }
  });

  /**
   * Log filter decision
   * POST /api/v1/filter/log
   */
  logFilterDecision = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Log filter decision request', { userId: req.userId });

      // Validate input
      const logData = validate<CreateFilterLogDTO>(req.body, {
        postId: { type: 'string', required: true },
        action: { type: 'string', enum: ['shown', 'hidden'], required: true },
        relevanceScore: { type: 'number', min: 0, max: 1, required: true },
        matchedKeywords: { type: 'array', required: false },
        method: { type: 'string', enum: ['keyword', 'ai', 'hybrid'], required: false },
      } as any);

      // Log to PostgreSQL
      await this.analyticsService.logFilterEvent({
        userId: req.userId!,
        postId: logData.postId,
        eventType: logData.action === 'shown' ? 'POST_SHOWN' : 'POST_FILTERED',
        relevanceScore: logData.relevanceScore,
        matchedKeywords: logData.matchedKeywords || [],
        filterMethod: logData.method || 'keyword',
        processingTimeMs: 0,
      });

      logger.debug('Filter decision logged', {
        userId: req.userId,
        postId: logData.postId,
        action: logData.action,
      });

      res.status(202).json({
        success: true,
        data: {
          message: 'Log received',
          queued: true,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Log filter decision error:', error);
      throw error;
    }
  });

  /**
   * Batch log filter decisions
   * POST /api/v1/filter/log/batch
   */
  batchLogFilterDecisions = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Batch log filter decisions request', { userId: req.userId });

      const { logs } = req.body;

      if (!Array.isArray(logs) || logs.length === 0) {
        throw new ValidationError('Logs array is required and must not be empty');
      }

      if (logs.length > 1000) {
        throw new ValidationError('Maximum 1000 logs can be submitted at once');
      }

      // Log all events
      const events = logs.map((log: any) => ({
        userId: req.userId!,
        postId: log.postId,
        eventType: log.action === 'shown' ? 'POST_SHOWN' : 'POST_FILTERED',
        relevanceScore: log.relevanceScore,
        matchedKeywords: log.matchedKeywords || [],
        filterMethod: log.method || 'keyword',
        processingTimeMs: log.processingTimeMs || 0,
      }));

      await this.analyticsService.batchLogFilterEvents(events);

      logger.debug('Batch logs submitted', {
        userId: req.userId,
        count: logs.length,
      });

      res.status(202).json({
        success: true,
        data: {
          message: `${logs.length} logs received`,
          queued: true,
          count: logs.length,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Batch log filter decisions error:', error);
      throw error;
    }
  });

  /**
   * Get filter configuration
   * GET /api/v1/filter/config
   */
  getFilterConfig = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get filter config request', { userId: req.userId });

      // TODO: Get config from Firebase
      const config = {
        strategy: 'moderate',
        enableAiClassification: true,
      };

      res.status(200).json({
        success: true,
        data: config,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get filter config error:', error);
      throw error;
    }
  });

  /**
   * Update filter configuration
   * PUT /api/v1/filter/config
   */
  updateFilterConfig = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Update filter config request', { userId: req.userId });

      // Validate input
      const updates = validate<UpdateFilterConfigDTO>(req.body, filterConfigSchema);

      // TODO: Update config in Firebase
      // TODO: Invalidate cache

      logger.info('Filter config updated', { userId: req.userId, updates });

      res.status(200).json({
        success: true,
        data: {
          message: 'Filter configuration updated successfully',
          ...updates,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Update filter config error:', error);
      throw error;
    }
  });

  /**
   * Get cache statistics
   * GET /api/v1/filter/cache/stats
   */
  getCacheStats = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get cache stats request');

      const stats = await this.cacheService.getCacheStats();

      res.status(200).json({
        success: true,
        data: stats,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get cache stats error:', error);
      throw error;
    }
  });

  /**
   * Clear cache
   * DELETE /api/v1/filter/cache
   */
  clearCache = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Clear cache request');

      // TODO: Clear all cache entries
      // This is an admin endpoint

      logger.info('Cache cleared');

      res.status(200).json({
        success: true,
        data: {
          message: 'Cache cleared successfully',
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Clear cache error:', error);
      throw error;
    }
  });
}

export default FilterController;
