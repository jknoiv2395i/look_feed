import { Request, Response, NextFunction } from 'express';
import JWTService from '@utils/jwt';
import { AuthenticationError, AuthorizationError } from '@utils/errors';
import { User } from '@types/index';

declare global {
  namespace Express {
    interface Request {
      userId?: string;
      user?: User;
      token?: string;
    }
  }
}

export function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AuthenticationError('Missing or invalid authorization header');
    }

    const token = authHeader.substring(7);
    const payload = JWTService.verifyAccessToken(token);

    req.userId = payload.userId;
    req.token = token;

    next();
  } catch (error) {
    if (error instanceof AuthenticationError) {
      throw error;
    }
    throw new AuthenticationError('Invalid token');
  }
}

export function optionalAuthMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const payload = JWTService.verifyAccessToken(token);
      req.userId = payload.userId;
      req.token = token;
    }

    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
}

export function roleMiddleware(allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      throw new AuthenticationError('User not authenticated');
    }

    if (!allowedRoles.includes(req.user.tier)) {
      throw new AuthorizationError('Insufficient permissions');
    }

    next();
  };
}
