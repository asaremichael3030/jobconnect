import { pool } from '../config/db';

export interface ApplicationRecord {
  id: number;
  job_id: number;
  user_id: number;
  status: string;
  cover_letter: string | null;
  resume_url: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface ApplicationForSeeker {
  id: number;
  job_id: number;
  status: string;
  created_at: Date;
  job_title: string;
  job_type: string;
  working_model: string;
  location: string | null;
  company_id: number;
  company_name: string;
  company_logo_url: string | null;
}

export interface ApplicationForEmployer {
  id: number;
  job_id: number;
  user_id: number;
  status: string;
  cover_letter: string | null;
  resume_url: string | null;
  created_at: Date;
  applicant_name: string;
  applicant_email: string;
  applicant_avatar_url: string | null;
  applicant_headline: string | null;
  applicant_location: string | null;
}

export async function findApplicationByJobAndUser(
  jobId: number,
  userId: number,
): Promise<ApplicationRecord | null> {
  const result = await pool.query<ApplicationRecord>(
    'SELECT * FROM applications WHERE job_id = $1 AND user_id = $2',
    [jobId, userId],
  );
  return result.rows[0] ?? null;
}

export async function findApplicationById(
  id: number,
): Promise<ApplicationRecord | null> {
  const result = await pool.query<ApplicationRecord>(
    'SELECT * FROM applications WHERE id = $1',
    [id],
  );
  return result.rows[0] ?? null;
}

export async function createApplication(
  jobId: number,
  userId: number,
  coverLetter?: string,
  resumeUrl?: string,
): Promise<ApplicationRecord> {
  const result = await pool.query<ApplicationRecord>(
    `INSERT INTO applications (job_id, user_id, cover_letter, resume_url, status)
     VALUES ($1, $2, $3, $4, 'APPLIED')
     RETURNING *`,
    [jobId, userId, coverLetter ?? null, resumeUrl ?? null],
  );
  return result.rows[0];
}

export async function findApplicationsByUser(
  userId: number,
): Promise<ApplicationForSeeker[]> {
  const result = await pool.query<ApplicationForSeeker>(
    `SELECT a.id, a.job_id, a.status, a.created_at,
            j.title AS job_title, j.job_type, j.working_model, j.location,
            j.company_id,
            c.name AS company_name,
            c.logo_url AS company_logo_url
     FROM applications a
     JOIN jobs j ON j.id = a.job_id
     JOIN companies c ON c.id = j.company_id
     WHERE a.user_id = $1
     ORDER BY a.created_at DESC`,
    [userId],
  );
  return result.rows;
}

export async function findApplicationsForJob(
  jobId: number,
): Promise<ApplicationForEmployer[]> {
  const result = await pool.query<ApplicationForEmployer>(
    `SELECT a.id, a.job_id, a.user_id, a.status, a.cover_letter,
            COALESCE(a.resume_url, p.resume_url) AS resume_url, 
            a.created_at,
            u.name AS applicant_name,
            u.email AS applicant_email,
            p.profile_picture_url AS applicant_avatar_url,
            p.headline AS applicant_headline,
            p.location AS applicant_location
     FROM applications a
     JOIN users u ON u.id = a.user_id
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE a.job_id = $1
     ORDER BY a.created_at DESC`,
    [jobId],
  );
  return result.rows;
}

export async function updateApplicationStatus(
  id: number,
  status: string,
): Promise<void> {
  await pool.query(
    'UPDATE applications SET status = $1, updated_at = NOW() WHERE id = $2',
    [status, id],
  );
}

export async function countApplicationsForJob(jobId: number): Promise<number> {
  const result = await pool.query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM applications WHERE job_id = $1',
    [jobId],
  );
  return parseInt(result.rows[0]?.count ?? '0', 10);
}