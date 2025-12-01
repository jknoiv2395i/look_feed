import knex from 'knex';
import { config } from './environment';
import logger from './logger';

const knexConfig = {
  client: 'pg',
  connection: {
    host: config.database.host,
    port: config.database.port,
    user: config.database.user,
    password: config.database.password,
    database: config.database.name,
  },
  pool: config.database.pool,
  migrations: {
    directory: './src/database/migrations',
    extension: 'ts',
  },
  seeds: {
    directory: './src/database/seeds',
    extension: 'ts',
  },
};

export const db = knex(knexConfig);

// Test database connection
export async function testDatabaseConnection(): Promise<void> {
  try {
    await db.raw('SELECT 1');
    logger.info('Database connection successful');
  } catch (error) {
    logger.error('Database connection failed:', error);
    throw error;
  }
}

export default db;
