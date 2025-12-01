import KeywordMatcher from '@services/KeywordMatcher';
import { FilterDecision } from '@types/index';

describe('KeywordMatcher', () => {
  let matcher: KeywordMatcher;

  beforeEach(() => {
    matcher = new KeywordMatcher();
  });

  describe('match', () => {
    it('should return SHOW decision for exact hashtag match', () => {
      const postData = {
        id: 'post1',
        caption: 'Great workout today',
        hashtags: ['fitness', 'gym', 'workout'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post1',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'sports'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeGreaterThanOrEqual(0.8);
      expect(result.decision).toBe(FilterDecision.SHOW);
      expect(result.matchedKeywords).toContain('fitness');
    });

    it('should return HIDE decision for no matches', () => {
      const postData = {
        id: 'post2',
        caption: 'Check out my new car',
        hashtags: ['cars', 'luxury'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post2',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'gym'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeLessThanOrEqual(0.3);
      expect(result.decision).toBe(FilterDecision.HIDE);
      expect(result.matchedKeywords.length).toBe(0);
    });

    it('should return UNCERTAIN decision for partial matches', () => {
      const postData = {
        id: 'post3',
        caption: 'Fitness tips and gym routines',
        hashtags: ['health'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post3',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'gym', 'sports'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeGreaterThan(0.3);
      expect(result.score).toBeLessThan(0.8);
      expect(result.decision).toBe(FilterDecision.UNCERTAIN);
    });

    it('should handle case-insensitive matching', () => {
      const postData = {
        id: 'post4',
        caption: 'AMAZING WORKOUT',
        hashtags: ['FITNESS', 'GYM'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post4',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'gym'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeGreaterThanOrEqual(0.8);
      expect(result.decision).toBe(FilterDecision.SHOW);
    });

    it('should handle fuzzy matching with typos', () => {
      const postData = {
        id: 'post5',
        caption: 'Great fitnes workout',
        hashtags: ['fitnes'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post5',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness'];
      const result = matcher.match(postData, keywords);

      // Should still match with fuzzy logic
      expect(result.matchedKeywords.length).toBeGreaterThan(0);
    });

    it('should handle empty keywords', () => {
      const postData = {
        id: 'post6',
        caption: 'Some content',
        hashtags: [],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post6',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords: string[] = [];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBe(0);
      expect(result.decision).toBe(FilterDecision.HIDE);
    });

    it('should handle empty caption', () => {
      const postData = {
        id: 'post7',
        caption: '',
        hashtags: ['fitness'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post7',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeGreaterThanOrEqual(0.8);
      expect(result.decision).toBe(FilterDecision.SHOW);
    });

    it('should prioritize hashtag matches over caption matches', () => {
      const postData = {
        id: 'post8',
        caption: 'Random content about something else',
        hashtags: ['fitness', 'gym'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post8',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness'];
      const result = matcher.match(postData, keywords);

      expect(result.score).toBeGreaterThanOrEqual(0.8);
      expect(result.decision).toBe(FilterDecision.SHOW);
    });

    it('should handle multiple keywords correctly', () => {
      const postData = {
        id: 'post9',
        caption: 'Fitness and gym workout',
        hashtags: ['fitness', 'gym', 'workout'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post9',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'gym', 'sports', 'yoga'];
      const result = matcher.match(postData, keywords);

      expect(result.matchedKeywords.length).toBe(2);
      expect(result.matchedKeywords).toContain('fitness');
      expect(result.matchedKeywords).toContain('gym');
    });

    it('should complete matching in less than 5ms', () => {
      const postData = {
        id: 'post10',
        caption: 'Fitness and gym workout routine',
        hashtags: ['fitness', 'gym', 'workout', 'health'],
        username: 'johndoe',
        postUrl: 'https://instagram.com/p/post10',
        imageUrls: [],
        videoUrl: null,
        postType: 'image' as const,
        extractedAt: Date.now(),
      };

      const keywords = ['fitness', 'gym', 'sports', 'yoga', 'health'];

      const startTime = Date.now();
      matcher.match(postData, keywords);
      const endTime = Date.now();

      expect(endTime - startTime).toBeLessThan(5);
    });
  });
});
