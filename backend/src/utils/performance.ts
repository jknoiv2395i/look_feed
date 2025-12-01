import logger from '@config/logger';

/**
 * Performance Optimization Utilities
 * Caching, memoization, and performance tracking
 */

export interface CacheOptions {
  ttl?: number; // Time to live in milliseconds
  key?: string;
}

/**
 * Simple memoization decorator
 */
export function memoize<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  options: CacheOptions = {}
): T {
  const cache = new Map<string, { value: any; expiry: number }>();
  const ttl = options.ttl || 3600000; // 1 hour default

  return (async (...args: any[]) => {
    const key = options.key || JSON.stringify(args);

    const cached = cache.get(key);
    if (cached && cached.expiry > Date.now()) {
      logger.debug('Cache hit', { key });
      return cached.value;
    }

    const result = await fn(...args);
    cache.set(key, {
      value: result,
      expiry: Date.now() + ttl,
    });

    return result;
  }) as T;
}

/**
 * Batch processing utility
 */
export class BatchProcessor<T, R> {
  private queue: T[] = [];
  private batchSize: number;
  private timeout: number;
  private processor: (batch: T[]) => Promise<R[]>;
  private timer: NodeJS.Timeout | null = null;

  constructor(
    processor: (batch: T[]) => Promise<R[]>,
    batchSize: number = 100,
    timeout: number = 1000
  ) {
    this.processor = processor;
    this.batchSize = batchSize;
    this.timeout = timeout;
  }

  /**
   * Add item to batch
   */
  public async add(item: T): Promise<R | null> {
    this.queue.push(item);

    if (this.queue.length >= this.batchSize) {
      return this.flush();
    }

    if (!this.timer) {
      this.timer = setTimeout(() => this.flush(), this.timeout);
    }

    return null;
  }

  /**
   * Flush batch
   */
  public async flush(): Promise<R | null> {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }

    if (this.queue.length === 0) {
      return null;
    }

    const batch = this.queue.splice(0, this.batchSize);
    logger.debug('Processing batch', { size: batch.length });

    try {
      const results = await this.processor(batch);
      return results[results.length - 1] || null;
    } catch (error) {
      logger.error('Batch processing error:', error);
      throw error;
    }
  }
}

/**
 * Rate limiter with sliding window
 */
export class SlidingWindowRateLimiter {
  private windows: Map<string, number[]> = new Map();
  private limit: number;
  private windowSize: number;

  constructor(limit: number, windowSize: number = 60000) {
    this.limit = limit;
    this.windowSize = windowSize;
  }

  /**
   * Check if request is allowed
   */
  public isAllowed(key: string): boolean {
    const now = Date.now();
    const window = this.windows.get(key) || [];

    // Remove old entries outside window
    const filtered = window.filter((timestamp) => now - timestamp < this.windowSize);

    if (filtered.length < this.limit) {
      filtered.push(now);
      this.windows.set(key, filtered);
      return true;
    }

    return false;
  }

  /**
   * Get remaining requests
   */
  public getRemaining(key: string): number {
    const now = Date.now();
    const window = this.windows.get(key) || [];
    const filtered = window.filter((timestamp) => now - timestamp < this.windowSize);
    return Math.max(0, this.limit - filtered.length);
  }

  /**
   * Reset key
   */
  public reset(key: string): void {
    this.windows.delete(key);
  }
}

/**
 * Circuit breaker pattern
 */
export class CircuitBreaker<T> {
  private failureCount: number = 0;
  private lastFailureTime: number = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private threshold: number;
  private timeout: number;

  constructor(threshold: number = 5, timeout: number = 60000) {
    this.threshold = threshold;
    this.timeout = timeout;
  }

  /**
   * Execute function with circuit breaker
   */
  public async execute<R>(fn: () => Promise<R>): Promise<R> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailureTime > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  /**
   * Handle success
   */
  private onSuccess(): void {
    this.failureCount = 0;
    this.state = 'closed';
  }

  /**
   * Handle failure
   */
  private onFailure(): void {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.threshold) {
      this.state = 'open';
    }
  }

  /**
   * Get current state
   */
  public getState(): string {
    return this.state;
  }
}

/**
 * Performance timer
 */
export class PerformanceTimer {
  private startTime: number;
  private marks: Map<string, number> = new Map();

  constructor() {
    this.startTime = Date.now();
  }

  /**
   * Mark a point in time
   */
  public mark(name: string): void {
    this.marks.set(name, Date.now());
  }

  /**
   * Measure time between marks
   */
  public measure(name: string, startMark: string, endMark: string): number {
    const start = this.marks.get(startMark) || this.startTime;
    const end = this.marks.get(endMark) || Date.now();
    return end - start;
  }

  /**
   * Get elapsed time since start
   */
  public elapsed(): number {
    return Date.now() - this.startTime;
  }

  /**
   * Get all marks
   */
  public getMarks(): Record<string, number> {
    return Object.fromEntries(this.marks);
  }
}

/**
 * Retry with exponential backoff
 */
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  initialDelay: number = 100
): Promise<T> {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      if (attempt < maxRetries - 1) {
        const delay = initialDelay * Math.pow(2, attempt);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError;
}

/**
 * Timeout wrapper
 */
export function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number
): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error('Operation timeout')), timeoutMs)
    ),
  ]);
}

export default {
  memoize,
  BatchProcessor,
  SlidingWindowRateLimiter,
  CircuitBreaker,
  PerformanceTimer,
  retryWithBackoff,
  withTimeout,
};
