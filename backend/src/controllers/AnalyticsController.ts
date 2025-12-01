import { Request, Response } from 'express';
import logger from '@config/logger';
import { asyncHandler } from '@middleware/errorHandler';
import { ValidationError } from '@utils/errors';
import AnalyticsService from '@services/AnalyticsService';

/**
 * Analytics Controller
 * Handles analytics queries and reporting
 */
export class AnalyticsController {
  private analyticsService = new AnalyticsService();

  /**
   * Get analytics dashboard
   * GET /api/v1/analytics/dashboard
   */
  getDashboard = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get analytics dashboard request', { userId: req.userId });

      const { dateRange = '7d' } = req.query;

      // Validate date range
      if (!['7d', '30d', '90d', 'all'].includes(dateRange as string)) {
        throw new ValidationError('Invalid date range. Must be 7d, 30d, 90d, or all');
      }

      // Get dashboard data
      const dashboard = await this.analyticsService.getAnalyticsDashboard(
        req.userId!,
        dateRange as '7d' | '30d' | '90d' | 'all'
      );

      logger.debug('Analytics dashboard retrieved', { userId: req.userId, dateRange });

      res.status(200).json({
        success: true,
        data: dashboard,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get analytics dashboard error:', error);
      throw error;
    }
  });

  /**
   * Get keyword statistics
   * GET /api/v1/analytics/keywords
   */
  getKeywordStats = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get keyword stats request', { userId: req.userId });

      const { limit = 10 } = req.query;

      // Validate limit
      const limitNum = parseInt(limit as string, 10);
      if (isNaN(limitNum) || limitNum < 1 || limitNum > 100) {
        throw new ValidationError('Limit must be between 1 and 100');
      }

      // Get keyword stats
      const keywords = await this.analyticsService.getKeywordStats(req.userId!, limitNum);

      logger.debug('Keyword stats retrieved', { userId: req.userId, count: keywords.length });

      res.status(200).json({
        success: true,
        data: {
          keywords,
          total: keywords.length,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get keyword stats error:', error);
      throw error;
    }
  });

  /**
   * Get daily statistics
   * GET /api/v1/analytics/daily
   */
  getDailyStats = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get daily stats request', { userId: req.userId });

      const { dateRange = '7d' } = req.query;

      // Validate date range
      if (!['7d', '30d', '90d', 'all'].includes(dateRange as string)) {
        throw new ValidationError('Invalid date range. Must be 7d, 30d, 90d, or all');
      }

      // Calculate start date
      const daysAgo = this.getDaysFromRange(dateRange as string);
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - daysAgo);

      // Get daily stats
      const dailyStats = await this.analyticsService.getDailyStats(req.userId!, startDate);

      logger.debug('Daily stats retrieved', { userId: req.userId, count: dailyStats.length });

      res.status(200).json({
        success: true,
        data: {
          dailyStats,
          total: dailyStats.length,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get daily stats error:', error);
      throw error;
    }
  });

  /**
   * Export analytics as CSV
   * GET /api/v1/analytics/export
   */
  exportAnalytics = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Export analytics request', { userId: req.userId });

      const { dateRange = '7d', format = 'csv' } = req.query;

      // Validate date range
      if (!['7d', '30d', '90d', 'all'].includes(dateRange as string)) {
        throw new ValidationError('Invalid date range. Must be 7d, 30d, 90d, or all');
      }

      // Validate format
      if (!['csv', 'json'].includes(format as string)) {
        throw new ValidationError('Invalid format. Must be csv or json');
      }

      // Export analytics
      const csv = await this.analyticsService.exportAnalytics(
        req.userId!,
        dateRange as '7d' | '30d' | '90d' | 'all'
      );

      logger.info('Analytics exported', { userId: req.userId, format });

      // Set response headers for file download
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="analytics-${new Date().toISOString()}.csv"`);
      res.send(csv);
    } catch (error) {
      logger.error('Export analytics error:', error);
      throw error;
    }
  });

  /**
   * Get analytics summary
   * GET /api/v1/analytics/summary
   */
  getSummary = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get analytics summary request', { userId: req.userId });

      const { dateRange = '7d' } = req.query;

      // Validate date range
      if (!['7d', '30d', '90d', 'all'].includes(dateRange as string)) {
        throw new ValidationError('Invalid date range. Must be 7d, 30d, 90d, or all');
      }

      // Get dashboard (which includes summary)
      const dashboard = await this.analyticsService.getAnalyticsDashboard(
        req.userId!,
        dateRange as '7d' | '30d' | '90d' | 'all'
      );

      const summary = {
        totalPostsViewed: dashboard.totalPostsViewed,
        totalPostsBlocked: dashboard.totalPostsBlocked,
        blockingRate: dashboard.blockingRate,
        timeSavedMinutes: dashboard.timeSavedMinutes,
        topKeywords: dashboard.topKeywords.slice(0, 5),
      };

      logger.debug('Analytics summary retrieved', { userId: req.userId });

      res.status(200).json({
        success: true,
        data: summary,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get analytics summary error:', error);
      throw error;
    }
  });

  /**
   * Get comparison stats (e.g., this week vs last week)
   * GET /api/v1/analytics/comparison
   */
  getComparison = asyncHandler(async (req: Request, res: Response) => {
    try {
      logger.debug('Get comparison stats request', { userId: req.userId });

      // Get current period stats (7d)
      const currentStats = await this.analyticsService.getAnalyticsDashboard(
        req.userId!,
        '7d'
      );

      // Get previous period stats (would need separate query)
      // For now, return current stats with placeholder for previous

      const comparison = {
        current: {
          period: 'Last 7 days',
          postsViewed: currentStats.totalPostsViewed,
          postsBlocked: currentStats.totalPostsBlocked,
          blockingRate: currentStats.blockingRate,
        },
        previous: {
          period: 'Previous 7 days',
          postsViewed: 0,
          postsBlocked: 0,
          blockingRate: 0,
        },
        change: {
          postsViewedChange: 0,
          postsBlockedChange: 0,
          blockingRateChange: 0,
        },
      };

      logger.debug('Comparison stats retrieved', { userId: req.userId });

      res.status(200).json({
        success: true,
        data: comparison,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Get comparison stats error:', error);
      throw error;
    }
  });

  /**
   * Helper: Get days from date range
   */
  private getDaysFromRange(range: string): number {
    const ranges: Record<string, number> = {
      '7d': 7,
      '30d': 30,
      '90d': 90,
      'all': 365,
    };
    return ranges[range] || 7;
  }
}

export default AnalyticsController;
