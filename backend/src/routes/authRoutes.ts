import { Router } from 'express';

import {
  forgotPassword,
  getMe,
  login,
  register,
  resetPassword,
} from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Registration and Login
router.post('/register', register);
router.post('/login', login);
router.get('/me', authenticateToken, getMe);

// Password Reset
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

export default router;