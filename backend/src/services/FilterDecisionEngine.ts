import { PostData, FilterDecision, FilterResult } from '@types/index';
import KeywordMatcher from './KeywordMatcher';
import AIClassifierService from './AIClassifierService';
import logger from '@config/logger';

export type FilterStrategy = 'strict' | 'moderate' | 'relaxed';

interface ThresholdConfig {
  keywordShowThreshold: number;
  keywordHideThreshold: number;
  aiShowThreshold: number;
}

const STRATEGY_THRESHOLDS: Record<FilterStrategy, ThresholdConfig> = {
  strict: {
    keywordShowThreshold: 0.9,
    keywordHideThreshold: 0.4,
    aiShowThreshold: 0.8,
  },
  moderate: {
    keywordShowThreshold: 0.8,
    keywordHideThreshold: 0.3,
    aiShowThreshold: 0.7,
  },
  relaxed: {
    keywordShowThreshold: 0.7,
    keywordHideThreshold: 0.2,
    aiShowThreshold: 0.6,
  },
};

export class FilterDecisionEngine {
  private keywordMatcher: KeywordMatcher;
  private aiClassifier: AIClassifierService;

  constructor() {
    this.keywordMatcher = new KeywordMatcher();
    this.aiClassifier = new AIClassifierService();
  }

  /**
   * Make filtering decision for a post
   */
  public async decide(
    postData: PostData,
    keywords: string[],
    strategy: FilterStrategy = 'moderate',
    enableAI: boolean = true
  ): Promise<FilterResult> {
    const startTime = Date.now();

    try {
      const thresholds = STRATEGY_THRESHOLDS[strategy];

      // Step 1: Keyword matching
      const keywordResult = this.keywordMatcher.match(postData, keywords);

      logger.debug('Keyword matching result', {
        postId: postData.id,
        score: keywordResult.score,
        decision: keywordResult.decision,
      });

      // Step 2: Make decision based on keyword score
      if (keywordResult.score >= thresholds.keywordShowThreshold) {
        const processingTime = Date.now() - startTime;
        return {
          decision: FilterDecision.SHOW,
          score: keywordResult.score,
          method: 'keyword',
          matchedKeywords: keywordResult.matchedKeywords,
          processingTimeMs: processingTime,
        };
      }

      if (keywordResult.score <= thresholds.keywordHideThreshold) {
        const processingTime = Date.now() - startTime;
        return {
          decision: FilterDecision.HIDE,
          score: keywordResult.score,
          method: 'keyword',
          matchedKeywords: keywordResult.matchedKeywords,
          processingTimeMs: processingTime,
        };
      }

      // Step 3: Use AI for uncertain cases
      if (enableAI && keywordResult.decision === FilterDecision.UNCERTAIN) {
        logger.debug('Sending to AI classifier', { postId: postData.id });

        const aiScore = await this.aiClassifier.classify(postData, keywords);

        const processingTime = Date.now() - startTime;

        const decision =
          aiScore >= thresholds.aiShowThreshold
            ? FilterDecision.SHOW
            : FilterDecision.HIDE;

        return {
          decision,
          score: aiScore,
          method: 'hybrid',
          matchedKeywords: keywordResult.matchedKeywords,
          processingTimeMs: processingTime,
        };
      }

      // Default to HIDE if uncertain and AI disabled
      const processingTime = Date.now() - startTime;
      return {
        decision: FilterDecision.HIDE,
        score: keywordResult.score,
        method: 'keyword',
        matchedKeywords: keywordResult.matchedKeywords,
        processingTimeMs: processingTime,
      };
    } catch (error) {
      logger.error('Error in filter decision engine:', error);
      throw error;
    }
  }

  /**
   * Get threshold configuration for a strategy
   */
  public getThresholds(strategy: FilterStrategy): ThresholdConfig {
    return STRATEGY_THRESHOLDS[strategy];
  }

  /**
   * Get all available strategies
   */
  public getAvailableStrategies(): FilterStrategy[] {
    return Object.keys(STRATEGY_THRESHOLDS) as FilterStrategy[];
  }
}

export default FilterDecisionEngine;
