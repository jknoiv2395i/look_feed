import { db } from '@config/database';
import logger from '@config/logger';
import { AppError } from '@utils/errors';
import crypto from 'crypto';

/**
 * Cache Service
 * Handles AI classification result caching in PostgreSQL
 * Prevents redundant API calls for same content
 */
export class CacheService {
  private readonly CACHE_TTL_HOURS = 24;

  /**
   * Generate cache key from post ID and keywords
   */
  private generateCacheKey(postId: string, keywords: string[]): string {
    const combined = `${postId}:${keywords.sort().join(',')}`;
    return crypto.createHash('md5').update(combined).digest('hex');
  }

  /**
   * Get cached classification score
   */
  async getCachedScore(postId: string, keywords: string[]): Promise<number | null> {
    try {
      const cacheKey = this.generateCacheKey(postId, keywords);

      logger.debug('Checking cache for score', { cacheKey });

      const cached = await db('ai_classification_cache')
        .where('cache_key', cacheKey)
        .where('expires_at', '>', new Date())
        .first();

      if (cached) {
        logger.debug('Cache hit', { cacheKey });
        return cached.relevance_score;
      }

      logger.debug('Cache miss', { cacheKey });
      return null;
    } catch (error) {
      logger.error('Error getting cached score:', error);
      // Return null on error (don't fail the request)
      return null;
    }
  }

  /**
   * Set cached classification score
   */
  async setCachedScore(
    postId: string,
    keywords: string[],
    score: number,
    ttlHours: number = this.CACHE_TTL_HOURS
  ): Promise<void> {
    try {
      const cacheKey = this.generateCacheKey(postId, keywords);
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + ttlHours);

      logger.debug('Caching score', { cacheKey, score, ttlHours });

      await db('ai_classification_cache').insert({
        id: this.generateId(),
        cache_key: cacheKey,
        post_id: postId,
        keywords: JSON.stringify(keywords),
        relevance_score: score,
        created_at: new Date(),
        expires_at: expiresAt,
      });

      logger.debug('Score cached successfully');
    } catch (error) {
      logger.error('Error setting cached score:', error);
      // Don't fail the request if caching fails
    }
  }

  /**
   * Invalidate cache for specific post
   */
  async invalidateCache(postId: string): Promise<void> {
    try {
      logger.debug('Invalidating cache for post', { postId });

      await db('ai_classification_cache').where('post_id', postId).delete();

      logger.debug('Cache invalidated successfully');
    } catch (error) {
      logger.error('Error invalidating cache:', error);
      // Don't fail the request if cache invalidation fails
    }
  }

  /**
   * Invalidate cache by key
   */
  async invalidateCacheByKey(cacheKey: string): Promise<void> {
    try {
      logger.debug('Invalidating cache by key', { cacheKey });

      await db('ai_classification_cache').where('cache_key', cacheKey).delete();

      logger.debug('Cache invalidated by key successfully');
    } catch (error) {
      logger.error('Error invalidating cache by key:', error);
    }
  }

  /**
   * Clean up expired cache entries
   * Should be called periodically (e.g., daily via cron job)
   */
  async cleanupExpiredCache(): Promise<number> {
    try {
      logger.debug('Cleaning up expired cache entries');

      const deletedCount = await db('ai_classification_cache')
        .where('expires_at', '<', new Date())
        .delete();

      logger.debug('Expired cache cleaned up', { deletedCount });
      return deletedCount;
    } catch (error) {
      logger.error('Error cleaning up expired cache:', error);
      throw new AppError('Failed to cleanup expired cache', 500);
    }
  }

  /**
   * Get cache statistics
   */
  async getCacheStats(): Promise<{
    totalEntries: number;
    expiredEntries: number;
    activeEntries: number;
    cacheSize: string;
  }> {
    try {
      logger.debug('Fetching cache statistics');

      const [stats] = await db('ai_classification_cache')
        .select(
          db.raw('COUNT(*) as total_entries'),
          db.raw("SUM(CASE WHEN expires_at < NOW() THEN 1 ELSE 0 END) as expired_entries"),
          db.raw("SUM(CASE WHEN expires_at >= NOW() THEN 1 ELSE 0 END) as active_entries"),
          db.raw("pg_size_pretty(pg_total_relation_size('ai_classification_cache')) as cache_size")
        );

      return {
        totalEntries: stats.total_entries || 0,
        expiredEntries: stats.expired_entries || 0,
        activeEntries: stats.active_entries || 0,
        cacheSize: stats.cache_size || '0 bytes',
      };
    } catch (error) {
      logger.error('Error fetching cache statistics:', error);
      throw new AppError('Failed to fetch cache statistics', 500);
    }
  }

  /**
   * Warm cache with frequently accessed posts
   * Called during off-peak hours
   */
  async warmCache(postIds: string[], keywords: string[]): Promise<void> {
    try {
      logger.debug('Warming cache', { postIdCount: postIds.length, keywordCount: keywords.length });

      // This would typically be called with pre-computed scores
      // For now, just log the operation
      logger.info('Cache warming initiated', { postIdCount: postIds.length });
    } catch (error) {
      logger.error('Error warming cache:', error);
      // Don't fail the request if cache warming fails
    }
  }

  /**
   * Get cache hit rate
   */
  async getCacheHitRate(timeWindowHours: number = 24): Promise<number> {
    try {
      logger.debug('Calculating cache hit rate', { timeWindowHours });

      const startTime = new Date();
      startTime.setHours(startTime.getHours() - timeWindowHours);

      const [stats] = await db('ai_classification_cache')
        .where('created_at', '>=', startTime)
        .select(
          db.raw('COUNT(*) as total_hits')
        );

      // This is a simplified calculation
      // In production, you'd track actual hits vs misses
      const hitRate = stats.total_hits || 0;
      return hitRate;
    } catch (error) {
      logger.error('Error calculating cache hit rate:', error);
      return 0;
    }
  }

  /**
   * Helper: Generate UUID
   */
  private generateId(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }
}

export default CacheService;
