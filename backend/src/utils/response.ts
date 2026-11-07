import { Response } from 'express';

export function success(res: Response, data: unknown, status = 200): Response {
  return res.status(status).json({
    success: true,
    data,
  });
}

export function failure(res: Response, message: string, status = 400): Response {
  return res.status(status).json({
    success: false,
    message,
  });
}