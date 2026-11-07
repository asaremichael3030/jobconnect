import { Router } from 'express';

import {
  applyToJob,
  getJobApplications,
} from '../controllers/applicationController';
import {
  createJobHandler,
  getJobById,
  getMyJobs,
  listJobs,
} from '../controllers/jobController';
import {
  saveJobHandler,
  unsaveJobHandler,
} from '../controllers/savedJobController';
import {
  authenticateToken,
  optionalAuth,
  requireRole,
} from '../middleware/auth';

const router = Router();

// Public: browse active jobs
router.get('/', listJobs);

// Employer-only
router.get(
  '/me',
  authenticateToken,
  requireRole('EMPLOYER'),
  getMyJobs,
);
router.post(
  '/',
  authenticateToken,
  requireRole('EMPLOYER'),
  createJobHandler,
);

// Nested application routes (must come before /:id)
router.get(
  '/:id/applications',
  authenticateToken,
  requireRole('EMPLOYER'),
  getJobApplications,
);
router.post(
  '/:id/apply',
  authenticateToken,
  requireRole('JOB_SEEKER'),
  applyToJob,
);

// Nested save routes (must come before /:id)
router.post(
  '/:id/save',
  authenticateToken,
  requireRole('JOB_SEEKER'),
  saveJobHandler,
);
router.delete(
  '/:id/save',
  authenticateToken,
  requireRole('JOB_SEEKER'),
  unsaveJobHandler,
);

// Public: fetch one job (optional auth)
router.get('/:id', optionalAuth, getJobById);

export default router;