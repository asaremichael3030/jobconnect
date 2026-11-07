import { Request, Response, NextFunction } from 'express';

import {
  getAllCompanies,
  getAllUsers,
  getAdminStats,
  updateCompanyVerification,
  updateUserStatus,
} from '../models/adminModel';
import { ensureJobsIndex } from '../services/searchIndexService';
import { reindexAllJobs } from '../services/jobIndexer';
import { success, failure } from '../utils/response';

export async function reindexAll(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await ensureJobsIndex();
    const count = await reindexAllJobs();
    success(res, { indexed: count });
  } catch (error) {
    next(error);
  }
}

export async function getStats(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const stats = await getAdminStats();
    success(res, stats);
  } catch (error) {
    next(error);
  }
}

export async function listUsers(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const users = await getAllUsers();
    success(res, {
      users: users.map((u) => ({
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role,
        status: u.status,
        createdAt: u.created_at,
      })),
    });
  } catch (error) {
    next(error);
  }
}

export async function toggleUserStatus(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const userId = parseInt(idString, 10);

    if (!Number.isInteger(userId) || userId < 1) {
      failure(res, 'Invalid user id', 400);
      return;
    }

    const { status } = req.body ?? {};
    if (status !== 'ACTIVE' && status !== 'SUSPENDED') {
      failure(res, 'Status must be ACTIVE or SUSPENDED', 400);
      return;
    }

    const updated = await updateUserStatus(userId, status);
    if (!updated) {
      failure(res, 'User not found', 404);
      return;
    }

    success(res, { message: `User marked as ${status}` });
  } catch (error) {
    next(error);
  }
}

export async function listCompanies(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const companies = await getAllCompanies();
    success(res, {
      companies: companies.map((c) => ({
        id: c.id,
        name: c.name,
        industry: c.industry ?? '',
        verificationStatus: c.verification_status,
        createdAt: c.created_at,
        ownerEmail: c.owner_email,
      })),
    });
  } catch (error) {
    next(error);
  }
}

export async function updateVerification(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const companyId = parseInt(idString, 10);

    if (!Number.isInteger(companyId) || companyId < 1) {
      failure(res, 'Invalid company id', 400);
      return;
    }

    const { status } = req.body ?? {};
    if (!['VERIFIED', 'REJECTED', 'PENDING'].includes(status)) {
      failure(res, 'Invalid verification status', 400);
      return;
    }

    const updated = await updateCompanyVerification(companyId, status);
    if (!updated) {
      failure(res, 'Company not found', 404);
      return;
    }

    success(res, { message: `Company marked as ${status}` });
  } catch (error) {
    next(error);
  }
}