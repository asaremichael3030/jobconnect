import { Request, Response, NextFunction } from 'express';
import { unlink } from 'fs/promises';
import { join } from 'path';

import {
  findProfileByUserId,
  updateProfile,
  updateProfilePictureUrl,
  updateResumeUrl,
} from '../models/profileModel';
import {
  getUserEducation,
  getUserExperience,
  getUserSkills,
  addUserExperience,
  addUserEducation,
  addUserSkill,
} from '../models/profileRelationsModel';
import { findUserById, updateUserName } from '../models/userModel';
import { failure, success } from '../utils/response';

function computeCompletionPercent(
  user: { name: string; email: string } | null,
  profile: {
    phone: string | null;
    location: string | null;
    headline: string | null;
    about: string | null;
  } | null,
  skillCount: number,
  expCount: number,
  eduCount: number,
): number {
  let percent = 0;
  if (user?.name) percent += 15;
  if (user?.email) percent += 10;
  if (profile?.phone) percent += 10;
  if (profile?.location) percent += 10;
  if (profile?.headline) percent += 10;
  if (profile?.about) percent += 10;
  if (skillCount > 0) percent += 10;
  if (expCount > 0) percent += 15;
  if (eduCount > 0) percent += 10;
  return Math.min(percent, 100);
}

export async function getMyProfile(
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

    const user = await findUserById(userId);
    if (!user) {
      failure(res, 'User not found', 404);
      return;
    }

    const profile = await findProfileByUserId(userId);
    const skills = await getUserSkills(userId);
    const experience = await getUserExperience(userId);
    const education = await getUserEducation(userId);

    const completionPercent = computeCompletionPercent(
      { name: user.name, email: user.email },
      profile,
      skills.length,
      experience.length,
      education.length,
    );

    success(res, {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
      profile: {
        phone: profile?.phone ?? null,
        location: profile?.location ?? null,
        headline: profile?.headline ?? null,
        about: profile?.about ?? null,
        yearsOfExperience: profile?.years_of_experience ?? 0,
        preferredJobType: profile?.preferred_job_type ?? null,
        preferredWorkingModel: profile?.preferred_working_model ?? null,
        linkedin: profile?.linkedin ?? null,
        github: profile?.github ?? null,
        portfolio: profile?.portfolio ?? null,
        profilePictureUrl: profile?.profile_picture_url ?? null,
        resumeUrl: profile?.resume_url ?? null,
        completionPercent,
      },
      skills: skills.map((s) => s.name),
      experience: experience.map((e) => ({
        id: e.id,
        jobTitle: e.job_title,
        company: e.company,
        startDate: e.start_date ?? '',
        endDate: e.end_date ?? '',
        description: e.description ?? '',
      })),
      education: education.map((e) => ({
        id: e.id,
        degree: e.degree,
        school: e.school,
        startYear: e.start_year ?? 0,
        endYear: e.end_year ?? 0,
      })),
    });
  } catch (error) {
    next(error);
  }
}

export async function updateMyProfile(
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
      phone,
      location,
      headline,
      about,
      yearsOfExperience,
      preferredJobType,
      preferredWorkingModel,
      linkedin,
      github,
      portfolio,
    } = req.body ?? {};

    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length < 2) {
        failure(res, 'Name must be at least 2 characters', 400);
        return;
      }
      await updateUserName(userId, name.trim());
    }

    await updateProfile(userId, {
      phone: typeof phone === 'string' ? phone : undefined,
      location: typeof location === 'string' ? location : undefined,
      headline: typeof headline === 'string' ? headline : undefined,
      about: typeof about === 'string' ? about : undefined,
      yearsOfExperience:
        typeof yearsOfExperience === 'number' ? yearsOfExperience : undefined,
      preferredJobType:
        typeof preferredJobType === 'string' ? preferredJobType : undefined,
      preferredWorkingModel:
        typeof preferredWorkingModel === 'string'
          ? preferredWorkingModel
          : undefined,
      linkedin: typeof linkedin === 'string' ? linkedin : undefined,
      github: typeof github === 'string' ? github : undefined,
      portfolio: typeof portfolio === 'string' ? portfolio : undefined,
    });

    success(res, { message: 'Profile updated' });
  } catch (error) {
    next(error);
  }
}

export async function uploadProfilePicture(
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

    const relativeUrl = `/uploads/profile-pictures/${file.filename}`;

    const current = await findProfileByUserId(userId);

    if (current?.profile_picture_url) {
      const oldPath = join(
        process.cwd(),
        current.profile_picture_url.replace(/^\//, ''),
      );
      await unlink(oldPath).catch(() => {});
    }

    await updateProfilePictureUrl(userId, relativeUrl);
    success(res, { profilePictureUrl: relativeUrl });
  } catch (error) {
    next(error);
  }
}

export async function uploadResume(
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

    const relativeUrl = `/uploads/resumes/${file.filename}`;

    const current = await findProfileByUserId(userId);

    if (current?.resume_url) {
      const oldPath = join(
        process.cwd(),
        current.resume_url.replace(/^\//, ''),
      );
      await unlink(oldPath).catch(() => {});
    }

    await updateResumeUrl(userId, relativeUrl);
    success(res, { resumeUrl: relativeUrl });
  } catch (error) {
    next(error);
  }
}

export async function addExperience(
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
    const { jobTitle, company, startDate, endDate, description } = req.body;

    if (!jobTitle || !company) {
      failure(res, 'Job title and company are required', 400);
      return;
    }

    await addUserExperience(
      userId,
      jobTitle,
      company,
      startDate || '',
      endDate || '',
      description || '',
    );
    success(res, { message: 'Experience added' }, 201);
  } catch (error) {
    next(error);
  }
}

export async function addEducation(
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
    const { degree, school, startYear, endYear } = req.body;

    if (!degree || !school) {
      failure(res, 'Degree and school are required', 400);
      return;
    }

    await addUserEducation(userId, degree, school, startYear || 0, endYear || 0);
    success(res, { message: 'Education added' }, 201);
  } catch (error) {
    next(error);
  }
}

export async function addSkill(
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
    const { skill } = req.body;

    if (!skill || typeof skill !== 'string') {
      failure(res, 'Skill name is required', 400);
      return;
    }

    await addUserSkill(userId, skill.trim());
    success(res, { message: 'Skill added' }, 201);
  } catch (error) {
    next(error);
  }
}