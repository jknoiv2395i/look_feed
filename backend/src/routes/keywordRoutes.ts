import { Router } from 'express';
import KeywordController from '@controllers/KeywordController';
import { authMiddleware } from '@middleware/auth';

const router = Router();

/**
 * Keyword Routes
 * GET    /api/v1/keywords            - Get all keywords
 * GET    /api/v1/keywords/:id        - Get single keyword
 * POST   /api/v1/keywords            - Create keyword
 * PUT    /api/v1/keywords/:id        - Update keyword
 * DELETE /api/v1/keywords/:id        - Delete keyword
 * POST   /api/v1/keywords/bulk       - Bulk add keywords
 * DELETE /api/v1/keywords            - Delete all keywords
 * GET    /api/v1/keywords/suggestions - Get suggestions
 */

// All routes require authentication
router.use(authMiddleware);

// List and create
router.get('/', KeywordController.getKeywords);
router.post('/', KeywordController.createKeyword);

// Bulk operations
router.post('/bulk', KeywordController.bulkAddKeywords);
router.delete('/', KeywordController.deleteAllKeywords);

// Suggestions
router.get('/suggestions', KeywordController.getKeywordSuggestions);

// Single keyword operations
router.get('/:id', KeywordController.getKeyword);
router.put('/:id', KeywordController.updateKeyword);
router.delete('/:id', KeywordController.deleteKeyword);

export default router;
