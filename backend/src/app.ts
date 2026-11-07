import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { join } from 'path';

import { testConnection } from './config/db';
import { testElasticsearchConnection } from './config/elasticsearch';
import { testRedisConnection } from './config/redis';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import adminRoutes from './routes/adminRoutes';
import applicationRoutes from './routes/applicationRoutes';
import authRoutes from './routes/authRoutes';
import companyRoutes from './routes/companyRoutes';
import jobRoutes from './routes/jobRoutes';
import notificationRoutes from './routes/notificationRoutes';
import savedJobRoutes from './routes/savedJobRoutes';
import userRoutes from './routes/userRoutes';
import { success, failure } from './utils/response';
import analyticsRoutes from './routes/analyticsRoutes';
import reportRoutes from './routes/reportRoutes';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

export function createApp(): Express {
  const app = express();

  app.use(helmet({ crossOriginResourcePolicy: false }));
  app.use(cors());
  app.use(express.json());

  app.get('/api/health', (_req, res) => {
    success(res, {
      status: 'ok',
      service: 'jobconnect-api',
      time: new Date().toISOString(),
    });
  });

  app.get('/api/health/db', async (_req, res) => {
    try {
      await testConnection();
      success(res, { status: 'ok', database: 'connected' });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      failure(res, `Database connection failed: ${message}`, 500);
    }
  });

  app.get('/api/health/es', async (_req, res) => {
    try {
      const ok = await testElasticsearchConnection();
      success(res, {
        status: ok ? 'ok' : 'degraded',
        elasticsearch: ok ? 'connected' : 'unreachable',
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      failure(res, `Elasticsearch connection failed: ${message}`, 500);
    }
  });

  app.get('/api/health/redis', async (_req, res) => {
    try {
      const ok = await testRedisConnection();
      if (ok) {
        success(res, { status: 'ok', redis: 'connected' });
      } else {
        failure(res, 'Redis connection failed', 500);
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      failure(res, `Redis connection failed: ${message}`, 500);
    }
  });

  app.use('/uploads', express.static(join(process.cwd(), 'uploads')));

  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/companies', companyRoutes);
  app.use('/api/jobs', jobRoutes);
  app.use('/api/applications', applicationRoutes);
  app.use('/api/saved-jobs', savedJobRoutes);
  app.use('/api/notifications', notificationRoutes);
  app.use('/api/admin', adminRoutes);
  app.use('/api/analytics', analyticsRoutes);
  app.use('/api/reports', reportRoutes);
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}