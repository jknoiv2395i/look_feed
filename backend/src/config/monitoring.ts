import logger from '@config/logger';

/**
 * Monitoring & Observability Configuration
 * Tracks application metrics and performance
 */

export interface MetricPoint {
  timestamp: number;
  value: number;
  labels?: Record<string, string>;
}

export interface PerformanceMetrics {
  requestCount: number;
  errorCount: number;
  averageResponseTime: number;
  p95ResponseTime: number;
  p99ResponseTime: number;
  cacheHitRate: number;
  dbQueryTime: number;
}

class MonitoringService {
  private metrics: Map<string, MetricPoint[]> = new Map();
  private performanceBuffer: number[] = [];
  private requestCounter: number = 0;
  private errorCounter: number = 0;
  private cacheHits: number = 0;
  private cacheMisses: number = 0;

  /**
   * Record API request
   */
  public recordRequest(method: string, path: string, statusCode: number, responseTime: number): void {
    this.requestCounter++;

    if (statusCode >= 400) {
      this.errorCounter++;
    }

    this.performanceBuffer.push(responseTime);

    // Keep only last 1000 measurements
    if (this.performanceBuffer.length > 1000) {
      this.performanceBuffer.shift();
    }

    const key = `${method}:${path}`;
    this.recordMetric(key, responseTime, { status: statusCode.toString() });
  }

  /**
   * Record cache hit
   */
  public recordCacheHit(): void {
    this.cacheHits++;
  }

  /**
   * Record cache miss
   */
  public recordCacheMiss(): void {
    this.cacheMisses++;
  }

  /**
   * Record database query time
   */
  public recordDatabaseQuery(query: string, duration: number): void {
    this.recordMetric('db_query_time', duration, { query: query.substring(0, 50) });
  }

  /**
   * Record custom metric
   */
  public recordMetric(name: string, value: number, labels?: Record<string, string>): void {
    if (!this.metrics.has(name)) {
      this.metrics.set(name, []);
    }

    const points = this.metrics.get(name)!;
    points.push({
      timestamp: Date.now(),
      value,
      labels,
    });

    // Keep only last 100 points per metric
    if (points.length > 100) {
      points.shift();
    }
  }

  /**
   * Get current performance metrics
   */
  public getMetrics(): PerformanceMetrics {
    const sorted = [...this.performanceBuffer].sort((a, b) => a - b);
    const len = sorted.length;

    return {
      requestCount: this.requestCounter,
      errorCount: this.errorCounter,
      averageResponseTime: len > 0 ? sorted.reduce((a, b) => a + b, 0) / len : 0,
      p95ResponseTime: len > 0 ? sorted[Math.floor(len * 0.95)] : 0,
      p99ResponseTime: len > 0 ? sorted[Math.floor(len * 0.99)] : 0,
      cacheHitRate: this.cacheHits + this.cacheMisses > 0 
        ? this.cacheHits / (this.cacheHits + this.cacheMisses) 
        : 0,
      dbQueryTime: 0,
    };
  }

  /**
   * Get health status
   */
  public getHealthStatus(): Record<string, unknown> {
    const metrics = this.getMetrics();
    const errorRate = this.requestCounter > 0 ? this.errorCounter / this.requestCounter : 0;

    return {
      status: errorRate < 0.05 ? 'healthy' : 'degraded',
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      metrics,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Reset metrics
   */
  public reset(): void {
    this.metrics.clear();
    this.performanceBuffer = [];
    this.requestCounter = 0;
    this.errorCounter = 0;
    this.cacheHits = 0;
    this.cacheMisses = 0;
  }

  /**
   * Export metrics for external monitoring
   */
  public exportMetrics(): Record<string, unknown> {
    const health = this.getHealthStatus();
    
    return {
      timestamp: Date.now(),
      application: {
        name: 'Feed Lock API',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
      },
      health,
      metrics: Object.fromEntries(this.metrics),
    };
  }
}

export default new MonitoringService();
