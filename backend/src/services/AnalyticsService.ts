import { db } from '@config/database';
import logger from '@config/logger';
import { AnalyticsDashboard, AnalyticsEvent, DailyAnalytics } from '@types/index';
import { AppError } from '@utils/errors';

/**
 * Analytics Service
 * Handles all analytics operations in PostgreSQL
 * Manages complex queries, aggregations, and reporting
 */
export class AnalyticsService {
  /**
   * Log filter event to PostgreSQL
   * Called every time a post is filtered
   */
  async logFilterEvent(event: Omit<AnalyticsEvent, 'id' | 'createdAt'>): Promise<void> {
    try {
      logger.debug('Logging filter event', { userId: event.userId, postId: event.postId });

      await db('analytics_events').insert({
        id: this.generateId(),
        user_id: event.userId,
        post_id: event.postId,
        event_type: event.eventType,
        relevance_score: event.relevanceScore,
        matched_keywords: JSON.stringify(event.matchedKeywords),
        filter_method: event.filterMethod,
        processing_time_ms: event.processingTimeMs,
        created_at: new Date(),
      });

      logger.debug('Filter event logged successfully');
    } catch (error) {
      logger.error('Error logging filter event:', error);
      throw new AppError('Failed to log filter event', 500);
    }
  }

  /**
   * Batch log multiple filter events
   * More efficient for high-volume logging
   */
  async batchLogFilterEvents(events: Omit<AnalyticsEvent, 'id' | 'createdAt'>[]): Promise<void> {
    try {
      logger.debug('Batch logging filter events', { count: events.length });

      const rows = events.map(event => ({
        id: this.generateId(),
        user_id: event.userId,
        post_id: event.postId,
        event_type: event.eventType,
        relevance_score: event.relevanceScore,
        matched_keywords: JSON.stringify(event.matchedKeywords),
        filter_method: event.filterMethod,
        processing_time_ms: event.processingTimeMs,
        created_at: new Date(),
      }));

      // Insert in batches of 500 (Firestore batch limit)
      const batchSize = 500;
      for (let i = 0; i < rows.length; i += batchSize) {
        const batch = rows.slice(i, i + batchSize);
        await db('analytics_events').insert(batch);
      }

      logger.debug('Batch logging completed', { count: events.length });
    } catch (error) {
      logger.error('Error batch logging filter events:', error);
      throw new AppError('Failed to batch log filter events', 500);
    }
  }

  /**
   * Get analytics dashboard for a user
   */
  async getAnalyticsDashboard(
    userId: string,
    dateRange: '7d' | '30d' | '90d' | 'all' = '7d'
  ): Promise<AnalyticsDashboard> {
    try {
      logger.debug('Fetching analytics dashboard', { userId, dateRange });

      const daysAgo = this.getDaysFromRange(dateRange);
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - daysAgo);

      // Get total posts viewed and blocked
      const [stats] = await db('analytics_events')
        .where('user_id', userId)
        .where('created_at', '>=', startDate)
        .select(
          db.raw('COUNT(*) as total_events'),
          db.raw("SUM(CASE WHEN event_type = 'POST_SHOWN' THEN 1 ELSE 0 END) as posts_shown"),
          db.raw("SUM(CASE WHEN event_type = 'POST_FILTERED' THEN 1 ELSE 0 END) as posts_blocked"),
          db.raw('AVG(relevance_score) as avg_relevance_score'),
          db.raw('AVG(processing_time_ms) as avg_processing_time')
        );

      const totalPostsViewed = stats.total_events || 0;
      const totalPostsBlocked = stats.posts_blocked || 0;
      const totalPostsShown = stats.posts_shown || 0;
      const blockingRate = totalPostsViewed > 0 ? totalPostsBlocked / totalPostsViewed : 0;
      const timeSavedMinutes = Math.round(totalPostsBlocked * 0.5); // Assume 30 sec per post

      // Get top keywords
      const topKeywords = await this.getTopKeywords(userId, startDate);

      // Get daily stats
      const dailyStats = await this.getDailyStats(userId, startDate);

      return {
        totalPostsViewed,
        totalPostsBlocked,
        blockingRate,
        timeSavedMinutes,
        topKeywords,
        dailyStats,
      };
    } catch (error) {
      logger.error('Error fetching analytics dashboard:', error);
      throw new AppError('Failed to fetch analytics dashboard', 500);
    }
  }

  /**
   * Get keyword effectiveness statistics
   */
  async getKeywordStats(userId: string, limit: number = 10): Promise<any[]> {
    try {
      logger.debug('Fetching keyword stats', { userId, limit });

      const keywords = await db('analytics_keyword_stats')
        .where('user_id', userId)
        .orderBy('match_count', 'desc')
        .limit(limit);

      return keywords;
    } catch (error) {
      logger.error('Error fetching keyword stats:', error);
      throw new AppError('Failed to fetch keyword stats', 500);
    }
  }

  /**
   * Get daily statistics
   */
  async getDailyStats(userId: string, startDate: Date): Promise<any[]> {
    try {
      logger.debug('Fetching daily stats', { userId });

      const dailyStats = await db('analytics_daily_summary')
        .where('user_id', userId)
        .where('date', '>=', startDate.toISOString().split('T')[0])
        .orderBy('date', 'asc');

      return dailyStats.map(stat => ({
        date: stat.date,
        postsViewed: stat.total_posts_viewed,
        postsBlocked: stat.total_posts_blocked,
      }));
    } catch (error) {
      logger.error('Error fetching daily stats:', error);
      throw new AppError('Failed to fetch daily stats', 500);
    }
  }

  /**
   * Aggregate daily statistics (called by cron job)
   */
  async aggregateDailyStats(userId: string, date: string): Promise<void> {
    try {
      logger.debug('Aggregating daily stats', { userId, date });

      const startOfDay = new Date(`${date}T00:00:00Z`);
      const endOfDay = new Date(`${date}T23:59:59Z`);

      // Get events for the day
      const [stats] = await db('analytics_events')
        .where('user_id', userId)
        .where('created_at', '>=', startOfDay)
        .where('created_at', '<=', endOfDay)
        .select(
          db.raw("SUM(CASE WHEN event_type = 'POST_SHOWN' THEN 1 ELSE 0 END) as posts_shown"),
          db.raw("SUM(CASE WHEN event_type = 'POST_FILTERED' THEN 1 ELSE 0 END) as posts_blocked")
        );

      const postsShown = stats.posts_shown || 0;
      const postsBlocked = stats.posts_blocked || 0;
      const totalPosts = postsShown + postsBlocked;
      const blockingRate = totalPosts > 0 ? postsBlocked / totalPosts : 0;
      const timeSavedMinutes = Math.round(postsBlocked * 0.5);

      // Upsert daily summary
      await db('analytics_daily_summary')
        .insert({
          id: this.generateId(),
          user_id: userId,
          date,
          total_posts_viewed: totalPosts,
          total_posts_blocked: postsBlocked,
          blocking_rate: blockingRate,
          time_saved_minutes: timeSavedMinutes,
          created_at: new Date(),
        })
        .onConflict(['user_id', 'date'])
        .merge();

      logger.debug('Daily stats aggregated successfully');
    } catch (error) {
      logger.error('Error aggregating daily stats:', error);
      throw new AppError('Failed to aggregate daily stats', 500);
    }
  }

  /**
   * Export analytics as CSV
   */
  async exportAnalytics(userId: string, dateRange: '7d' | '30d' | '90d' | 'all' = '7d'): Promise<string> {
    try {
      logger.debug('Exporting analytics', { userId, dateRange });

      const daysAgo = this.getDaysFromRange(dateRange);
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - daysAgo);

      const events = await db('analytics_events')
        .where('user_id', userId)
        .where('created_at', '>=', startDate)
        .orderBy('created_at', 'desc');

      // Convert to CSV
      const csv = this.convertToCSV(events);
      return csv;
    } catch (error) {
      logger.error('Error exporting analytics:', error);
      throw new AppError('Failed to export analytics', 500);
    }
  }

  /**
   * Clean up old analytics data (retention policy)
   */
  async cleanupOldAnalytics(retentionDays: number = 30): Promise<void> {
    try {
      logger.debug('Cleaning up old analytics', { retentionDays });

      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

      await db('analytics_events').where('created_at', '<', cutoffDate).delete();

      logger.debug('Old analytics cleaned up successfully');
    } catch (error) {
      logger.error('Error cleaning up old analytics:', error);
      throw new AppError('Failed to cleanup old analytics', 500);
    }
  }

  /**
   * Helper: Get top keywords for a user
   */
  private async getTopKeywords(userId: string, startDate: Date): Promise<any[]> {
    const keywords = await db('analytics_events')
      .where('user_id', userId)
      .where('created_at', '>=', startDate)
      .select(
        db.raw('jsonb_array_elements(matched_keywords) as keyword'),
        db.raw('COUNT(*) as match_count'),
        db.raw('AVG(relevance_score) as effectiveness')
      )
      .groupBy('keyword')
      .orderBy('match_count', 'desc')
      .limit(10);

    return keywords.map(k => ({
      keyword: k.keyword,
      matchCount: k.match_count,
      effectiveness: parseFloat(k.effectiveness),
    }));
  }

  /**
   * Helper: Get days from date range
   */
  private getDaysFromRange(range: '7d' | '30d' | '90d' | 'all'): number {
    const ranges: Record<string, number> = {
      '7d': 7,
      '30d': 30,
      '90d': 90,
      'all': 365,
    };
    return ranges[range] || 7;
  }

  /**
   * Helper: Convert events to CSV
   */
  private convertToCSV(events: any[]): string {
    const headers = ['Date', 'Post ID', 'Action', 'Relevance Score', 'Method', 'Keywords'];
    const rows = events.map(e => [
      new Date(e.created_at).toISOString(),
      e.post_id,
      e.event_type,
      e.relevance_score,
      e.filter_method,
      JSON.parse(e.matched_keywords).join(';'),
    ]);

    const csv = [
      headers.join(','),
      ...rows.map(row => row.map(cell => `"${cell}"`).join(',')),
    ].join('\n');

    return csv;
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

export default AnalyticsService;
