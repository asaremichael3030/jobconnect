import { Request, Response, NextFunction } from 'express';

import {
  countApplicationsForJob,
  findApplicationByJobAndUser,
} from '../models/applicationModel';
import { logSearch } from '../models/analyticsModel';
import { findCompanyByOwnerId } from '../models/companyModel';
import {
  createJob,
  findActiveJobs,
  findJobByIdWithCompany,
  findJobsByCompanyId,
  JobRecord,
  JobWithCompany,
  JobDetailWithCompany,
} from '../models/jobModel';
import { isJobSaved } from '../models/savedJobModel';
import { getCached, setCached } from '../services/cacheService';
import { indexOneJob } from '../services/jobIndexer';
import { searchJobsES, SortOption } from '../services/jobSearchService';
import { failure, success } from '../utils/response';

const WORKING_MODELS = ['Remote', 'Hybrid', 'On-Site'];
const JOB_TYPES = ['Full-Time', 'Part-Time', 'Internship', 'Contract'];
const EXPERIENCE_LEVELS = [
  'Internship',
  'Entry Level',
  'Junior',
  'Mid-Level',
  'Senior',
];

const VALID_SORTS: SortOption[] = [
  'Relevance',
  'Newest',
  'Salary: High to Low',
  'Salary: Low to High',
];

function parseOptionalInt(value: unknown): number | undefined {
  if (typeof value !== 'string' || value === '') return undefined;
  const parsed = parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : undefined;
}

function toJobResponse(job: JobRecord) {
  return {
    id: job.id,
    companyId: job.company_id,
    title: job.title,
    description: job.description,
    location: job.location ?? '',
    workingModel: job.working_model,
    jobType: job.job_type,
    experienceLevel: job.experience_level,
    salaryMin: job.salary_min,
    salaryMax: job.salary_max,
    salaryCurrency: job.salary_currency ?? 'USD',
    requirements: job.requirements ?? '',
    responsibilities: job.responsibilities ?? '',
    applicationDeadline: job.application_deadline
      ? job.application_deadline.toISOString().split('T')[0]
      : null,
    status: job.status,
    createdAt: job.created_at,
  };
}

function toJobWithCompanyResponse(job: JobWithCompany) {
  return {
    id: job.id,
    companyId: job.company_id,
    title: job.title,
    description: job.description,
    location: job.location ?? '',
    workingModel: job.working_model,
    jobType: job.job_type,
    experienceLevel: job.experience_level,
    salaryMin: job.salary_min,
    salaryMax: job.salary_max,
    salaryCurrency: job.salary_currency ?? 'USD',
    companyName: job.company_name,
    companyLogoUrl: job.company_logo_url,
    companyLocation: job.company_location ?? '',
    createdAt: job.created_at,
  };
}

function toJobDetailResponse(job: JobDetailWithCompany) {
  return {
    id: job.id,
    companyId: job.company_id,
    title: job.title,
    description: job.description,
    location: job.location ?? '',
    workingModel: job.working_model,
    jobType: job.job_type,
    experienceLevel: job.experience_level,
    salaryMin: job.salary_min,
    salaryMax: job.salary_max,
    salaryCurrency: job.salary_currency ?? 'USD',
    requirements: job.requirements ?? '',
    responsibilities: job.responsibilities ?? '',
    applicationDeadline: job.application_deadline
      ? job.application_deadline.toISOString().split('T')[0]
      : null,
    status: job.status,
    createdAt: job.created_at,
    companyName: job.company_name,
    companyLogoUrl: job.company_logo_url,
    companyLocation: job.company_location ?? '',
    company: {
      name: job.company_name,
      logoUrl: job.company_logo_url,
      location: job.company_location ?? '',
      industry: job.company_industry ?? '',
      companySize: job.company_size ?? '',
      about: job.company_about ?? '',
      website: job.company_website ?? '',
      foundedYear: job.company_founded_year,
      verificationStatus: job.company_verification_status,
    },
  };
}

function validateCreateJob(body: Record<string, unknown>): string | null {
  const {
    title,
    description,
    workingModel,
    jobType,
    experienceLevel,
    salaryMin,
    salaryMax,
  } = body;

  if (!title || typeof title !== 'string' || title.trim().length < 3) {
    return 'Title must be at least 3 characters';
  }
  if (
    !description ||
    typeof description !== 'string' ||
    description.trim().length < 20
  ) {
    return 'Description must be at least 20 characters';
  }
  if (
    !workingModel ||
    typeof workingModel !== 'string' ||
    !WORKING_MODELS.includes(workingModel)
  ) {
    return 'Working model must be Remote, Hybrid, or On-Site';
  }
  if (
    !jobType ||
    typeof jobType !== 'string' ||
    !JOB_TYPES.includes(jobType)
  ) {
    return 'Job type must be Full-Time, Part-Time, Internship, or Contract';
  }
  if (
    !experienceLevel ||
    typeof experienceLevel !== 'string' ||
    !EXPERIENCE_LEVELS.includes(experienceLevel)
  ) {
    return 'Experience level must be Internship, Entry Level, Junior, Mid-Level, or Senior';
  }
  if (
    salaryMin !== undefined &&
    (typeof salaryMin !== 'number' || salaryMin < 0)
  ) {
    return 'Salary minimum must be a positive number';
  }
  if (
    salaryMax !== undefined &&
    (typeof salaryMax !== 'number' || salaryMax < 0)
  ) {
    return 'Salary maximum must be a positive number';
  }
  if (
    typeof salaryMin === 'number' &&
    typeof salaryMax === 'number' &&
    salaryMin > salaryMax
  ) {
    return 'Salary minimum cannot be greater than salary maximum';
  }
  return null;
}

export async function createJobHandler(
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

    const company = await findCompanyByOwnerId(userId);
    if (!company) {
      failure(res, 'Create your company profile before posting jobs', 400);
      return;
    }

    const error = validateCreateJob(req.body ?? {});
    if (error) {
      failure(res, error, 400);
      return;
    }

    const body = req.body ?? {};
    const job = await createJob({
      companyId: company.id,
      title: String(body.title).trim(),
      description: String(body.description).trim(),
      location: typeof body.location === 'string' ? body.location : undefined,
      workingModel: body.workingModel,
      jobType: body.jobType,
      experienceLevel: body.experienceLevel,
      salaryMin:
        typeof body.salaryMin === 'number' ? body.salaryMin : undefined,
      salaryMax:
        typeof body.salaryMax === 'number' ? body.salaryMax : undefined,
      salaryCurrency:
        typeof body.salaryCurrency === 'string'
          ? body.salaryCurrency
          : undefined,
      requirements:
        typeof body.requirements === 'string' ? body.requirements : undefined,
      responsibilities:
        typeof body.responsibilities === 'string'
          ? body.responsibilities
          : undefined,
      applicationDeadline:
        typeof body.applicationDeadline === 'string'
          ? body.applicationDeadline
          : undefined,
    });

    success(res, { job: toJobResponse(job) }, 201);

    try {
      await indexOneJob(job.id);
    } catch (indexError) {
      console.error(
        '[search] Failed to index new job:',
        indexError instanceof Error ? indexError.message : indexError,
      );
    }
  } catch (error) {
    next(error);
  }
}

export async function getMyJobs(
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

    const company = await findCompanyByOwnerId(userId);
    if (!company) {
      success(res, { jobs: [] });
      return;
    }

    const jobs = await findJobsByCompanyId(company.id);
    success(res, { jobs: jobs.map(toJobResponse) });
  } catch (error) {
    next(error);
  }
}

export async function listJobs(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const startTime = Date.now();
  try {
    const search = typeof req.query.q === 'string' ? req.query.q.trim() : '';
    const location =
      typeof req.query.location === 'string' ? req.query.location : '';
    const workingModel =
      typeof req.query.workingModel === 'string'
        ? req.query.workingModel
        : '';
    const jobType =
      typeof req.query.jobType === 'string' ? req.query.jobType : '';
    const experienceLevel =
      typeof req.query.experienceLevel === 'string'
        ? req.query.experienceLevel
        : '';
    const company =
      typeof req.query.company === 'string' ? req.query.company.trim() : '';
    const postedAfter =
      typeof req.query.postedAfter === 'string' ? req.query.postedAfter : '';

    const salaryMin = parseOptionalInt(req.query.salaryMin);
    const salaryMax = parseOptionalInt(req.query.salaryMax);

    const sortRaw =
      typeof req.query.sort === 'string' ? req.query.sort : 'Relevance';
    const sort: SortOption = VALID_SORTS.includes(sortRaw as SortOption)
      ? (sortRaw as SortOption)
      : 'Relevance';

    const page = Math.max(1, parseInt(String(req.query.page ?? '1'), 10) || 1);
    const limit = Math.min(
      50,
      Math.max(1, parseInt(String(req.query.limit ?? '20'), 10) || 20),
    );

    const cacheKey = `search:q=${search}:loc=${location}:wm=${workingModel}:jt=${jobType}:exp=${experienceLevel}:smin=${salaryMin}:smax=${salaryMax}:co=${company}:pa=${postedAfter}:sort=${sort}:page=${page}:limit=${limit}`;

    if (search) {
      const cachedData = await getCached<{
        jobs: unknown[];
        total: number;
        page: number;
        limit: number;
      }>(cacheKey);

      if (cachedData) {
        const latency = Date.now() - startTime;
        logSearch({
          userId: req.user?.id,
          query: search,
          resultCount: cachedData.total,
          latencyMs: latency,
          cacheHit: true,
        }).catch((err) => console.error('[analytics] Failed to log cache hit:', err));

        success(res, cachedData);
        return;
      }
    }

    if (search) {
      try {
        const esResult = await searchJobsES({
          query: search,
          location: location || undefined,
          workingModel: workingModel || undefined,
          jobType: jobType || undefined,
          experienceLevel: experienceLevel || undefined,
          salaryMin,
          salaryMax,
          company: company || undefined,
          postedAfter: postedAfter || undefined,
          sort,
          page,
          limit,
        });

        const mapped = esResult.jobs.map((j) => ({
          id: j.id,
          companyId: j.companyId,
          title: j.title,
          description: j.description,
          location: j.location,
          workingModel: j.workingModel,
          jobType: j.jobType,
          experienceLevel: j.experienceLevel,
          salaryMin: j.salaryMin,
          salaryMax: j.salaryMax,
          salaryCurrency: 'USD',
          companyName: j.companyName,
          companyLogoUrl: j.companyLogoUrl,
          companyLocation: '',
          createdAt: j.createdAt,
          matchScore: j.matchScore,
        }));

        const responsePayload = {
          jobs: mapped,
          total: esResult.total,
          page,
          limit,
        };

        await setCached(cacheKey, responsePayload, 60);

        const latency = Date.now() - startTime;
        logSearch({
          userId: req.user?.id,
          query: search,
          resultCount: esResult.total,
          latencyMs: latency,
          cacheHit: false,
        }).catch((err) => console.error('[analytics] Failed to log ES search:', err));

        success(res, responsePayload);
        return;
      } catch (esError) {
        console.error(
          '[search] Elasticsearch failed; falling back to SQL:',
          esError instanceof Error ? esError.message : esError,
        );
      }
    }

    const { jobs, total } = await findActiveJobs({
      search: search || undefined,
      location: location || undefined,
      workingModel: workingModel || undefined,
      jobType: jobType || undefined,
      experienceLevel: experienceLevel || undefined,
      salaryMin,
      salaryMax,
      company: company || undefined,
      postedAfter: postedAfter || undefined,
      sort,
      page,
      limit,
    });

    success(res, {
      jobs: jobs.map(toJobWithCompanyResponse),
      total,
      page,
      limit,
    });
  } catch (error) {
    next(error);
  }
}

export async function getJobById(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
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

    const applicantCount = await countApplicationsForJob(jobId);

    let hasApplied = false;
    let hasSaved = false;
    if (req.user && req.user.role === 'JOB_SEEKER') {
      const existing = await findApplicationByJobAndUser(jobId, req.user.id);
      hasApplied = existing !== null;
      hasSaved = await isJobSaved(req.user.id, jobId);
    }

    const response = toJobDetailResponse(job);
    success(res, {
      job: {
        ...response,
        applicantCount,
        hasApplied,
        hasSaved,
      },
    });
  } catch (error) {
    next(error);
  }
}