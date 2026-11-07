import jwt from 'jsonwebtoken';

export interface TokenPayload {
  id: number;
  role: 'JOB_SEEKER' | 'EMPLOYER' | 'ADMIN';
}

const SECRET = process.env.JWT_SECRET as string;
const EXPIRES_IN = process.env.JWT_EXPIRES_IN ?? '7d';

if (!SECRET || SECRET === 'replace_this_with_a_long_random_string') {
  throw new Error(
    'JWT_SECRET is not set. Update your .env file with a long random string.',
  );
}

export function signToken(payload: TokenPayload): string {
  return jwt.sign(payload, SECRET, { expiresIn: EXPIRES_IN } as jwt.SignOptions);
}

export function verifyToken(token: string): TokenPayload {
  return jwt.verify(token, SECRET) as TokenPayload;
}