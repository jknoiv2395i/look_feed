import { PostData, FilterDecision, MatchResult } from '@types/index';
import logger from '@config/logger';

export class KeywordMatcher {
  /**
   * Normalize text for matching: lowercase, trim, normalize whitespace
   */
  private normalizeText(text: string): string {
    return text
      .toLowerCase()
      .trim()
      .replace(/\s+/g, ' ')
      .replace(/[^\w\s#]/g, '');
  }

  /**
   * Calculate Levenshtein distance between two strings
   * Used for fuzzy matching
   */
  private levenshteinDistance(str1: string, str2: string): number {
    const len1 = str1.length;
    const len2 = str2.length;
    const matrix: number[][] = [];

    for (let i = 0; i <= len2; i++) {
      matrix[i] = [i];
    }

    for (let j = 0; j <= len1; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= len2; i++) {
      for (let j = 1; j <= len1; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1
          );
        }
      }
    }

    return matrix[len2][len1];
  }

  /**
   * Calculate fuzzy match confidence (0.0 - 1.0)
   */
  private calculateFuzzyMatch(keyword: string, text: string): number {
    const normalizedKeyword = this.normalizeText(keyword);
    const normalizedText = this.normalizeText(text);

    // Exact match
    if (normalizedText.includes(normalizedKeyword)) {
      return 1.0;
    }

    // Levenshtein distance based fuzzy match
    const distance = this.levenshteinDistance(normalizedKeyword, normalizedText);
    const maxLen = Math.max(normalizedKeyword.length, normalizedText.length);

    if (distance <= 2) {
      return 0.8;
    }

    if (distance <= 3) {
      return 0.6;
    }

    return 0.0;
  }

  /**
   * Match post data against keywords
   * Returns score, matched keywords, and decision
   */
  public match(postData: PostData, keywords: string[]): MatchResult {
    const startTime = Date.now();

    try {
      // Prepare content for matching
      const caption = postData.caption || '';
      const hashtags = postData.hashtags || [];
      const normalizedCaption = this.normalizeText(caption);
      const normalizedHashtags = hashtags.map(h => this.normalizeText(h));

      const matchedKeywords: string[] = [];
      let totalScore = 0;

      // Match each keyword
      for (const keyword of keywords) {
        const normalizedKeyword = this.normalizeText(keyword);
        let keywordScore = 0;

        // Check hashtags (highest priority)
        for (const hashtag of normalizedHashtags) {
          if (hashtag === normalizedKeyword) {
            keywordScore = 1.0;
            break;
          }
        }

        // Check caption (if no hashtag match)
        if (keywordScore === 0) {
          keywordScore = this.calculateFuzzyMatch(normalizedKeyword, normalizedCaption);
        }

        if (keywordScore > 0) {
          matchedKeywords.push(keyword);
          totalScore += keywordScore;
        }
      }

      // Calculate overall relevance score
      const score = keywords.length > 0 ? totalScore / keywords.length : 0;

      // Determine decision based on thresholds
      let decision: FilterDecision;
      if (score >= 0.8) {
        decision = FilterDecision.SHOW;
      } else if (score <= 0.3) {
        decision = FilterDecision.HIDE;
      } else {
        decision = FilterDecision.UNCERTAIN;
      }

      const processingTime = Date.now() - startTime;

      logger.debug('Keyword matching completed', {
        postId: postData.id,
        score,
        decision,
        matchedKeywords,
        processingTime,
      });

      return {
        score,
        matchedKeywords,
        decision,
        method: 'keyword',
      };
    } catch (error) {
      logger.error('Error in keyword matching:', error);
      throw error;
    }
  }
}

export default KeywordMatcher;
