import { db } from '@config/database';
import { config } from '@config/environment';
import logger from '@config/logger';
import { RateLimitError } from '@utils/errors';

/**
 * Rate Limit Service
 * Handles API rate limiting per user tier
 * Tracks AI classification calls and enforces limits
 */
export class RateLimitService {
  private readonly TIER_LIMITS = {
    free: config.rateLimit.freeTier,
    premium: config.rateLimit.premiumTier,
    pro: config.rateLimit.proTier === 'unlimited' ? Infinity : parseInt(config.rateLimit.proTier as string),
  };

  /**
   * Check if user has exceeded rate limit
   */
  async checkLimit(userId: string, tier: 'free' | 'premium' | 'pro'): Promise<boolean> {
    try {
      logger.debug('Checking rate limit', { userId, tier });

      const limit = this.TIER_LIMITS[tier];

      // Pro tier has unlimited calls
      if (limit === Infinity) {
        logger.debug('Pro tier user, no limit');
        return true;
      }

      const today = new Date().toISOString().split('T')[0];

      // Get current usage
      const [usage] = await db('rate_limit_tracking')
        .where('user_id', userId)
        .where('date', today)
        .select('ai_calls_today');

      const currentUsage = usage?.ai_calls_today || 0;

      if (currentUsage >= limit) {
        logger.warn('Rate limit exceeded', { userId, tier, currentUsage, limit });
        return false;
      }

      logger.debug('Rate limit check passed', { userId, currentUsage, limit });
      return true;
    } catch (error) {
      logger.error('Error checking rate limit:', error);
      // On error, allow the request (fail open)
      return true;
    }
  }

  /**
   * Increment usage counter
   */
  async incrementUsage(userId: string, tier: 'free' | 'premium' | 'pro'): Promise<void> {
    try {
      const today = new Date().toISOString().split('T')[0];

      logger.debug('Incrementing rate limit usage', { userId, tier });

      // Upsert usage record
      await db('rate_limit_tracking')
        .insert({
          id: this.generateId(),
          user_id: userId,
          tier,
          date: today,
          ai_calls_today: 1,
          last_reset: new Date(),
          created_at: new Date(),
        })
        .onConflict(['user_id', 'date'])
        .merge({
          ai_calls_today: db.raw('ai_calls_today + 1'),
          last_reset: new Date(),
        });

      logger.debug('Usage incremented successfully');
    } catch (error) {
      logger.error('Error incrementing usage:', error);
      // Don't fail the request if tracking fails
    }
  }

  /**
   * Get current usage for user
   */
  async getCurrentUsage(userId: string): Promise<{
    today: number;
    thisHour: number;
    limit: number;
    remaining: number;
    resetAt: Date;
  }> {
    try {
      const today = new Date().toISOString().split('T')[0];

      const [usage] = await db('rate_limit_tracking')
        .where('user_id', userId)
        .where('date', today)
        .select('ai_calls_today', 'tier', 'last_reset');

      const tier = usage?.tier || 'free';
      const limit = this.TIER_LIMITS[tier as keyof typeof this.TIER_LIMITS];
      const callsToday = usage?.ai_calls_today || 0;
      const remaining = Math.max(0, limit - callsToday);

      // Calculate reset time (next day at 00:00 UTC)
      const resetAt = new Date();
      resetAt.setDate(resetAt.getDate() + 1);
      resetAt.setHours(0, 0, 0, 0);

      return {
        today: callsToday,
        thisHour: 0, // Simplified - would need hourly tracking
        limit,
        remaining,
        resetAt,
      };
    } catch (error) {
      logger.error('Error getting current usage:', error);
      return {
        today: 0,
        thisHour: 0,
        limit: this.TIER_LIMITS.free,
        remaining: this.TIER_LIMITS.free,
        resetAt: new Date(),
      };
    }
  }

  /**
   * Reset daily limits (called by cron job)
   */
  async resetDailyLimits(): Promise<number> {
    try {
      logger.debug('Resetting daily rate limits');

      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      // Delete old records
      const deletedCount = await db('rate_limit_tracking')
        .where('date', '<', yesterdayStr)
        .delete();

      logger.debug('Daily limits reset', { deletedCount });
      return deletedCount;
    } catch (error) {
      logger.error('Error resetting daily limits:', error);
      return 0;
    }
  }

  /**
   * Get rate limit statistics
   */
  async getRateLimitStats(): Promise<{
    totalUsers: number;
    freeUsersAtLimit: number;
    premiumUsersAtLimit: number;
    averageUsagePerUser: number;
  }> {
    try {
      logger.debug('Fetching rate limit statistics');

      const today = new Date().toISOString().split('T')[0];

      const [stats] = await db('rate_limit_tracking')
        .where('date', today)
        .select(
          db.raw('COUNT(DISTINCT user_id) as total_users'),
          db.raw(`SUM(CASE WHEN tier = 'free' AND ai_calls_today >= ${this.TIER_LIMITS.free} THEN 1 ELSE 0 END) as free_at_limit`),
          db.raw(`SUM(CASE WHEN tier = 'premium' AND ai_calls_today >= ${this.TIER_LIMITS.premium} THEN 1 ELSE 0 END) as premium_at_limit`),
          db.raw('AVG(ai_calls_today) as avg_usage')
        );

      return {
        totalUsers: stats.total_users || 0,
        freeUsersAtLimit: stats.free_at_limit || 0,
        premiumUsersAtLimit: stats.premium_at_limit || 0,
        averageUsagePerUser: parseFloat(stats.avg_usage) || 0,
      };
    } catch (error) {
      logger.error('Error fetching rate limit statistics:', error);
      return {
        totalUsers: 0,
        freeUsersAtLimit: 0,
        premiumUsersAtLimit: 0,
        averageUsagePerUser: 0,
      };
    }
  }

  /**
   * Check and enforce rate limit (throws error if exceeded)
   */
  async checkAndEnforce(userId: string, tier: 'free' | 'premium' | 'pro'): Promise<void> {
    const allowed = await this.checkLimit(userId, tier);

    if (!allowed) {
      const usage = await this.getCurrentUsage(userId);
      throw new RateLimitError(Math.ceil((usage.resetAt.getTime() - Date.now()) / 1000));
    }

    await this.incrementUsage(userId, tier);
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

export default RateLimitService;
