import { createClient } from 'redis';

const redisUrl = process.env.REDIS_URL ?? 'redis://localhost:6379';

export const redisClient = createClient({
  url: redisUrl,
});

let hasLoggedDisconnect = false;

redisClient.on('error', (err) => {
  if (!hasLoggedDisconnect) {
    console.error('[redis] Connection error:', err.message || err);
    console.error('[redis] Is Redis running? Try: docker compose start redis');
    hasLoggedDisconnect = true;
  }
});

redisClient.on('connect', () => {
  console.log('[redis] Connected to Redis');
  hasLoggedDisconnect = false;
});

redisClient.on('reconnecting', () => {
  // quiet — the error handler already logged once
});

redisClient.connect().catch((err) => {
  console.error('[redis] Initial connection failed:', err.message);
  console.error('[redis] Start Redis with: docker compose start redis');
});

export async function testRedisConnection(): Promise<boolean> {
  try {
    const pong = await redisClient.ping();
    return pong === 'PONG';
  } catch (error) {
    return false;
  }
}