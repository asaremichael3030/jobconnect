import { Router } from 'express';

import { getAnalytics } from '../controllers/analyticsController';
import { authenticateToken, requireRole } from '../middleware/auth';

const router = Router();

router.get(
  '/searches',
  authenticateToken,
  requireRole('ADMIN'),
  getAnalytics,
);

export default router;