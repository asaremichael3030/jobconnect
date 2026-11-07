import request from 'supertest';
import { createApp } from '../src/app';

const app = createApp();

async function setupJobAndSeeker() {
  // 1. Create Employer and Job
  await request(app).post('/api/auth/register').send({
    name: 'Employer', email: 'emp@test.com', password: 'password123', role: 'EMPLOYER',
  });
  const empRes = await request(app).post('/api/auth/login').send({ email: 'emp@test.com', password: 'password123' });
  const empToken = empRes.body.data.token;

  await request(app).put('/api/companies/me').set('Authorization', `Bearer ${empToken}`).send({ name: 'Emp Corp' });

  const jobRes = await request(app).post('/api/jobs').set('Authorization', `Bearer ${empToken}`).send({
    title: 'Junior Developer', description: 'Learn and grow with us! We offer training.', workingModel: 'Remote', jobType: 'Full-Time', experienceLevel: 'Junior',
  });
  const jobId = jobRes.body.data.job.id;

  // 2. Create Seeker
  await request(app).post('/api/auth/register').send({
    name: 'Seeker', email: 'seek@test.com', password: 'password123', role: 'JOB_SEEKER',
  });
  const seekRes = await request(app).post('/api/auth/login').send({ email: 'seek@test.com', password: 'password123' });
  const seekToken = seekRes.body.data.token;

  return { empToken, seekToken, jobId };
}

describe('Applications', () => {
  it('should allow a seeker to apply to a job', async () => {
    const { seekToken, jobId } = await setupJobAndSeeker();

    const res = await request(app)
      .post(`/api/jobs/${jobId}/apply`)
      .set('Authorization', `Bearer ${seekToken}`)
      .send({ coverLetter: 'I am very interested in this role.' });

    expect(res.status).toBe(201);
    expect(res.body.data.application.status).toBe('APPLIED');
  });

  it('should prevent applying to the same job twice', async () => {
    const { seekToken, jobId } = await setupJobAndSeeker();

    // First apply
    await request(app)
      .post(`/api/jobs/${jobId}/apply`)
      .set('Authorization', `Bearer ${seekToken}`)
      .send({});

    // Second apply
    const res = await request(app)
      .post(`/api/jobs/${jobId}/apply`)
      .set('Authorization', `Bearer ${seekToken}`)
      .send({});

    expect(res.status).toBe(409);
    expect(res.body.message).toMatch(/already applied/i);
  });
});