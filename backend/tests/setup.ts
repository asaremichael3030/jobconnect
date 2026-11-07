import 'dotenv/config';
import { pool } from '../src/config/db';

// Override the database name to point to the test database
process.env.DB_NAME = 'jobconnect_test';

beforeAll(async () => {
  // Wait for connection
  await pool.query('SELECT 1');
});

afterEach(async () => {
  // Clear all tables before the next test
  await pool.query(`
    TRUNCATE TABLE
      users, profiles, companies, jobs, applications,
      saved_jobs, notifications, reports, skills,
      user_skills, education, experience, search_analytics
    RESTART IDENTITY CASCADE;
  `);
});

afterAll(async () => {
  // Close the connection when all tests are done
  await pool.end();
});