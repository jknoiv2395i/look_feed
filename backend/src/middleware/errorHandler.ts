import { Request, Response, NextFunction } from 'express';
import { AppError } from '@utils/errors';
import logger from '@config/logger';
import { ApiResponse } from '@types/index';

export function errorHandler(
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  logger.error('Error occurred:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  if (err instanceof AppError) {
    const response: ApiResponse<null> = {
      success: false,
      error: {
        status: err.status,
        message: err.message,
        code: err.code,
        details: err.details,
      },
      timestamp: new Date().toISOString(),
    };
    res.status(err.status).json(response);
    return;
  }

  // Handle unknown errors
  const response: ApiResponse<null> = {
    success: false,
    error: {
      status: 500,
      message: 'Internal server error',
      code: 'INTERNAL_SERVER_ERROR',
    },
    timestamp: new Date().toISOString(),
  };
  res.status(500).json(response);
}

export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
