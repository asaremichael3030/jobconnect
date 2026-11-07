import { Router } from 'express';

import {
  getUnreadCount,
  listMyNotifications,
  markAll,
  markRead,
} from '../controllers/notificationController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

router.get('/', authenticateToken, listMyNotifications);
router.get('/unread-count', authenticateToken, getUnreadCount);
router.patch('/:id/read', authenticateToken, markRead);
router.patch('/read-all', authenticateToken, markAll);

export default router;