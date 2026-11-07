import { pool } from '../config/db';

export interface NotificationRecord {
  id: number;
  user_id: number;
  title: string;
  message: string;
  type: string;
  related_id: number | null;
  is_read: boolean;
  created_at: Date;
}

export interface CreateNotificationFields {
  userId: number;
  title: string;
  message: string;
  type: string;
  relatedId?: number;
}

export async function createNotification(
  fields: CreateNotificationFields,
): Promise<NotificationRecord> {
  const result = await pool.query<NotificationRecord>(
    `INSERT INTO notifications (user_id, title, message, type, related_id)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [
      fields.userId,
      fields.title,
      fields.message,
      fields.type,
      fields.relatedId ?? null,
    ],
  );
  return result.rows[0];
}

export async function findNotificationsByUser(
  userId: number,
  limit = 50,
): Promise<NotificationRecord[]> {
  const result = await pool.query<NotificationRecord>(
    `SELECT * FROM notifications
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
    [userId, limit],
  );
  return result.rows;
}

export async function countUnreadForUser(userId: number): Promise<number> {
  const result = await pool.query<{ count: string }>(
    `SELECT COUNT(*)::text AS count
     FROM notifications
     WHERE user_id = $1 AND is_read = FALSE`,
    [userId],
  );
  return parseInt(result.rows[0]?.count ?? '0', 10);
}

export async function markNotificationRead(
  notificationId: number,
  userId: number,
): Promise<boolean> {
  const result = await pool.query(
    `UPDATE notifications
     SET is_read = TRUE
     WHERE id = $1 AND user_id = $2`,
    [notificationId, userId],
  );
  return (result.rowCount ?? 0) > 0;
}

export async function markAllRead(userId: number): Promise<void> {
  await pool.query(
    'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE',
    [userId],
  );
}