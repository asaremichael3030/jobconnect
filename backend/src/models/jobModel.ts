import { pool } from '../config/db';
import type { SortOption } from '../services/jobSearchService';

export interface JobRecord {
  id: number;
  company_id: number;
  title: string;
  description: string;
  location: string | null;
  working_model: string;
  job_type: string;
  experience_level: string;
  salary_min: number | null;
  salary_max: number | null;
  salary_currency: string | null;
  requirements: string | null;
  responsibilities: string | null;
  application_deadline: Date | null;
  status: string;
  created_at: Date;
  updated_at: Date;
}

export interface JobWithCompany {
  id: number;
  company_id: number;
  title: string;
  description: string;
  location: string | null;
  working_model: string;
  job_type: string;
  experience_level: string;
  salary_min: number | null;
  salary_max: number | null;
  salary_currency: string | null;
  status: string;
  created_at: Date;
  company_name: string;
  company_logo_url: string | null;
  company_location: string | null;
}

export interface JobDetailWithCompany {
  id: number;
  company_id: number;
  title: string;
  description: string;
  location: string | null;
  working_model: string;
  job_type: string;
  experience_level: string;
  salary_min: number | null;
  salary_max: number | null;
  salary_currency: string | null;
  requirements: string | null;
  responsibilities: string | null;
  application_deadline: Date | null;
  status: string;
  created_at: Date;
  company_name: string;
  company_logo_url: string | null;
  company_location: string | null;
  company_industry: string | null;
  company_size: string | null;
  company_about: string | null;
  company_website: string | null;
  company_founded_year: number | null;
  company_verification_status: string;
}

export interface CreateJobFields {
  companyId: number;
  title: string;
  description: string;
  location?: string;
  workingModel: string;
  jobType: string;
  experienceLevel: string;
  salaryMin?: number;
  salaryMax?: number;
  salaryCurrency?: string;
  requirements?: string;
  responsibilities?: string;
  applicationDeadline?: string;
}

export interface ListJobsOptions {
  search?: string;
  location?: string;
  workingModel?: string;
  jobType?: string;
  experienceLevel?: string;
  salaryMin?: number;
  salaryMax?: number;
  company?: string;
  postedAfter?: string;
  sort?: SortOption;
  page: number;
  limit: number;
}

export async function createJob(fields: CreateJobFields): Promise<JobRecord> {
  const result = await pool.query<JobRecord>(
    `INSERT INTO jobs (
       company_id, title, description, location, working_model,
       job_type, experience_level, salary_min, salary_max, salary_currency,
       requirements, responsibilities, application_deadline, status
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'ACTIVE')
     RETURNING *`,
    [
      fields.companyId,
      fields.title,
      fields.description,
      fields.location ?? null,
      fields.workingModel,
      fields.jobType,
      fields.experienceLevel,
      fields.salaryMin ?? null,
      fields.salaryMax ?? null,
      fields.salaryCurrency ?? 'USD',
      fields.requirements ?? null,
      fields.responsibilities ?? null,
      fields.applicationDeadline ?? null,
    ],
  );
  return result.rows[0];
}

export async function findJobsByCompanyId(
  companyId: number,
): Promise<JobRecord[]> {
  const result = await pool.query<JobRecord>(
    `SELECT * FROM jobs
     WHERE company_id = $1 AND status != 'REMOVED'
     ORDER BY created_at DESC`,
    [companyId],
  );
  return result.rows;
}

function sqlSortClause(
  sort: SortOption | undefined,
  _hasSearch: boolean,
): string {
  switch (sort) {
    case 'Newest':
      return 'ORDER BY j.created_at DESC';
    case 'Salary: High to Low':
      return 'ORDER BY j.salary_max DESC NULLS LAST, j.created_at DESC';
    case 'Salary: Low to High':
      return 'ORDER BY j.salary_min ASC NULLS LAST, j.created_at DESC';
    case 'Relevance':
    default:
      return 'ORDER BY j.created_at DESC';
  }
}

export async function findActiveJobs(
  options: ListJobsOptions,
): Promise<{ jobs: JobWithCompany[]; total: number }> {
  const conditions: string[] = ["j.status = 'ACTIVE'"];
  const values: unknown[] = [];

  if (options.search) {
    values.push(`%${options.search.toLowerCase()}%`);
    conditions.push(
      `(LOWER(j.title) LIKE $${values.length} OR LOWER(j.description) LIKE $${values.length} OR LOWER(c.name) LIKE $${values.length})`,
    );
  }

  if (options.location) {
    values.push(options.location);
    conditions.push(`j.location = $${values.length}`);
  }

  if (options.workingModel) {
    values.push(options.workingModel);
    conditions.push(`j.working_model = $${values.length}`);
  }

  if (options.jobType) {
    values.push(options.jobType);
    conditions.push(`j.job_type = $${values.length}`);
  }

  if (options.experienceLevel) {
    values.push(options.experienceLevel);
    conditions.push(`j.experience_level = $${values.length}`);
  }

  if (options.salaryMin !== undefined) {
    values.push(options.salaryMin);
    conditions.push(`j.salary_max >= $${values.length}`);
  }

  if (options.salaryMax !== undefined) {
    values.push(options.salaryMax);
    conditions.push(`j.salary_min <= $${values.length}`);
  }

  if (options.company) {
    values.push(`%${options.company.toLowerCase()}%`);
    conditions.push(`LOWER(c.name) LIKE $${values.length}`);
  }

  if (options.postedAfter) {
    values.push(options.postedAfter);
    conditions.push(`j.created_at >= $${values.length}`);
  }

  const whereClause = conditions.join(' AND ');

  const countResult = await pool.query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM jobs j
     JOIN companies c ON c.id = j.company_id
     WHERE ${whereClause}`,
    values,
  );
  const total = parseInt(countResult.rows[0]?.count ?? '0', 10);

  const offset = (options.page - 1) * options.limit;
  values.push(options.limit, offset);

  const listResult = await pool.query<JobWithCompany>(
    `SELECT j.id, j.company_id, j.title, j.description, j.location,
            j.working_model, j.job_type, j.experience_level,
            j.salary_min, j.salary_max, j.salary_currency, j.status,
            j.created_at,
            c.name AS company_name,
            c.logo_url AS company_logo_url,
            c.location AS company_location
     FROM jobs j
     JOIN companies c ON c.id = j.company_id
     WHERE ${whereClause}
     ${sqlSortClause(options.sort, Boolean(options.search))}
     LIMIT $${values.length - 1} OFFSET $${values.length}`,
    values,
  );

  return { jobs: listResult.rows, total };
}

export async function findJobByIdWithCompany(
  id: number,
): Promise<JobDetailWithCompany | null> {
  const result = await pool.query<JobDetailWithCompany>(
    `SELECT j.id, j.company_id, j.title, j.description, j.location,
            j.working_model, j.job_type, j.experience_level,
            j.salary_min, j.salary_max, j.salary_currency,
            j.requirements, j.responsibilities, j.application_deadline,
            j.status, j.created_at,
            c.name AS company_name,
            c.logo_url AS company_logo_url,
            c.location AS company_location,
            c.industry AS company_industry,
            c.company_size AS company_size,
            c.about AS company_about,
            c.website AS company_website,
            c.founded_year AS company_founded_year,
            c.verification_status AS company_verification_status
     FROM jobs j
     JOIN companies c ON c.id = j.company_id
     WHERE j.id = $1 AND j.status != 'REMOVED'`,
    [id],
  );
  return result.rows[0] ?? null;
}