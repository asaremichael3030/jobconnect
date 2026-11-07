import { Request, Response, NextFunction } from 'express';

import { verifyToken } from '../utils/jwt';
import { failure } from '../utils/response';

export function authenticateToken(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    failure(res, 'Authentication required', 401);
    return;
  }

  const token = header.slice('Bearer '.length).trim();

  if (!token) {
    failure(res, 'Authentication required', 401);
    return;
  }

  try {
    const payload = verifyToken(token);
    req.user = payload;
    next();
  } catch {
    failure(res, 'Invalid or expired token', 401);
    return;
  }
}

export function optionalAuth(
  req: Request,
  _res: Response,
  next: NextFunction,
): void {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    next();
    return;
  }

  const token = header.slice('Bearer '.length).trim();
  if (!token) {
    next();
    return;
  }

  try {
    const payload = verifyToken(token);
    req.user = payload;
  } catch {
    // Invalid or expired token → continue as unauthenticated
  }
  next();
}

export function requireRole(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      failure(res, 'Authentication required', 401);
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      failure(res, 'You do not have permission to access this resource', 403);
      return;
    }

    next();
  };
}