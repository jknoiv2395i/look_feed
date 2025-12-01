import AnalyticsService from '@services/AnalyticsService';

describe('AnalyticsService', () => {
  let service: AnalyticsService;

  beforeEach(() => {
    service = new AnalyticsService();
  });

  describe('logFilterEvent', () => {
    it('should log filter event successfully', async () => {
      const event = {
        userId: 'user123',
        postId: 'post123',
        eventType: 'POST_SHOWN' as const,
        relevanceScore: 0.85,
        matchedKeywords: ['fitness'],
        filterMethod: 'keyword' as const,
        processingTimeMs: 10,
      };

      await expect(service.logFilterEvent(event)).resolves.not.toThrow();
    });

    it('should handle POST_FILTERED event', async () => {
      const event = {
        userId: 'user123',
        postId: 'post123',
        eventType: 'POST_FILTERED' as const,
        relevanceScore: 0.2,
        matchedKeywords: [],
        filterMethod: 'keyword' as const,
        processingTimeMs: 5,
      };

      await expect(service.logFilterEvent(event)).resolves.not.toThrow();
    });

    it('should handle multiple keywords', async () => {
      const event = {
        userId: 'user123',
        postId: 'post123',
        eventType: 'POST_SHOWN' as const,
        relevanceScore: 0.9,
        matchedKeywords: ['fitness', 'gym', 'workout'],
        filterMethod: 'hybrid' as const,
        processingTimeMs: 50,
      };

      await expect(service.logFilterEvent(event)).resolves.not.toThrow();
    });
  });

  describe('batchLogFilterEvents', () => {
    it('should batch log multiple events', async () => {
      const events = [
        {
          userId: 'user123',
          postId: 'post1',
          eventType: 'POST_SHOWN' as const,
          relevanceScore: 0.85,
          matchedKeywords: ['fitness'],
          filterMethod: 'keyword' as const,
          processingTimeMs: 10,
        },
        {
          userId: 'user123',
          postId: 'post2',
          eventType: 'POST_FILTERED' as const,
          relevanceScore: 0.2,
          matchedKeywords: [],
          filterMethod: 'keyword' as const,
          processingTimeMs: 5,
        },
      ];

      await expect(service.batchLogFilterEvents(events)).resolves.not.toThrow();
    });

    it('should handle large batch of events', async () => {
      const events = Array.from({ length: 100 }, (_, i) => ({
        userId: 'user123',
        postId: `post${i}`,
        eventType: i % 2 === 0 ? ('POST_SHOWN' as const) : ('POST_FILTERED' as const),
        relevanceScore: Math.random(),
        matchedKeywords: i % 2 === 0 ? ['fitness'] : [],
        filterMethod: 'keyword' as const,
        processingTimeMs: Math.random() * 100,
      }));

      await expect(service.batchLogFilterEvents(events)).resolves.not.toThrow();
    });
  });

  describe('getAnalyticsDashboard', () => {
    it('should return dashboard data', async () => {
      const dashboard = await service.getAnalyticsDashboard('user123', '7d');

      expect(dashboard).toHaveProperty('totalPostsViewed');
      expect(dashboard).toHaveProperty('totalPostsBlocked');
      expect(dashboard).toHaveProperty('blockingRate');
      expect(dashboard).toHaveProperty('timeSavedMinutes');
      expect(dashboard).toHaveProperty('topKeywords');
    });

    it('should support different date ranges', async () => {
      const ranges = ['7d', '30d', '90d', 'all'] as const;

      for (const range of ranges) {
        const dashboard = await service.getAnalyticsDashboard('user123', range);
        expect(dashboard).toBeDefined();
      }
    });

    it('should return valid metrics', async () => {
      const dashboard = await service.getAnalyticsDashboard('user123', '7d');

      expect(dashboard.totalPostsViewed).toBeGreaterThanOrEqual(0);
      expect(dashboard.totalPostsBlocked).toBeGreaterThanOrEqual(0);
      expect(dashboard.blockingRate).toBeGreaterThanOrEqual(0);
      expect(dashboard.blockingRate).toBeLessThanOrEqual(1);
      expect(dashboard.timeSavedMinutes).toBeGreaterThanOrEqual(0);
    });
  });

  describe('getKeywordStats', () => {
    it('should return keyword statistics', async () => {
      const stats = await service.getKeywordStats('user123', 10);

      expect(Array.isArray(stats)).toBe(true);
      expect(stats.length).toBeLessThanOrEqual(10);
    });

    it('should return keywords with match counts', async () => {
      const stats = await service.getKeywordStats('user123', 5);

      stats.forEach((stat) => {
        expect(stat).toHaveProperty('keyword');
        expect(stat).toHaveProperty('matchCount');
        expect(stat.matchCount).toBeGreaterThanOrEqual(0);
      });
    });
  });

  describe('getDailyStats', () => {
    it('should return daily statistics', async () => {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);

      const stats = await service.getDailyStats('user123', startDate);

      expect(Array.isArray(stats)).toBe(true);
    });

    it('should return stats with date and counts', async () => {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);

      const stats = await service.getDailyStats('user123', startDate);

      stats.forEach((stat) => {
        expect(stat).toHaveProperty('date');
        expect(stat).toHaveProperty('postsShown');
        expect(stat).toHaveProperty('postsFiltered');
      });
    });
  });

  describe('exportAnalytics', () => {
    it('should export analytics as CSV', async () => {
      const csv = await service.exportAnalytics('user123', '7d');

      expect(typeof csv).toBe('string');
      expect(csv.length).toBeGreaterThan(0);
    });

    it('should include CSV headers', async () => {
      const csv = await service.exportAnalytics('user123', '7d');

      expect(csv).toContain('date');
      expect(csv).toContain('posts_shown');
      expect(csv).toContain('posts_filtered');
    });

    it('should support different date ranges', async () => {
      const ranges = ['7d', '30d', '90d', 'all'] as const;

      for (const range of ranges) {
        const csv = await service.exportAnalytics('user123', range);
        expect(csv.length).toBeGreaterThan(0);
      }
    });
  });

  describe('cleanupOldAnalytics', () => {
    it('should cleanup old analytics', async () => {
      await expect(service.cleanupOldAnalytics(30)).resolves.not.toThrow();
    });

    it('should accept different retention days', async () => {
      const days = [7, 30, 90, 365];

      for (const day of days) {
        await expect(service.cleanupOldAnalytics(day)).resolves.not.toThrow();
      }
    });
  });
});
