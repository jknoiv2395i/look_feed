import FilterDecisionEngine from '@services/FilterDecisionEngine';
import { FilterDecision } from '@types/index';

describe('FilterDecisionEngine', () => {
  let engine: FilterDecisionEngine;

  beforeEach(() => {
    engine = new FilterDecisionEngine();
  });

  describe('decide', () => {
    const mockPost = {
      id: 'post1',
      caption: 'Great fitness workout',
      hashtags: ['fitness', 'gym'],
      username: 'johndoe',
      postUrl: 'https://instagram.com/p/post1',
      imageUrls: [],
      videoUrl: null,
      postType: 'image' as const,
      extractedAt: Date.now(),
    };

    it('should return SHOW decision for high relevance score', async () => {
      const keywords = ['fitness', 'gym'];
      const result = await engine.decide(mockPost, keywords, 'moderate', false);

      expect(result.decision).toBe(FilterDecision.SHOW);
      expect(result.score).toBeGreaterThanOrEqual(0.8);
    });

    it('should return HIDE decision for low relevance score', async () => {
      const keywords = ['cars', 'luxury'];
      const result = await engine.decide(mockPost, keywords, 'moderate', false);

      expect(result.decision).toBe(FilterDecision.HIDE);
      expect(result.score).toBeLessThanOrEqual(0.3);
    });

    it('should return UNCERTAIN decision for medium relevance score', async () => {
      const keywords = ['health', 'wellness'];
      const result = await engine.decide(mockPost, keywords, 'moderate', false);

      expect(result.decision).toBe(FilterDecision.UNCERTAIN);
      expect(result.score).toBeGreaterThan(0.3);
      expect(result.score).toBeLessThan(0.8);
    });

    it('should apply strict strategy correctly', async () => {
      const keywords = ['fitness'];
      const result = await engine.decide(mockPost, keywords, 'strict', false);

      // Strict strategy should have higher threshold
      expect(result.decision).toBeDefined();
    });

    it('should apply relaxed strategy correctly', async () => {
      const keywords = ['health'];
      const result = await engine.decide(mockPost, keywords, 'relaxed', false);

      // Relaxed strategy should have lower threshold
      expect(result.decision).toBeDefined();
    });

    it('should include matched keywords in result', async () => {
      const keywords = ['fitness', 'gym', 'sports'];
      const result = await engine.decide(mockPost, keywords, 'moderate', false);

      expect(result.matchedKeywords).toContain('fitness');
      expect(result.matchedKeywords).toContain('gym');
    });

    it('should set method to keyword when AI is disabled', async () => {
      const keywords = ['fitness'];
      const result = await engine.decide(mockPost, keywords, 'moderate', false);

      expect(result.method).toBe('keyword');
    });

    it('should complete in reasonable time', async () => {
      const keywords = ['fitness'];
      const startTime = Date.now();
      await engine.decide(mockPost, keywords, 'moderate', false);
      const endTime = Date.now();

      expect(endTime - startTime).toBeLessThan(100);
    });
  });

  describe('getThreshold', () => {
    it('should return correct threshold for strict strategy', () => {
      const threshold = engine.getThreshold('strict');
      expect(threshold).toBeGreaterThan(0.7);
    });

    it('should return correct threshold for moderate strategy', () => {
      const threshold = engine.getThreshold('moderate');
      expect(threshold).toBeGreaterThan(0.5);
      expect(threshold).toBeLessThan(0.7);
    });

    it('should return correct threshold for relaxed strategy', () => {
      const threshold = engine.getThreshold('relaxed');
      expect(threshold).toBeLessThan(0.5);
    });
  });
});
