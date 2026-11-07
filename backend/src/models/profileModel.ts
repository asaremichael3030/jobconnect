import { pool } from '../config/db';

export interface ProfileRecord {
  id: number;
  user_id: number;
  phone: string | null;
  location: string | null;
  headline: string | null;
  about: string | null;
  years_of_experience: number;
  preferred_job_type: string | null;
  preferred_working_model: string | null;
  linkedin: string | null;
  github: string | null;
  portfolio: string | null;
  profile_picture_url: string | null;
  resume_url: string | null;
}

export async function findProfileByUserId(
  userId: number,
): Promise<ProfileRecord | null> {
  const result = await pool.query<ProfileRecord>(
    'SELECT * FROM profiles WHERE user_id = $1',
    [userId],
  );
  return result.rows[0] ?? null;
}

export interface UpdateProfileFields {
  phone?: string;
  location?: string;
  headline?: string;
  about?: string;
  yearsOfExperience?: number;
  preferredJobType?: string;
  preferredWorkingModel?: string;
  linkedin?: string;
  github?: string;
  portfolio?: string;
}

export async function updateProfile(
  userId: number,
  fields: UpdateProfileFields,
): Promise<void> {
  await pool.query(
    `UPDATE profiles
     SET phone = COALESCE($2, phone),
         location = COALESCE($3, location),
         headline = COALESCE($4, headline),
         about = COALESCE($5, about),
         years_of_experience = COALESCE($6, years_of_experience),
         preferred_job_type = COALESCE($7, preferred_job_type),
         preferred_working_model = COALESCE($8, preferred_working_model),
         linkedin = COALESCE($9, linkedin),
         github = COALESCE($10, github),
         portfolio = COALESCE($11, portfolio),
         updated_at = NOW()
     WHERE user_id = $1`,
    [
      userId,
      fields.phone ?? null,
      fields.location ?? null,
      fields.headline ?? null,
      fields.about ?? null,
      fields.yearsOfExperience ?? null,
      fields.preferredJobType ?? null,
      fields.preferredWorkingModel ?? null,
      fields.linkedin ?? null,
      fields.github ?? null,
      fields.portfolio ?? null,
    ],
  );
}

export async function updateProfilePictureUrl(
  userId: number,
  url: string,
): Promise<void> {
  await pool.query(
    `UPDATE profiles
     SET profile_picture_url = $1, updated_at = NOW()
     WHERE user_id = $2`,
    [url, userId],
  );
}

export async function updateResumeUrl(
  userId: number,
  url: string,
): Promise<void> {
  await pool.query(
    `UPDATE profiles
     SET resume_url = $1, updated_at = NOW()
     WHERE user_id = $2`,
    [url, userId],
  );
}