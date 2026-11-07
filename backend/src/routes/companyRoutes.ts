import { Router } from 'express';

import {
  getMyCompany,
  updateMyCompany,
  uploadCompanyLogo,
} from '../controllers/companyController';
import { authenticateToken, requireRole } from '../middleware/auth';
import { companyLogoUpload } from '../middleware/upload';

const router = Router();

router.get('/me', authenticateToken, requireRole('EMPLOYER'), getMyCompany);
router.put('/me', authenticateToken, requireRole('EMPLOYER'), updateMyCompany);
router.post(
  '/me/logo',
  authenticateToken,
  requireRole('EMPLOYER'),
  companyLogoUpload.single('file'),
  uploadCompanyLogo,
);

export default router;