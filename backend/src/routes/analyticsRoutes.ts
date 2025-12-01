import { Router } from 'express';
import AnalyticsController from '@controllers/AnalyticsController';
import { authMiddleware } from '@middleware/auth';

const router = Router();

/**
 * Analytics Routes
 * GET    /api/v1/analytics/dashboard      - Get dashboard
 * GET    /api/v1/analytics/keywords       - Get keyword stats
 * GET    /api/v1/analytics/daily          - Get daily stats
 * GET    /api/v1/analytics/summary        - Get summary
 * GET    /api/v1/analytics/comparison     - Get comparison
 * GET    /api/v1/analytics/export         - Export as CSV
 */

const analyticsController = new AnalyticsController();

// All routes require authentication
router.use(authMiddleware);

// Dashboard and summaries
router.get('/dashboard', analyticsController.getDashboard);
router.get('/summary', analyticsController.getSummary);
router.get('/comparison', analyticsController.getComparison);

// Detailed stats
router.get('/keywords', analyticsController.getKeywordStats);
router.get('/daily', analyticsController.getDailyStats);

// Export
router.get('/export', analyticsController.exportAnalytics);

export default router;
