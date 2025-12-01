import { createClient, RedisClientType } from 'redis';
import { config } from './environment';
import logger from './logger';

let redisClient: RedisClientType | null = null;

export async function initializeRedis(): Promise<RedisClientType> {
  try {
    const client = createClient({
      host: config.redis.host,
      port: config.redis.port,
      password: config.redis.password,
      db: config.redis.db,
    });

    client.on('error', (err) => logger.error('Redis Client Error', err));
    client.on('connect', () => logger.info('Redis Client Connected'));

    await client.connect();
    redisClient = client;
    logger.info('Redis connection successful');
    return client;
  } catch (error) {
    logger.error('Redis connection failed:', error);
    throw error;
  }
}

export function getRedisClient(): RedisClientType {
  if (!redisClient) {
    throw new Error('Redis client not initialized. Call initializeRedis() first.');
  }
  return redisClient;
}

export async function closeRedis(): Promise<void> {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
    logger.info('Redis connection closed');
  }
}

export default getRedisClient;
