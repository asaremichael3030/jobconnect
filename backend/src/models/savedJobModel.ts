import { pool } from '../config/db';

export interface SavedJobRecord {
  id: number;
  user_id: number;
  job_id: number;
  created_at: Date;
}

export interface SavedJobWithJob {
  id: number;
  saved_at: Date;
  job_id: number;
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
  company_id: number;
  company_name: string;
  company_logo_url: string | null;
}

export async function isJobSaved(
  userId: number,
  jobId: number,
): Promise<boolean> {
  const result = await pool.query(
    'SELECT 1 FROM saved_jobs WHERE user_id = $1 AND job_id = $2 LIMIT 1',
    [userId, jobId],
  );
  return result.rowCount !== null && result.rowCount > 0;
}

export async function saveJob(
  userId: number,
  jobId: number,
): Promise<void> {
  await pool.query(
    `INSERT INTO saved_jobs (user_id, job_id)
     VALUES ($1, $2)
     ON CONFLICT (user_id, job_id) DO NOTHING`,
    [userId, jobId],
  );
}

export async function unsaveJob(
  userId: number,
  jobId: number,
): Promise<void> {
  await pool.query(
    'DELETE FROM saved_jobs WHERE user_id = $1 AND job_id = $2',
    [userId, jobId],
  );
}

export async function findSavedJobsByUser(
  userId: number,
): Promise<SavedJobWithJob[]> {
  const result = await pool.query<SavedJobWithJob>(
    `SELECT s.id, s.created_at AS saved_at, s.job_id,
            j.title, j.description, j.location, j.working_model,
            j.job_type, j.experience_level,
            j.salary_min, j.salary_max, j.salary_currency, j.status,
            j.company_id,
            c.name AS company_name,
            c.logo_url AS company_logo_url
     FROM saved_jobs s
     JOIN jobs j ON j.id = s.job_id
     JOIN companies c ON c.id = j.company_id
     WHERE s.user_id = $1 AND j.status != 'REMOVED'
     ORDER BY s.created_at DESC`,
    [userId],
  );
  return result.rows;
}

export async function countSavedJobsForUser(
  userId: number,
): Promise<number> {
  const result = await pool.query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM saved_jobs WHERE user_id = $1',
    [userId],
  );
  return parseInt(result.rows[0]?.count ?? '0', 10);
}