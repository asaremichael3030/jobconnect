import multer from 'multer';
import { Request } from 'express';
import { existsSync, mkdirSync } from 'fs';
import { extname, join } from 'path';

const IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp'];
const IMAGE_MAX_SIZE = 2 * 1024 * 1024;

const RESUME_EXTENSIONS = ['.pdf', '.doc', '.docx'];
const RESUME_MAX_SIZE = 5 * 1024 * 1024;

function makeStorage(folder: string) {
  const destination = join(process.cwd(), 'uploads', folder);

  if (!existsSync(destination)) {
    mkdirSync(destination, { recursive: true });
  }

  return multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, destination),
    filename: (req: Request, file, cb) => {
      const extension = extname(file.originalname).toLowerCase();
      const userId = req.user?.id ?? 0;
      const timestamp = Date.now();
      cb(null, `${userId}-${timestamp}${extension}`);
    },
  });
}

function makeImageFilter() {
  return (
    _req: Request,
    file: Express.Multer.File,
    cb: multer.FileFilterCallback,
  ) => {
    const extension = extname(file.originalname).toLowerCase();
    if (!IMAGE_EXTENSIONS.includes(extension)) {
      cb(new Error('Only jpg, jpeg, png, and webp files are allowed'));
      return;
    }
    cb(null, true);
  };
}

function makeResumeFilter() {
  return (
    _req: Request,
    file: Express.Multer.File,
    cb: multer.FileFilterCallback,
  ) => {
    const extension = extname(file.originalname).toLowerCase();
    if (!RESUME_EXTENSIONS.includes(extension)) {
      cb(new Error('Only PDF, DOC, and DOCX files are allowed'));
      return;
    }
    cb(null, true);
  };
}

export const profilePictureUpload = multer({
  storage: makeStorage('profile-pictures'),
  limits: { fileSize: IMAGE_MAX_SIZE },
  fileFilter: makeImageFilter(),
});

export const companyLogoUpload = multer({
  storage: makeStorage('company-logos'),
  limits: { fileSize: IMAGE_MAX_SIZE },
  fileFilter: makeImageFilter(),
});

export const resumeUpload = multer({
  storage: makeStorage('resumes'),
  limits: { fileSize: RESUME_MAX_SIZE },
  fileFilter: makeResumeFilter(),
});