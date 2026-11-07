import { Request, Response, NextFunction } from 'express';

import { createReport, getReports, updateReportStatus } from '../models/reportModel';
import { failure, success } from '../utils/response';

export async function submitReport(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const { targetType, targetId, reason } = req.body ?? {};

    if (!['JOB', 'COMPANY', 'USER'].includes(targetType)) {
      failure(res, 'Invalid target type', 400);
      return;
    }

    if (typeof targetId !== 'number' || targetId < 1) {
      failure(res, 'Invalid target ID', 400);
      return;
    }

    if (!reason || typeof reason !== 'string' || reason.trim().length < 10) {
      failure(res, 'Reason must be at least 10 characters', 400);
      return;
    }

    await createReport(userId, targetType, targetId, reason.trim());

    success(res, { message: 'Report submitted successfully' }, 201);
  } catch (error) {
    next(error);
  }
}

export async function listReports(
  _req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const reports = await getReports();
    success(res, {
      reports: reports.map((r) => ({
        id: r.id,
        reporterName: r.reporter_name,
        targetType: r.target_type,
        targetId: r.target_id,
        targetName: r.target_name,
        reason: r.reason,
        status: r.status,
        createdAt: r.created_at,
      })),
    });
  } catch (error) {
    next(error);
  }
}

export async function resolveReport(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const reportId = parseInt(idString, 10);

    if (!Number.isInteger(reportId) || reportId < 1) {
      failure(res, 'Invalid report id', 400);
      return;
    }

    const { status } = req.body ?? {};
    if (!['PENDING', 'REVIEWED', 'RESOLVED'].includes(status)) {
      failure(res, 'Invalid status', 400);
      return;
    }

    const updated = await updateReportStatus(reportId, status);
    if (!updated) {
      failure(res, 'Report not found', 404);
      return;
    }

    success(res, { message: `Report marked as ${status}` });
  } catch (error) {
    next(error);
  }
}