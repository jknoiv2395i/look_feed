import { Router } from 'express';
import AuthController from '@controllers/AuthController';
import { authMiddleware } from '@middleware/auth';

const router = Router();

/**
 * Authentication Routes
 * POST   /api/v1/auth/register       - Register new user
 * POST   /api/v1/auth/login          - Login user
 * POST   /api/v1/auth/refresh        - Refresh access token
 * POST   /api/v1/auth/logout         - Logout user
 * GET    /api/v1/auth/me             - Get current user profile
 * POST   /api/v1/auth/verify-email   - Verify email
 * POST   /api/v1/auth/forgot-password - Request password reset
 * POST   /api/v1/auth/reset-password  - Reset password
 */

// Public routes
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/refresh', AuthController.refresh);
router.post('/forgot-password', AuthController.forgotPassword);
router.post('/reset-password', AuthController.resetPassword);
router.post('/verify-email', AuthController.verifyEmail);

// Protected routes
router.get('/me', authMiddleware, AuthController.getCurrentUser);
router.post('/logout', authMiddleware, AuthController.logout);

export default router;
