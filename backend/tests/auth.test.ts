import request from 'supertest';
import { createApp } from '../src/app';

const app = createApp();

describe('Authentication', () => {
  it('should register a new user successfully', async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Test Seeker',
      email: 'test@example.com',
      password: 'password123',
      role: 'JOB_SEEKER',
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe('test@example.com');
  });

  it('should reject duplicate email registration', async () => {
    // Register once
    await request(app).post('/api/auth/register').send({
      name: 'Test Seeker',
      email: 'duplicate@example.com',
      password: 'password123',
      role: 'JOB_SEEKER',
    });

    // Try registering again with the same email
    const res = await request(app).post('/api/auth/register').send({
      name: 'Another Name',
      email: 'duplicate@example.com',
      password: 'password123',
      role: 'JOB_SEEKER',
    });

    expect(res.status).toBe(409);
    expect(res.body.message).toMatch(/already exists/i);
  });

  it('should login and return a JWT token', async () => {
    await request(app).post('/api/auth/register').send({
      name: 'Login Test',
      email: 'login@example.com',
      password: 'password123',
      role: 'EMPLOYER',
    });

    const res = await request(app).post('/api/auth/login').send({
      email: 'login@example.com',
      password: 'password123',
    });

    expect(res.status).toBe(200);
    expect(res.body.data.token).toBeDefined();
    expect(res.body.data.user.role).toBe('EMPLOYER');
  });

  it('should reject login with wrong password', async () => {
    await request(app).post('/api/auth/register').send({
      name: 'Login Test',
      email: 'login2@example.com',
      password: 'password123',
      role: 'JOB_SEEKER',
    });

    const res = await request(app).post('/api/auth/login').send({
      email: 'login2@example.com',
      password: 'wrongpassword',
    });

    expect(res.status).toBe(401);
    expect(res.body.message).toMatch(/invalid email or password/i);
  });
});