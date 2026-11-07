import { Router } from 'express';

import { listSavedJobs } from '../controllers/savedJobController';
import { authenticateToken, requireRole } from '../middleware/auth';

const router = Router();

router.get(
  '/',
  authenticateToken,
  requireRole('JOB_SEEKER'),
  listSavedJobs,
);

export default router;