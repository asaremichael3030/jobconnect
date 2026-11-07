import { Router } from 'express';

import {
  getMyProfile,
  updateMyProfile,
  uploadProfilePicture,
  uploadResume,
  addExperience,
  addEducation,
  addSkill,
} from '../controllers/userController';
import { authenticateToken } from '../middleware/auth';
import { profilePictureUpload, resumeUpload } from '../middleware/upload';

const router = Router();

router.get('/me', authenticateToken, getMyProfile);
router.put('/me', authenticateToken, updateMyProfile);

router.post(
  '/me/profile-picture',
  authenticateToken,
  profilePictureUpload.single('file'),
  uploadProfilePicture,
);

router.post(
  '/me/resume',
  authenticateToken,
  resumeUpload.single('file'),
  uploadResume,
);

router.post('/me/experience', authenticateToken, addExperience);
router.post('/me/education', authenticateToken, addEducation);
router.post('/me/skills', authenticateToken, addSkill);

export default router;