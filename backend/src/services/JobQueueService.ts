import logger from '@config/logger';

/**
 * Job Queue Service
 * Handles background job processing and scheduling
 */

export interface Job {
  id: string;
  type: string;
  data: Record<string, any>;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  retries: number;
  maxRetries: number;
  createdAt: Date;
  startedAt?: Date;
  completedAt?: Date;
  error?: string;
}

export interface JobHandler {
  (data: Record<string, any>): Promise<void>;
}

export class JobQueueService {
  private jobs: Map<string, Job> = new Map();
  private handlers: Map<string, JobHandler> = new Map();
  private processing: boolean = false;
  private processInterval: NodeJS.Timeout | null = null;

  /**
   * Register job handler
   */
  public registerHandler(jobType: string, handler: JobHandler): void {
    this.handlers.set(jobType, handler);
    logger.info('Job handler registered', { jobType });
  }

  /**
   * Enqueue job
   */
  public async enqueueJob(
    jobType: string,
    data: Record<string, any>,
    maxRetries: number = 3
  ): Promise<string> {
    const jobId = `job_${Date.now()}_${Math.random().toString(36).substring(7)}`;

    const job: Job = {
      id: jobId,
      type: jobType,
      data,
      status: 'pending',
      retries: 0,
      maxRetries,
      createdAt: new Date(),
    };

    this.jobs.set(jobId, job);
    logger.debug('Job enqueued', { jobId, jobType });

    return jobId;
  }

  /**
   * Get job status
   */
  public getJobStatus(jobId: string): Job | null {
    return this.jobs.get(jobId) || null;
  }

  /**
   * Start processing jobs
   */
  public startProcessing(intervalMs: number = 1000): void {
    if (this.processing) {
      logger.warn('Job processing already started');
      return;
    }

    this.processing = true;
    logger.info('Job processing started');

    this.processInterval = setInterval(() => {
      this.processNextJob().catch((error) => {
        logger.error('Error processing job:', error);
      });
    }, intervalMs);
  }

  /**
   * Stop processing jobs
   */
  public stopProcessing(): void {
    if (this.processInterval) {
      clearInterval(this.processInterval);
      this.processInterval = null;
    }

    this.processing = false;
    logger.info('Job processing stopped');
  }

  /**
   * Process next job
   */
  private async processNextJob(): Promise<void> {
    const pendingJob = Array.from(this.jobs.values()).find((job) => job.status === 'pending');

    if (!pendingJob) {
      return;
    }

    const handler = this.handlers.get(pendingJob.type);
    if (!handler) {
      logger.error('No handler for job type', { jobType: pendingJob.type });
      pendingJob.status = 'failed';
      pendingJob.error = 'No handler registered';
      return;
    }

    try {
      pendingJob.status = 'processing';
      pendingJob.startedAt = new Date();

      await handler(pendingJob.data);

      pendingJob.status = 'completed';
      pendingJob.completedAt = new Date();
      logger.info('Job completed', { jobId: pendingJob.id, jobType: pendingJob.type });
    } catch (error) {
      logger.error('Job processing error:', error);

      if (pendingJob.retries < pendingJob.maxRetries) {
        pendingJob.retries++;
        pendingJob.status = 'pending';
        logger.info('Job retrying', { jobId: pendingJob.id, retries: pendingJob.retries });
      } else {
        pendingJob.status = 'failed';
        pendingJob.error = (error as Error).message;
        logger.error('Job failed after retries', { jobId: pendingJob.id });
      }
    }
  }

  /**
   * Get queue stats
   */
  public getStats(): Record<string, number> {
    const stats = {
      total: this.jobs.size,
      pending: 0,
      processing: 0,
      completed: 0,
      failed: 0,
    };

    this.jobs.forEach((job) => {
      stats[job.status]++;
    });

    return stats;
  }

  /**
   * Clear completed jobs
   */
  public clearCompleted(): number {
    let cleared = 0;

    this.jobs.forEach((job, jobId) => {
      if (job.status === 'completed') {
        this.jobs.delete(jobId);
        cleared++;
      }
    });

    logger.info('Completed jobs cleared', { count: cleared });
    return cleared;
  }

  /**
   * Clear failed jobs
   */
  public clearFailed(): number {
    let cleared = 0;

    this.jobs.forEach((job, jobId) => {
      if (job.status === 'failed') {
        this.jobs.delete(jobId);
        cleared++;
      }
    });

    logger.info('Failed jobs cleared', { count: cleared });
    return cleared;
  }
}

export default new JobQueueService();
