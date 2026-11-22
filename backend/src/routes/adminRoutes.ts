import { Router } from 'express';

import {
  getStats,
  listCompanies,
  listUsers,
  reindexAll,
  toggleUserStatus,
  updateVerification,
} from '../controllers/adminController';
import { listReports, resolveReport } from '../controllers/reportController';
import { authenticateToken, requireRole } from '../middleware/auth';
import { success } from '../utils/response';

const router = Router();

// All admin routes require a valid token AND the ADMIN role
router.use(authenticateToken);
router.use(requireRole('ADMIN'));

router.get('/ping', (_req, res) => {
  success(res, { message: 'Admin access granted' });
});

router.post('/reindex', reindexAll);

router.get('/stats', getStats);
router.get('/users', listUsers);
router.patch('/users/:id/status', toggleUserStatus);

router.get('/companies', listCompanies);
router.patch('/companies/:id/verify', updateVerification);

// REPORTS - These were missing, causing the "Route not found" error
router.get('/reports', listReports);
router.patch('/reports/:id/status', resolveReport);

export default router;