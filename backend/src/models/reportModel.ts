import { pool } from '../config/db';

export interface ReportRecord {
  id: number;
  reporter_id: number;
  target_type: string;
  target_id: number;
  reason: string;
  status: string;
  created_at: Date;
  reporter_name: string;
  target_name: string;
}

export async function createReport(
  reporterId: number,
  targetType: 'JOB' | 'COMPANY' | 'USER',
  targetId: number,
  reason: string,
): Promise<void> {
  await pool.query(
    `INSERT INTO reports (reporter_id, target_type, target_id, reason)
     VALUES ($1, $2, $3, $4)`,
    [reporterId, targetType, targetId, reason],
  );
}

export async function getReports(): Promise<ReportRecord[]> {
  const result = await pool.query<ReportRecord>(
    `SELECT r.id, r.reporter_id, r.target_type, r.target_id, r.reason, r.status, r.created_at,
            u.name AS reporter_name,
            CASE 
              WHEN r.target_type = 'JOB' THEN j.title
              WHEN r.target_type = 'COMPANY' THEN c.name
              WHEN r.target_type = 'USER' THEN tu.name
              ELSE 'Unknown'
            END AS target_name
     FROM reports r
     JOIN users u ON u.id = r.reporter_id
     LEFT JOIN jobs j ON r.target_type = 'JOB' AND j.id = r.target_id
     LEFT JOIN companies c ON r.target_type = 'COMPANY' AND c.id = r.target_id
     LEFT JOIN users tu ON r.target_type = 'USER' AND tu.id = r.target_id
     ORDER BY r.created_at DESC`,
  );
  return result.rows;
}

export async function updateReportStatus(
  reportId: number,
  status: 'PENDING' | 'REVIEWED' | 'RESOLVED',
): Promise<boolean> {
  const result = await pool.query(
    'UPDATE reports SET status = $1 WHERE id = $2',
    [status, reportId],
  );
  return (result.rowCount ?? 0) > 0;
}