import { Router } from 'express';
import authRoutes from './authRoutes';
import keywordRoutes from './keywordRoutes';
import filterRoutes from './filterRoutes';
import analyticsRoutes from './analyticsRoutes';

const router = Router();

/**
 * API Routes
 * Combines all route modules
 */

// Authentication routes
router.use('/auth', authRoutes);

// Keyword routes
router.use('/keywords', keywordRoutes);

// Filter routes
router.use('/filter', filterRoutes);

// Analytics routes
router.use('/analytics', analyticsRoutes);

export default router;
