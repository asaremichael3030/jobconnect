-- Reset block. Uncomment all lines below and run the migration
-- if you want a completely fresh database during development.
-- WARNING: this deletes all data.
--
-- DROP TABLE IF EXISTS search_analytics CASCADE;
-- DROP TABLE IF EXISTS reports CASCADE;
-- DROP TABLE IF EXISTS notifications CASCADE;
-- DROP TABLE IF EXISTS saved_jobs CASCADE;
-- DROP TABLE IF EXISTS applications CASCADE;
-- DROP TABLE IF EXISTS jobs CASCADE;
-- DROP TABLE IF EXISTS experience CASCADE;
-- DROP TABLE IF EXISTS education CASCADE;
-- DROP TABLE IF EXISTS user_skills CASCADE;
-- DROP TABLE IF EXISTS skills CASCADE;
-- DROP TABLE IF EXISTS companies CASCADE;
-- DROP TABLE IF EXISTS profiles CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE IF NOT EXISTS users (
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(120) NOT NULL,
  email          VARCHAR(160) UNIQUE NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  role           VARCHAR(20)  NOT NULL
                 CHECK (role IN ('JOB_SEEKER', 'EMPLOYER', 'ADMIN')),
  status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
                 CHECK (status IN ('ACTIVE', 'SUSPENDED')),
  created_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

CREATE TABLE IF NOT EXISTS profiles (
  id                      SERIAL PRIMARY KEY,
  user_id                 INTEGER NOT NULL UNIQUE
                          REFERENCES users(id) ON DELETE CASCADE,
  phone                   VARCHAR(40),
  location                VARCHAR(120),
  headline                VARCHAR(200),
  about                   TEXT,
  years_of_experience     INTEGER DEFAULT 0,
  preferred_job_type      VARCHAR(20),
  preferred_working_model VARCHAR(20),
  linkedin                VARCHAR(200),
  github                  VARCHAR(200),
  portfolio               VARCHAR(200),
  profile_picture_url     VARCHAR(300),
  resume_url              VARCHAR(300),
  created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS companies (
  id                   SERIAL PRIMARY KEY,
  owner_id             INTEGER NOT NULL
                       REFERENCES users(id) ON DELETE CASCADE,
  name                 VARCHAR(160) NOT NULL,
  industry             VARCHAR(120),
  company_size         VARCHAR(60),
  location             VARCHAR(160),
  about                TEXT,
  website              VARCHAR(200),
  email                VARCHAR(160),
  linkedin             VARCHAR(200),
  twitter              VARCHAR(200),
  logo_url             VARCHAR(300),
  verification_status  VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                       CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
  founded_year         INTEGER,
  created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_companies_owner ON companies(owner_id);

CREATE TABLE IF NOT EXISTS skills (
  id    SERIAL PRIMARY KEY,
  name  VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS user_skills (
  id        SERIAL PRIMARY KEY,
  user_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  skill_id  INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  UNIQUE (user_id, skill_id)
);

CREATE TABLE IF NOT EXISTS education (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  degree      VARCHAR(160) NOT NULL,
  school      VARCHAR(160) NOT NULL,
  start_year  INTEGER,
  end_year    INTEGER,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS experience (
  id           SERIAL PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  job_title    VARCHAR(160) NOT NULL,
  company      VARCHAR(160) NOT NULL,
  start_date   VARCHAR(40),
  end_date     VARCHAR(40),
  description  TEXT,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS jobs (
  id                    SERIAL PRIMARY KEY,
  company_id            INTEGER NOT NULL
                        REFERENCES companies(id) ON DELETE CASCADE,
  title                 VARCHAR(160) NOT NULL,
  description           TEXT NOT NULL,
  location              VARCHAR(160),
  working_model         VARCHAR(20) NOT NULL
                        CHECK (working_model IN ('Remote', 'Hybrid', 'On-Site')),
  job_type              VARCHAR(20) NOT NULL
                        CHECK (job_type IN ('Full-Time', 'Part-Time', 'Internship', 'Contract')),
  experience_level      VARCHAR(20) NOT NULL
                        CHECK (experience_level IN ('Internship', 'Entry Level', 'Junior', 'Mid-Level', 'Senior')),
  salary_min            INTEGER,
  salary_max            INTEGER,
  salary_currency       VARCHAR(10) DEFAULT 'USD',
  requirements          TEXT,
  responsibilities      TEXT,
  application_deadline  DATE,
  status                VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                        CHECK (status IN ('DRAFT', 'ACTIVE', 'CLOSED', 'REMOVED')),
  created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_jobs_company ON jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status  ON jobs(status);

CREATE TABLE IF NOT EXISTS applications (
  id            SERIAL PRIMARY KEY,
  job_id        INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status        VARCHAR(20) NOT NULL DEFAULT 'APPLIED'
                CHECK (status IN ('APPLIED', 'REVIEWING', 'SHORTLISTED',
                                  'INTERVIEW', 'REJECTED', 'HIRED')),
  cover_letter  TEXT,
  resume_url    VARCHAR(300),
  created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (job_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_applications_job  ON applications(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_user ON applications(user_id);

CREATE TABLE IF NOT EXISTS saved_jobs (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  job_id      INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, job_id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id          SERIAL PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title       VARCHAR(200) NOT NULL,
  message     TEXT NOT NULL,
  type        VARCHAR(40) NOT NULL,
  related_id  INTEGER,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);

CREATE TABLE IF NOT EXISTS reports (
  id           SERIAL PRIMARY KEY,
  reporter_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_type  VARCHAR(20) NOT NULL
               CHECK (target_type IN ('USER', 'COMPANY', 'JOB')),
  target_id    INTEGER NOT NULL,
  reason       TEXT NOT NULL,
  status       VARCHAR(20) NOT NULL DEFAULT 'PENDING'
               CHECK (status IN ('PENDING', 'REVIEWED', 'RESOLVED')),
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

CREATE TABLE IF NOT EXISTS search_analytics (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER REFERENCES users(id) ON DELETE SET NULL,
  query         VARCHAR(300) NOT NULL,
  result_count  INTEGER NOT NULL DEFAULT 0,
  latency_ms    INTEGER NOT NULL DEFAULT 0,
  cache_hit     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_analytics_query   ON search_analytics(query);
CREATE INDEX IF NOT EXISTS idx_search_analytics_created ON search_analytics(created_at);