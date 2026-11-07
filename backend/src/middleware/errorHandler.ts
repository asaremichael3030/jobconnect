import { Request, Response, NextFunction } from 'express';

interface HttpError extends Error {
  statusCode?: number;
}

export function errorHandler(
  err: HttpError,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const status = err.statusCode ?? 500;
  const message = err.message || 'Internal server error';

  console.error(`[error] ${status} ${message}`);

  res.status(status).json({
    success: false,
    message,
  });
}

export function notFoundHandler(_req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
}