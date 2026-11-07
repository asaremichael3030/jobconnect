import { Request, Response, NextFunction } from 'express';

import { getSearchStats } from '../models/analyticsModel';
import { success } from '../utils/response';

export async function getAnalytics(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const stats = await getSearchStats();
    success(res, stats);
  } catch (error) {
    next(error);
  }
}