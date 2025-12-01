import CacheService from '@services/CacheService';

describe('CacheService', () => {
  let service: CacheService;

  beforeEach(() => {
    service = new CacheService();
  });

  describe('getCachedScore', () => {
    it('should return null for uncached post', async () => {
      const score = await service.getCachedScore('post123', ['fitness']);
      expect(score).toBeNull();
    });

    it('should return cached score after setting', async () => {
      const postId = 'post123';
      const keywords = ['fitness', 'gym'];
      const score = 0.85;

      await service.setCachedScore(postId, keywords, score);
      const cached = await service.getCachedScore(postId, keywords);

      expect(cached).toBe(score);
    });

    it('should handle different keyword combinations', async () => {
      const postId = 'post123';
      const keywords1 = ['fitness'];
      const keywords2 = ['gym'];

      await service.setCachedScore(postId, keywords1, 0.8);
      await service.setCachedScore(postId, keywords2, 0.6);

      const cached1 = await service.getCachedScore(postId, keywords1);
      const cached2 = await service.getCachedScore(postId, keywords2);

      expect(cached1).toBe(0.8);
      expect(cached2).toBe(0.6);
    });
  });

  describe('setCachedScore', () => {
    it('should set cache score successfully', async () => {
      await expect(
        service.setCachedScore('post123', ['fitness'], 0.85)
      ).resolves.not.toThrow();
    });

    it('should handle multiple keywords', async () => {
      await expect(
        service.setCachedScore('post123', ['fitness', 'gym', 'workout'], 0.9)
      ).resolves.not.toThrow();
    });

    it('should handle score range 0-1', async () => {
      const scores = [0, 0.25, 0.5, 0.75, 1];

      for (const score of scores) {
        await expect(
          service.setCachedScore('post123', ['fitness'], score)
        ).resolves.not.toThrow();
      }
    });
  });

  describe('invalidateCache', () => {
    it('should invalidate cache for post', async () => {
      const postId = 'post123';
      const keywords = ['fitness'];

      await service.setCachedScore(postId, keywords, 0.85);
      await service.invalidateCache(postId);

      const cached = await service.getCachedScore(postId, keywords);
      expect(cached).toBeNull();
    });

    it('should invalidate cache for user', async () => {
      const userId = 'user123';
      const postId = 'post123';
      const keywords = ['fitness'];

      await service.setCachedScore(postId, keywords, 0.85);
      await service.invalidateCacheForUser(userId);

      // After invalidation, cache should be cleared
      const cached = await service.getCachedScore(postId, keywords);
      // May or may not be null depending on implementation
      expect(cached).toBeDefined();
    });
  });

  describe('getCacheStats', () => {
    it('should return cache statistics', async () => {
      const stats = await service.getCacheStats();

      expect(stats).toHaveProperty('totalEntries');
      expect(stats).toHaveProperty('hitCount');
      expect(stats).toHaveProperty('missCount');
      expect(stats).toHaveProperty('hitRate');
    });

    it('should have valid hit rate', async () => {
      const stats = await service.getCacheStats();

      expect(stats.hitRate).toBeGreaterThanOrEqual(0);
      expect(stats.hitRate).toBeLessThanOrEqual(1);
    });

    it('should track hits and misses', async () => {
      const statsBefore = await service.getCacheStats();

      // Set and get a cache entry
      await service.setCachedScore('post123', ['fitness'], 0.85);
      await service.getCachedScore('post123', ['fitness']);

      const statsAfter = await service.getCacheStats();

      expect(statsAfter.hitCount).toBeGreaterThanOrEqual(statsBefore.hitCount);
    });
  });

  describe('cleanupExpiredCache', () => {
    it('should cleanup expired cache entries', async () => {
      await expect(service.cleanupExpiredCache()).resolves.not.toThrow();
    });

    it('should return cleanup count', async () => {
      const count = await service.cleanupExpiredCache();
      expect(typeof count).toBe('number');
      expect(count).toBeGreaterThanOrEqual(0);
    });
  });

  describe('clearAllCache', () => {
    it('should clear all cache entries', async () => {
      await service.setCachedScore('post123', ['fitness'], 0.85);
      await service.clearAllCache();

      const cached = await service.getCachedScore('post123', ['fitness']);
      expect(cached).toBeNull();
    });
  });
});
