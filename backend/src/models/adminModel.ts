import { pool } from '../config/db';

export interface AdminStats {
  totalUsers: number;
  totalCompanies: number;
  totalJobs: number;
  totalApplications: number;
  pendingReports: number;
}

export async function getAdminStats(): Promise<AdminStats> {
  const users = await pool.query<{ count: string }>('SELECT COUNT(*)::text AS count FROM users');
  const companies = await pool.query<{ count: string }>('SELECT COUNT(*)::text AS count FROM companies');
  const jobs = await pool.query<{ count: string }>('SELECT COUNT(*)::text AS count FROM jobs');
  const apps = await pool.query<{ count: string }>('SELECT COUNT(*)::text AS count FROM applications');
  const reports = await pool.query<{ count: string }>("SELECT COUNT(*)::text AS count FROM reports WHERE status = 'PENDING'");

  return {
    totalUsers: parseInt(users.rows[0]?.count ?? '0', 10),
    totalCompanies: parseInt(companies.rows[0]?.count ?? '0', 10),
    totalJobs: parseInt(jobs.rows[0]?.count ?? '0', 10),
    totalApplications: parseInt(apps.rows[0]?.count ?? '0', 10),
    pendingReports: parseInt(reports.rows[0]?.count ?? '0', 10),
  };
}

export interface AdminUserRecord {
  id: number;
  name: string;
  email: string;
  role: string;
  status: string;
  created_at: Date;
}

export async function getAllUsers(): Promise<AdminUserRecord[]> {
  const result = await pool.query<AdminUserRecord>(
    'SELECT id, name, email, role, status, created_at FROM users ORDER BY created_at DESC',
  );
  return result.rows;
}

export async function updateUserStatus(
  userId: number,
  status: 'ACTIVE' | 'SUSPENDED',
): Promise<boolean> {
  const result = await pool.query(
    'UPDATE users SET status = $1, updated_at = NOW() WHERE id = $2',
    [status, userId],
  );
  return (result.rowCount ?? 0) > 0;
}

export interface AdminCompanyRecord {
  id: number;
  name: string;
  industry: string | null;
  verification_status: string;
  created_at: Date;
  owner_email: string;
}

export async function getAllCompanies(): Promise<AdminCompanyRecord[]> {
  const result = await pool.query<AdminCompanyRecord>(
    `SELECT c.id, c.name, c.industry, c.verification_status, c.created_at,
            u.email AS owner_email
     FROM companies c
     JOIN users u ON u.id = c.owner_id
     ORDER BY c.created_at DESC`,
  );
  return result.rows;
}

export async function updateCompanyVerification(
  companyId: number,
  status: 'VERIFIED' | 'REJECTED' | 'PENDING',
): Promise<boolean> {
  const result = await pool.query(
    'UPDATE companies SET verification_status = $1, updated_at = NOW() WHERE id = $2',
    [status, companyId],
  );
  return (result.rowCount ?? 0) > 0;
}