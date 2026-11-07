import { Request, Response, NextFunction } from 'express';
import { unlink } from 'fs/promises';
import { join } from 'path';

import {
  createCompany,
  findCompanyByOwnerId,
  updateCompany,
  updateCompanyLogoUrl,
} from '../models/companyModel';
import { failure, success } from '../utils/response';

function toCompanyResponse(company: {
  id: number;
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
}) {
  return {
    id: company.id,
    name: company.name,
    industry: company.industry ?? '',
    companySize: company.company_size ?? '',
    location: company.location ?? '',
    about: company.about ?? '',
    website: company.website ?? '',
    email: company.email ?? '',
    linkedin: company.linkedin ?? null,
    twitter: company.twitter ?? null,
    logoUrl: company.logo_url ?? null,
    verificationStatus: company.verification_status,
    foundedYear: company.founded_year ?? 0,
  };
}

export async function getMyCompany(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const company = await findCompanyByOwnerId(userId);
    if (!company) {
      success(res, { exists: false, company: null });
      return;
    }

    success(res, {
      exists: true,
      company: toCompanyResponse(company),
    });
  } catch (error) {
    next(error);
  }
}

export async function updateMyCompany(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const {
      name,
      industry,
      companySize,
      location,
      about,
      website,
      email,
      linkedin,
      twitter,
      foundedYear,
    } = req.body ?? {};

    const existing = await findCompanyByOwnerId(userId);

    if (!existing) {
      if (!name || typeof name !== 'string' || name.trim().length < 2) {
        failure(
          res,
          'Company name is required to create a company profile',
          400,
        );
        return;
      }

      const created = await createCompany(userId, {
        name: name.trim(),
        industry: typeof industry === 'string' ? industry : undefined,
        companySize: typeof companySize === 'string' ? companySize : undefined,
        location: typeof location === 'string' ? location : undefined,
        about: typeof about === 'string' ? about : undefined,
        website: typeof website === 'string' ? website : undefined,
        email: typeof email === 'string' ? email : undefined,
        linkedin: typeof linkedin === 'string' ? linkedin : undefined,
        twitter: typeof twitter === 'string' ? twitter : undefined,
        foundedYear:
          typeof foundedYear === 'number' ? foundedYear : undefined,
      });

      success(res, {
        exists: true,
        company: toCompanyResponse(created),
      });
      return;
    }

    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length < 2) {
        failure(res, 'Company name must be at least 2 characters', 400);
        return;
      }
    }

    await updateCompany(userId, {
      name: typeof name === 'string' ? name.trim() : undefined,
      industry: typeof industry === 'string' ? industry : undefined,
      companySize: typeof companySize === 'string' ? companySize : undefined,
      location: typeof location === 'string' ? location : undefined,
      about: typeof about === 'string' ? about : undefined,
      website: typeof website === 'string' ? website : undefined,
      email: typeof email === 'string' ? email : undefined,
      linkedin: typeof linkedin === 'string' ? linkedin : undefined,
      twitter: typeof twitter === 'string' ? twitter : undefined,
      foundedYear: typeof foundedYear === 'number' ? foundedYear : undefined,
    });

    const updated = await findCompanyByOwnerId(userId);

    success(res, {
      exists: true,
      company: updated ? toCompanyResponse(updated) : null,
    });
  } catch (error) {
    next(error);
  }
}

export async function uploadCompanyLogo(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const file = req.file;
    if (!file) {
      failure(res, 'No file uploaded', 400);
      return;
    }

    const company = await findCompanyByOwnerId(userId);
    if (!company) {
      await unlink(file.path).catch(() => {
        // File was just uploaded; clean it up since we cannot attach it
      });
      failure(
        res,
        'Create your company profile before uploading a logo',
        400,
      );
      return;
    }

    const relativeUrl = `/uploads/company-logos/${file.filename}`;

    if (company.logo_url) {
      const oldPath = join(
        process.cwd(),
        company.logo_url.replace(/^\//, ''),
      );
      await unlink(oldPath).catch(() => {
        // Old file may already be gone; that is fine
      });
    }

    await updateCompanyLogoUrl(userId, relativeUrl);

    success(res, {
      logoUrl: relativeUrl,
    });
  } catch (error) {
    next(error);
  }
}