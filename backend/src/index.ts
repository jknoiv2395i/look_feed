import express, { Express } from 'express';
import cors from 'cors';
import compression from 'compression';
import helmet from 'helmet';
import { config, validateConfig } from '@config/environment';
import logger from '@config/logger';
import { testDatabaseConnection } from '@config/database';
import { initializeRedis } from '@config/redis';
import { errorHandler, asyncHandler } from '@middleware/errorHandler';

// Validate environment configuration
validateConfig();

const app: Express = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info(`${req.method} ${req.path} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// API version endpoint
app.get('/api/v1', (req, res) => {
  res.json({
    version: '1.0.0',
    name: 'Feed Lock API',
    description: 'Instagram Content Filtering Engine',
  });
});

// Import and register routes
import apiRoutes from '@routes/index';
app.use('/api/v1', apiRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: {
      status: 404,
      message: 'Endpoint not found',
      code: 'NOT_FOUND',
    },
    timestamp: new Date().toISOString(),
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Start server
async function startServer(): Promise<void> {
  try {
    // Test database connection
    await testDatabaseConnection();
    logger.info('Database connected successfully');

    // Initialize Redis
    await initializeRedis();
    logger.info('Redis connected successfully');

    // Start listening
    app.listen(config.app.port, () => {
      logger.info(`Server running on port ${config.app.port}`);
      logger.info(`Environment: ${config.app.nodeEnv}`);
      logger.info(`API URL: ${config.app.apiUrl}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received: closing HTTP server');
  process.exit(0);
});

// Start the server
startServer();

export default app;
