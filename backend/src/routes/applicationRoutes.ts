import { Router } from 'express';

import {
  getMyApplications,
  updateApplicationStatusHandler,
} from '../controllers/applicationController';
import { authenticateToken, requireRole } from '../middleware/auth';

const router = Router();

router.get(
  '/me',
  authenticateToken,
  requireRole('JOB_SEEKER'),
  getMyApplications,
);

router.patch(
  '/:id/status',
  authenticateToken,
  requireRole('EMPLOYER'),
  updateApplicationStatusHandler,
);

export default router;