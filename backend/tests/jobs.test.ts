import request from 'supertest';
import { createApp } from '../src/app';

const app = createApp();

// Helper to get an employer token
async function getEmployerToken(): Promise<string> {
  await request(app).post('/api/auth/register').send({
    name: 'Tech Corp',
    email: 'employer@test.com',
    password: 'password123',
    role: 'EMPLOYER',
  });
  const res = await request(app).post('/api/auth/login').send({
    email: 'employer@test.com',
    password: 'password123',
  });
  return res.body.data.token;
}

describe('Jobs', () => {
  it('should create a job as an employer', async () => {
    const token = await getEmployerToken();

    // Note: In a real test, you would need to create a company profile first.
    // For this test to pass, you must create the company profile.
    await request(app)
      .put('/api/companies/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Tech Corp', industry: 'Software' });

    const res = await request(app)
      .post('/api/jobs')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Senior Backend Developer',
        description: 'We are looking for a Node.js expert.',
        workingModel: 'Remote',
        jobType: 'Full-Time',
        experienceLevel: 'Senior',
      });

    expect(res.status).toBe(201);
    expect(res.body.data.job.title).toBe('Senior Backend Developer');
  });

  it('should allow guest users to view jobs', async () => {
    // Create a job first
    const token = await getEmployerToken();
    await request(app)
      .put('/api/companies/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Tech Corp' });

    await request(app)
      .post('/api/jobs')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Frontend Developer',
        description: 'React and Flutter expert needed for our team.',
        workingModel: 'Remote',
        jobType: 'Full-Time',
        experienceLevel: 'Mid-Level',
      });

    // Fetch jobs without a token (Guest)
    const res = await request(app).get('/api/jobs');

    expect(res.status).toBe(200);
    expect(res.body.data.jobs.length).toBeGreaterThan(0);
    expect(res.body.data.jobs[0].title).toBe('Frontend Developer');
  });
});