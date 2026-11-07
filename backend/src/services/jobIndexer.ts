import { esClient } from '../config/elasticsearch';
import { pool } from '../config/db';
import { JOBS_INDEX, refreshJobsIndex } from './searchIndexService';

interface JobRow {
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
  status: string;
  created_at: Date;
  company_name: string;
  company_logo_url: string | null;
}

function toDocument(row: JobRow) {
  return {
    id: row.id,
    companyId: row.company_id,
    title: row.title,
    description: row.description,
    location: row.location ?? '',
    workingModel: row.working_model,
    jobType: row.job_type,
    experienceLevel: row.experience_level,
    salaryMin: row.salary_min,
    salaryMax: row.salary_max,
    companyName: row.company_name,
    companyLogoUrl: row.company_logo_url,
    status: row.status,
    createdAt: row.created_at,
  };
}

export async function indexOneJob(jobId: number): Promise<void> {
  const result = await pool.query<JobRow>(
    `SELECT j.id, j.company_id, j.title, j.description, j.location,
            j.working_model, j.job_type, j.experience_level,
            j.salary_min, j.salary_max, j.status, j.created_at,
            c.name AS company_name,
            c.logo_url AS company_logo_url
     FROM jobs j
     JOIN companies c ON c.id = j.company_id
     WHERE j.id = $1`,
    [jobId],
  );

  const row = result.rows[0];
  if (!row) {
    console.warn(`[es] Job ${jobId} not found in PostgreSQL; skipping index`);
    return;
  }

  await esClient.index({
    index: JOBS_INDEX,
    id: String(row.id),
    document: toDocument(row),
  });

  await refreshJobsIndex();
}

export async function removeJobFromIndex(jobId: number): Promise<void> {
  try {
    await esClient.delete({
      index: JOBS_INDEX,
      id: String(jobId),
    });
  } catch (error: unknown) {
    const err = error as { meta?: { statusCode?: number } };
    if (err.meta?.statusCode !== 404) {
      throw error;
    }
  }
}

export async function reindexAllJobs(): Promise<number> {
  const result = await pool.query<JobRow>(
    `SELECT j.id, j.company_id, j.title, j.description, j.location,
            j.working_model, j.job_type, j.experience_level,
            j.salary_min, j.salary_max, j.status, j.created_at,
            c.name AS company_name,
            c.logo_url AS company_logo_url
     FROM jobs j
     JOIN companies c ON c.id = j.company_id
     WHERE j.status = 'ACTIVE'`,
  );

  if (result.rows.length === 0) {
    await refreshJobsIndex();
    return 0;
  }

  const operations = result.rows.flatMap((row) => [
    { index: { _index: JOBS_INDEX, _id: String(row.id) } },
    toDocument(row),
  ]);

  const bulkResponse = await esClient.bulk({ operations });

  if (bulkResponse.errors) {
    const failed = bulkResponse.items.filter((item) => item.index?.error);
    console.warn(`[es] Bulk reindex had ${failed.length} failures`);
  }

  await refreshJobsIndex();

  return result.rows.length;
}