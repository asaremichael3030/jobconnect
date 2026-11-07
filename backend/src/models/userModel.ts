import { pool } from '../config/db';

export interface NewUser {
  name: string;
  email: string;
  passwordHash: string;
  role: 'JOB_SEEKER' | 'EMPLOYER' | 'ADMIN';
}

export interface UserRecord {
  id: number;
  name: string;
  email: string;
  password_hash: string;
  role: string;
  status: string;
  created_at: Date;
  updated_at: Date;
}

export async function findUserByEmail(
  email: string,
): Promise<UserRecord | null> {
  const result = await pool.query<UserRecord>(
    'SELECT * FROM users WHERE email = $1',
    [email],
  );
  return result.rows[0] ?? null;
}

export async function findUserById(id: number): Promise<UserRecord | null> {
  const result = await pool.query<UserRecord>(
    'SELECT * FROM users WHERE id = $1',
    [id],
  );
  return result.rows[0] ?? null;
}

export async function createUser(data: NewUser): Promise<UserRecord> {
  const result = await pool.query<UserRecord>(
    `INSERT INTO users (name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [data.name, data.email, data.passwordHash, data.role],
  );
  return result.rows[0];
}

export async function createEmptyProfile(userId: number): Promise<void> {
  await pool.query('INSERT INTO profiles (user_id) VALUES ($1)', [userId]);
}

export async function updateUserName(
  userId: number,
  name: string,
): Promise<void> {
  await pool.query(
    'UPDATE users SET name = $1, updated_at = NOW() WHERE id = $2',
    [name, userId],
  );
}