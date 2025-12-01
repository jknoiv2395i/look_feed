import axios, { AxiosError } from 'axios';
import { config } from '@config/environment';
import logger from '@config/logger';
import { PostData } from '@types/index';
import { ExternalServiceError } from '@utils/errors';

interface OpenAIResponse {
  choices: Array<{
    message: {
      content: string;
    };
  }>;
}

export class AIClassifierService {
  private apiKey: string;
  private model: string;
  private temperature: number;
  private maxTokens: number;
  private baseURL = 'https://api.openai.com/v1';

  constructor() {
    this.apiKey = config.openai.apiKey;
    this.model = config.openai.model;
    this.temperature = config.openai.temperature;
    this.maxTokens = config.openai.maxTokens;

    if (!this.apiKey) {
      throw new Error('OpenAI API key not configured');
    }
  }

  /**
   * Construct prompt for AI classification
   */
  private constructPrompt(postData: PostData, keywords: string[]): string {
    const keywordsList = keywords.join(', ');
    const hashtags = postData.hashtags.join(' ');

    return `User's interests: ${keywordsList}

Post content:
Caption: "${postData.caption}"
Hashtags: ${hashtags || 'None'}

Rate the relevance of this post to the user's interests on a scale of 0.0 (completely irrelevant) to 1.0 (highly relevant).

Consider:
- Direct keyword matches (high relevance)
- Semantic similarity (moderate relevance)
- Topic alignment (moderate relevance)
- Context and intent (important)

Respond with ONLY a single number between 0.0 and 1.0, no explanation.`;
  }

  /**
   * Parse score from OpenAI response
   */
  private parseScore(response: string): number {
    const match = response.match(/0\.\d+|1\.0?/);
    if (match) {
      const score = parseFloat(match[0]);
      if (score >= 0 && score <= 1) {
        return score;
      }
    }
    // Default to neutral score if parsing fails
    return 0.5;
  }

  /**
   * Call OpenAI API for classification
   */
  private async callOpenAI(prompt: string): Promise<string> {
    try {
      const response = await axios.post<OpenAIResponse>(
        `${this.baseURL}/chat/completions`,
        {
          model: this.model,
          messages: [
            {
              role: 'system',
              content: 'You are a content relevance classifier. You analyze social media posts and rate their relevance to user-defined topics.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          temperature: this.temperature,
          max_tokens: this.maxTokens,
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 5000,
        }
      );

      return response.data.choices[0].message.content;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError;
        logger.error('OpenAI API error:', {
          status: axiosError.response?.status,
          data: axiosError.response?.data,
        });

        if (axiosError.response?.status === 429) {
          throw new ExternalServiceError('OpenAI', 'Rate limit exceeded');
        }
      }
      throw new ExternalServiceError('OpenAI', 'Failed to classify content');
    }
  }

  /**
   * Classify post content using AI
   */
  public async classify(postData: PostData, keywords: string[]): Promise<number> {
    const startTime = Date.now();

    try {
      logger.debug('Starting AI classification', {
        postId: postData.id,
        keywordCount: keywords.length,
      });

      const prompt = this.constructPrompt(postData, keywords);
      const response = await this.callOpenAI(prompt);
      const score = this.parseScore(response);

      const processingTime = Date.now() - startTime;

      logger.debug('AI classification completed', {
        postId: postData.id,
        score,
        processingTime,
      });

      return score;
    } catch (error) {
      logger.error('Error in AI classification:', error);
      // Return neutral score on error
      return 0.5;
    }
  }
}

export default AIClassifierService;
