import { Router } from 'express';

import {
  getStats,
  listCompanies,
  listUsers,
  reindexAll,
  toggleUserStatus,
  updateVerification,
} from '../controllers/adminController';
import { authenticateToken, requireRole } from '../middleware/auth';
import { success } from '../utils/response';

const router = Router();

router.use(authenticateToken);
router.use(requireRole('ADMIN'));

router.get('/ping', (_req, res) => {
  success(res, { message: 'Admin access granted' });
});

/**
 * @swagger
 * /api/admin/reindex:
 *   post:
 *     summary: Rebuild Elasticsearch index
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Indexed successfully
 */
router.post('/reindex', reindexAll);

/**
 * @swagger
 * /api/admin/stats:
 *   get:
 *     summary: Get platform statistics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Stats returned
 */
router.get('/stats', getStats);

/**
 * @swagger
 * /api/admin/users:
 *   get:
 *     summary: List all users
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of users
 */
router.get('/users', listUsers);

/**
 * @swagger
 * /api/admin/users/{id}/status:
 *   patch:
 *     summary: Suspend or reactivate a user
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [ACTIVE, SUSPENDED]
 *     responses:
 *       200:
 *         description: Status updated
 */
router.patch('/users/:id/status', toggleUserStatus);

/**
 * @swagger
 * /api/admin/companies:
 *   get:
 *     summary: List all companies
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of companies
 */
router.get('/companies', listCompanies);

/**
 * @swagger
 * /api/admin/companies/{id}/verify:
 *   patch:
 *     summary: Verify or reject a company
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [VERIFIED, REJECTED, PENDING]
 *     responses:
 *       200:
 *         description: Verification updated
 */
router.patch('/companies/:id/verify', updateVerification);

export default router;