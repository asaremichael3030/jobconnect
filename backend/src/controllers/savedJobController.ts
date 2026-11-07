import { Request, Response, NextFunction } from 'express';

import { findJobByIdWithCompany } from '../models/jobModel';
import {
  findSavedJobsByUser,
  saveJob,
  unsaveJob,
  SavedJobWithJob,
} from '../models/savedJobModel';
import { failure, success } from '../utils/response';

function toSavedJobResponse(row: SavedJobWithJob) {
  return {
    id: row.id,
    savedAt: row.saved_at,
    jobId: row.job_id,
    title: row.title,
    description: row.description,
    location: row.location ?? '',
    workingModel: row.working_model,
    jobType: row.job_type,
    experienceLevel: row.experience_level,
    salaryMin: row.salary_min,
    salaryMax: row.salary_max,
    salaryCurrency: row.salary_currency ?? 'USD',
    status: row.status,
    companyId: row.company_id,
    companyName: row.company_name,
    companyLogoUrl: row.company_logo_url,
  };
}

function parseJobId(req: Request): number | null {
  const idParam = req.params.id;
  const idString = Array.isArray(idParam) ? idParam[0] : idParam;
  const jobId = parseInt(idString, 10);
  if (!Number.isInteger(jobId) || jobId < 1) return null;
  return jobId;
}

export async function saveJobHandler(
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

    const jobId = parseJobId(req);
    if (jobId === null) {
      failure(res, 'Invalid job id', 400);
      return;
    }

    const job = await findJobByIdWithCompany(jobId);
    if (!job) {
      failure(res, 'Job not found', 404);
      return;
    }

    await saveJob(userId, jobId);

    success(res, { saved: true, jobId });
  } catch (error) {
    next(error);
  }
}

export async function unsaveJobHandler(
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

    const jobId = parseJobId(req);
    if (jobId === null) {
      failure(res, 'Invalid job id', 400);
      return;
    }

    await unsaveJob(userId, jobId);

    success(res, { saved: false, jobId });
  } catch (error) {
    next(error);
  }
}

export async function listSavedJobs(
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

    const rows = await findSavedJobsByUser(userId);

    success(res, {
      savedJobs: rows.map(toSavedJobResponse),
    });
  } catch (error) {
    next(error);
  }
}