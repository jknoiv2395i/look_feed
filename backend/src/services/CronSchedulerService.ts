import logger from '@config/logger';

/**
 * Cron Scheduler Service
 * Handles scheduled task execution
 */

export interface CronTask {
  id: string;
  name: string;
  schedule: string; // Cron expression
  handler: () => Promise<void>;
  enabled: boolean;
  lastRun?: Date;
  nextRun?: Date;
  lastError?: string;
}

export class CronSchedulerService {
  private tasks: Map<string, CronTask> = new Map();
  private running: boolean = false;
  private checkInterval: NodeJS.Timeout | null = null;

  /**
   * Register cron task
   */
  public registerTask(
    id: string,
    name: string,
    schedule: string,
    handler: () => Promise<void>
  ): void {
    const task: CronTask = {
      id,
      name,
      schedule,
      handler,
      enabled: true,
      nextRun: this.calculateNextRun(schedule),
    };

    this.tasks.set(id, task);
    logger.info('Cron task registered', { id, name, schedule });
  }

  /**
   * Start scheduler
   */
  public start(checkIntervalMs: number = 60000): void {
    if (this.running) {
      logger.warn('Cron scheduler already running');
      return;
    }

    this.running = true;
    logger.info('Cron scheduler started');

    this.checkInterval = setInterval(() => {
      this.checkAndExecuteTasks().catch((error) => {
        logger.error('Error checking cron tasks:', error);
      });
    }, checkIntervalMs);
  }

  /**
   * Stop scheduler
   */
  public stop(): void {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
    }

    this.running = false;
    logger.info('Cron scheduler stopped');
  }

  /**
   * Check and execute tasks
   */
  private async checkAndExecuteTasks(): Promise<void> {
    const now = new Date();

    for (const task of this.tasks.values()) {
      if (!task.enabled) {
        continue;
      }

      if (task.nextRun && now >= task.nextRun) {
        await this.executeTask(task);
        task.nextRun = this.calculateNextRun(task.schedule);
      }
    }
  }

  /**
   * Execute single task
   */
  private async executeTask(task: CronTask): Promise<void> {
    try {
      logger.info('Executing cron task', { id: task.id, name: task.name });

      task.lastRun = new Date();
      await task.handler();

      task.lastError = undefined;
      logger.info('Cron task completed', { id: task.id, name: task.name });
    } catch (error) {
      task.lastError = (error as Error).message;
      logger.error('Cron task error:', error, { id: task.id, name: task.name });
    }
  }

  /**
   * Calculate next run time (simplified cron parsing)
   */
  private calculateNextRun(schedule: string): Date {
    // Simplified cron parsing - in production use a library like 'cron-parser'
    const now = new Date();
    const parts = schedule.split(' ');

    if (parts.length !== 5) {
      logger.warn('Invalid cron expression', { schedule });
      return new Date(now.getTime() + 60000); // Default to 1 minute
    }

    const [minute, hour, dayOfMonth, month, dayOfWeek] = parts;

    // Parse minute
    const nextMinute = this.parseField(minute, 0, 59);
    const nextHour = this.parseField(hour, 0, 23);

    const next = new Date(now);
    next.setHours(nextHour);
    next.setMinutes(nextMinute);
    next.setSeconds(0);
    next.setMilliseconds(0);

    if (next <= now) {
      next.setDate(next.getDate() + 1);
    }

    return next;
  }

  /**
   * Parse cron field
   */
  private parseField(field: string, min: number, max: number): number {
    if (field === '*') {
      return min;
    }

    if (field.includes(',')) {
      const values = field.split(',').map((v) => parseInt(v, 10));
      return values[0];
    }

    if (field.includes('/')) {
      const [start, step] = field.split('/');
      const startVal = start === '*' ? min : parseInt(start, 10);
      return startVal;
    }

    return parseInt(field, 10);
  }

  /**
   * Enable task
   */
  public enableTask(id: string): void {
    const task = this.tasks.get(id);
    if (task) {
      task.enabled = true;
      logger.info('Cron task enabled', { id });
    }
  }

  /**
   * Disable task
   */
  public disableTask(id: string): void {
    const task = this.tasks.get(id);
    if (task) {
      task.enabled = false;
      logger.info('Cron task disabled', { id });
    }
  }

  /**
   * Get task status
   */
  public getTaskStatus(id: string): CronTask | null {
    return this.tasks.get(id) || null;
  }

  /**
   * Get all tasks
   */
  public getAllTasks(): CronTask[] {
    return Array.from(this.tasks.values());
  }

  /**
   * Get scheduler status
   */
  public getStatus(): Record<string, any> {
    return {
      running: this.running,
      taskCount: this.tasks.size,
      tasks: Array.from(this.tasks.values()).map((task) => ({
        id: task.id,
        name: task.name,
        enabled: task.enabled,
        lastRun: task.lastRun,
        nextRun: task.nextRun,
        lastError: task.lastError,
      })),
    };
  }
}

export default new CronSchedulerService();
