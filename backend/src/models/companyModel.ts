import { pool } from '../config/db';

export interface CompanyRecord {
  id: number;
  owner_id: number;
  name: string;
  industry: string | null;
  company_size: string | null;
  location: string | null;
  about: string | null;
  website: string | null;
  email: string | null;
  linkedin: string | null;
  twitter: string | null;
  logo_url: string | null;
  verification_status: string;
  founded_year: number | null;
  created_at: Date;
  updated_at: Date;
}

export async function findCompanyByOwnerId(
  ownerId: number,
): Promise<CompanyRecord | null> {
  const result = await pool.query<CompanyRecord>(
    'SELECT * FROM companies WHERE owner_id = $1',
    [ownerId],
  );
  return result.rows[0] ?? null;
}

export async function findCompanyById(
  id: number,
): Promise<CompanyRecord | null> {
  const result = await pool.query<CompanyRecord>(
    'SELECT * FROM companies WHERE id = $1',
    [id],
  );
  return result.rows[0] ?? null;
}

export interface CreateCompanyFields {
  name: string;
  industry?: string;
  companySize?: string;
  location?: string;
  about?: string;
  website?: string;
  email?: string;
  linkedin?: string;
  twitter?: string;
  foundedYear?: number;
}

export async function createCompany(
  ownerId: number,
  fields: CreateCompanyFields,
): Promise<CompanyRecord> {
  const result = await pool.query<CompanyRecord>(
    `INSERT INTO companies (
       owner_id, name, industry, company_size, location, about,
       website, email, linkedin, twitter, founded_year
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
     RETURNING *`,
    [
      ownerId,
      fields.name,
      fields.industry ?? null,
      fields.companySize ?? null,
      fields.location ?? null,
      fields.about ?? null,
      fields.website ?? null,
      fields.email ?? null,
      fields.linkedin ?? null,
      fields.twitter ?? null,
      fields.foundedYear ?? null,
    ],
  );
  return result.rows[0];
}

export interface UpdateCompanyFields {
  name?: string;
  industry?: string;
  companySize?: string;
  location?: string;
  about?: string;
  website?: string;
  email?: string;
  linkedin?: string;
  twitter?: string;
  foundedYear?: number;
}

export async function updateCompany(
  ownerId: number,
  fields: UpdateCompanyFields,
): Promise<void> {
  await pool.query(
    `UPDATE companies
     SET name = COALESCE($2, name),
         industry = COALESCE($3, industry),
         company_size = COALESCE($4, company_size),
         location = COALESCE($5, location),
         about = COALESCE($6, about),
         website = COALESCE($7, website),
         email = COALESCE($8, email),
         linkedin = COALESCE($9, linkedin),
         twitter = COALESCE($10, twitter),
         founded_year = COALESCE($11, founded_year),
         updated_at = NOW()
     WHERE owner_id = $1`,
    [
      ownerId,
      fields.name ?? null,
      fields.industry ?? null,
      fields.companySize ?? null,
      fields.location ?? null,
      fields.about ?? null,
      fields.website ?? null,
      fields.email ?? null,
      fields.linkedin ?? null,
      fields.twitter ?? null,
      fields.foundedYear ?? null,
    ],
  );
}

export async function updateCompanyLogoUrl(
  ownerId: number,
  url: string,
): Promise<void> {
  await pool.query(
    `UPDATE companies
     SET logo_url = $1, updated_at = NOW()
     WHERE owner_id = $2`,
    [url, ownerId],
  );
}