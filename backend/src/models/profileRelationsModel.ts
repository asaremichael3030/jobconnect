import { pool } from '../config/db';

export interface SkillRecord {
  id: number;
  name: string;
}

export interface ExperienceRecord {
  id: number;
  user_id: number;
  job_title: string;
  company: string;
  start_date: string | null;
  end_date: string | null;
  description: string | null;
}

export interface EducationRecord {
  id: number;
  user_id: number;
  degree: string;
  school: string;
  start_year: number | null;
  end_year: number | null;
}

export async function getUserSkills(userId: number): Promise<SkillRecord[]> {
  const result = await pool.query<SkillRecord>(
    `SELECT s.id, s.name
     FROM skills s
     JOIN user_skills us ON us.skill_id = s.id
     WHERE us.user_id = $1
     ORDER BY s.name`,
    [userId],
  );
  return result.rows;
}

export async function getUserExperience(
  userId: number,
): Promise<ExperienceRecord[]> {
  const result = await pool.query<ExperienceRecord>(
    'SELECT * FROM experience WHERE user_id = $1 ORDER BY id DESC',
    [userId],
  );
  return result.rows;
}

export async function getUserEducation(
  userId: number,
): Promise<EducationRecord[]> {
  const result = await pool.query<EducationRecord>(
    'SELECT * FROM education WHERE user_id = $1 ORDER BY end_year DESC NULLS LAST, id DESC',
    [userId],
  );
  return result.rows;
}

export async function addUserExperience(
  userId: number,
  jobTitle: string,
  company: string,
  startDate: string,
  endDate: string,
  description: string,
): Promise<void> {
  await pool.query(
    `INSERT INTO experience (user_id, job_title, company, start_date, end_date, description)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId, jobTitle, company, startDate, endDate, description],
  );
}

export async function addUserEducation(
  userId: number,
  degree: string,
  school: string,
  startYear: number,
  endYear: number,
): Promise<void> {
  await pool.query(
    `INSERT INTO education (user_id, degree, school, start_year, end_year)
     VALUES ($1, $2, $3, $4, $5)`,
    [userId, degree, school, startYear, endYear],
  );
}

export async function addUserSkill(
  userId: number,
  skillName: string,
): Promise<void> {
  // 1. Insert the skill into the global skills list if it doesn't exist
  await pool.query(
    'INSERT INTO skills (name) VALUES ($1) ON CONFLICT (name) DO NOTHING',
    [skillName],
  );
  // 2. Link the skill to the user
  await pool.query(
    `INSERT INTO user_skills (user_id, skill_id) 
     SELECT $1, id FROM skills WHERE name = $2 
     ON CONFLICT DO NOTHING`,
    [userId, skillName],
  );
}