import { Request, Response, NextFunction } from 'express';

import {
  createEmptyProfile,
  createUser,
  findUserByEmail,
  findUserById,
} from '../models/userModel';
import { signToken } from '../utils/jwt';
import { hashPassword, verifyPassword } from '../utils/password';
import { failure, success } from '../utils/response';

const ALLOWED_ROLES = ['JOB_SEEKER', 'EMPLOYER'] as const;

function isValidEmail(email: string): boolean {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return pattern.test(email);
}

export async function register(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { name, email, password, role } = req.body ?? {};

    if (!name || typeof name !== 'string' || name.trim().length < 2) {
      failure(res, 'Name must be at least 2 characters', 400);
      return;
    }

    if (!email || typeof email !== 'string' || !isValidEmail(email)) {
      failure(res, 'A valid email is required', 400);
      return;
    }

    if (!password || typeof password !== 'string' || password.length < 6) {
      failure(res, 'Password must be at least 6 characters', 400);
      return;
    }

    if (!role || !ALLOWED_ROLES.includes(role)) {
      failure(res, 'Role must be JOB_SEEKER or EMPLOYER', 400);
      return;
    }

    const normalisedEmail = email.trim().toLowerCase();
    const existing = await findUserByEmail(normalisedEmail);
    if (existing) {
      failure(res, 'An account with this email already exists', 409);
      return;
    }

    const passwordHash = await hashPassword(password);

    const user = await createUser({
      name: name.trim(),
      email: normalisedEmail,
      passwordHash,
      role,
    });

    await createEmptyProfile(user.id);

    success(
      res,
      {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      },
      201,
    );
  } catch (error) {
    next(error);
  }
}

export async function login(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { email, password } = req.body ?? {};

    if (!email || typeof email !== 'string') {
      failure(res, 'Email is required', 400);
      return;
    }

    if (!password || typeof password !== 'string') {
      failure(res, 'Password is required', 400);
      return;
    }

    const normalisedEmail = email.trim().toLowerCase();
    const user = await findUserByEmail(normalisedEmail);

    if (!user) {
      failure(res, 'Invalid email or password', 401);
      return;
    }

    if (user.status !== 'ACTIVE') {
      failure(res, 'This account has been suspended', 403);
      return;
    }

    const passwordMatches = await verifyPassword(password, user.password_hash);
    if (!passwordMatches) {
      failure(res, 'Invalid email or password', 401);
      return;
    }

    const token = signToken({
      id: user.id,
      role: user.role as 'JOB_SEEKER' | 'EMPLOYER' | 'ADMIN',
    });

    success(res, {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    next(error);
  }
}

export async function getMe(
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

    if (user.status !== 'ACTIVE') {
      failure(res, 'This account has been suspended', 403);
      return;
    }

    success(res, {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    next(error);
  }
}