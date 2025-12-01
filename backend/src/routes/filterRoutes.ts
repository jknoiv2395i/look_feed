import { Router } from 'express';
import FilterController from '@controllers/FilterController';
import { authMiddleware } from '@middleware/auth';

const router = Router();

/**
 * Filter Routes
 * POST   /api/v1/filter/classify     - Classify post
 * POST   /api/v1/filter/log          - Log filter decision
 * POST   /api/v1/filter/log/batch    - Batch log decisions
 * GET    /api/v1/filter/config       - Get config
 * PUT    /api/v1/filter/config       - Update config
 * GET    /api/v1/filter/cache/stats  - Get cache stats
 * DELETE /api/v1/filter/cache        - Clear cache
 */

const filterController = new FilterController();

// All routes require authentication
router.use(authMiddleware);

// Classification
router.post('/classify', filterController.classify);

// Logging
router.post('/log', filterController.logFilterDecision);
router.post('/log/batch', filterController.batchLogFilterDecisions);

// Configuration
router.get('/config', filterController.getFilterConfig);
router.put('/config', filterController.updateFilterConfig);

// Cache management
router.get('/cache/stats', filterController.getCacheStats);
router.delete('/cache', filterController.clearCache);

export default router;
