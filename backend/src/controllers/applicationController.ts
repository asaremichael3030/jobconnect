import { Request, Response, NextFunction } from 'express';

import {
  createApplication,
  findApplicationByJobAndUser,
  findApplicationById,
  findApplicationsByUser,
  findApplicationsForJob,
  updateApplicationStatus,
  ApplicationForEmployer,
  ApplicationForSeeker,
} from '../models/applicationModel';
import { findCompanyByOwnerId } from '../models/companyModel';
import { findJobByIdWithCompany } from '../models/jobModel';
import { findUserById } from '../models/userModel';
import {
  notifyApplicationStatus,
  notifyNewApplication,
} from '../services/notificationService';
import { failure, success } from '../utils/response';

const VALID_STATUSES = [
  'APPLIED',
  'REVIEWING',
  'SHORTLISTED',
  'INTERVIEW',
  'REJECTED',
  'HIRED',
];

function toSeekerApplication(a: ApplicationForSeeker) {
  return {
    id: a.id,
    jobId: a.job_id,
    status: a.status,
    appliedAt: a.created_at,
    job: {
      title: a.job_title,
      jobType: a.job_type,
      workingModel: a.working_model,
      location: a.location ?? '',
      companyId: a.company_id,
      companyName: a.company_name,
      companyLogoUrl: a.company_logo_url,
    },
  };
}

function toEmployerApplication(a: ApplicationForEmployer) {
  return {
    id: a.id,
    jobId: a.job_id,
    userId: a.user_id,
    status: a.status,
    coverLetter: a.cover_letter ?? '',
    resumeUrl: a.resume_url,
    appliedAt: a.created_at,
    applicant: {
      name: a.applicant_name,
      email: a.applicant_email,
      avatarUrl: a.applicant_avatar_url,
      headline: a.applicant_headline ?? '',
      location: a.applicant_location ?? '',
    },
  };
}

export async function applyToJob(
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

    if (req.user?.role !== 'JOB_SEEKER') {
      failure(res, 'Only job seekers can apply to jobs', 403);
      return;
    }

    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const jobId = parseInt(idString, 10);

    if (!Number.isInteger(jobId) || jobId < 1) {
      failure(res, 'Invalid job id', 400);
      return;
    }

    const job = await findJobByIdWithCompany(jobId);
    if (!job) {
      failure(res, 'Job not found', 404);
      return;
    }

    if (job.status !== 'ACTIVE') {
      failure(res, 'This job is no longer accepting applications', 400);
      return;
    }

    const existing = await findApplicationByJobAndUser(jobId, userId);
    if (existing) {
      failure(res, 'You have already applied to this job', 409);
      return;
    }

    const coverLetter =
      typeof req.body?.coverLetter === 'string'
        ? req.body.coverLetter.trim()
        : undefined;

    const application = await createApplication(
      jobId,
      userId,
      coverLetter && coverLetter.length > 0 ? coverLetter : undefined,
    );

    success(
      res,
      {
        application: {
          id: application.id,
          jobId: application.job_id,
          status: application.status,
          appliedAt: application.created_at,
        },
      },
      201,
    );

    const applicant = await findUserById(userId);
    if (applicant) {
      await notifyNewApplication(
        job.company_id,
        applicant.name,
        job.title,
        application.id,
      );
    }
  } catch (error) {
    next(error);
  }
}

export async function getMyApplications(
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

    const rows = await findApplicationsByUser(userId);
    success(res, { applications: rows.map(toSeekerApplication) });
  } catch (error) {
    next(error);
  }
}

export async function getJobApplications(
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

    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const jobId = parseInt(idString, 10);

    if (!Number.isInteger(jobId) || jobId < 1) {
      failure(res, 'Invalid job id', 400);
      return;
    }

    const job = await findJobByIdWithCompany(jobId);
    if (!job) {
      failure(res, 'Job not found', 404);
      return;
    }

    const company = await findCompanyByOwnerId(userId);
    if (!company || company.id !== job.company_id) {
      failure(
        res,
        'You do not have permission to view these applications',
        403,
      );
      return;
    }

    const applications = await findApplicationsForJob(jobId);
    success(res, {
      applications: applications.map(toEmployerApplication),
    });
  } catch (error) {
    next(error);
  }
}

export async function updateApplicationStatusHandler(
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

    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const applicationId = parseInt(idString, 10);

    if (!Number.isInteger(applicationId) || applicationId < 1) {
      failure(res, 'Invalid application id', 400);
      return;
    }

    const { status } = req.body ?? {};
    if (typeof status !== 'string' || !VALID_STATUSES.includes(status)) {
      failure(
        res,
        `Status must be one of: ${VALID_STATUSES.join(', ')}`,
        400,
      );
      return;
    }

    const application = await findApplicationById(applicationId);
    if (!application) {
      failure(res, 'Application not found', 404);
      return;
    }

    const job = await findJobByIdWithCompany(application.job_id);
    if (!job) {
      failure(res, 'Job not found', 404);
      return;
    }

    const company = await findCompanyByOwnerId(userId);
    if (!company || company.id !== job.company_id) {
      failure(
        res,
        'You do not have permission to update this application',
        403,
      );
      return;
    }

    await updateApplicationStatus(applicationId, status);

    await notifyApplicationStatus(
      application.user_id,
      application.job_id,
      status,
      applicationId,
    );

    success(res, {
      application: {
        id: application.id,
        status,
      },
    });
  } catch (error) {
    next(error);
  }
}