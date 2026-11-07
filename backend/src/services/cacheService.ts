import { redisClient } from '../config/redis';

export async function getCached<T>(key: string): Promise<T | null> {
  try {
    const data = await redisClient.get(key);
    if (!data) return null;
    return JSON.parse(data) as T;
  } catch (error) {
    console.error('[cache] Failed to read from Redis:', error);
    return null;
  }
}

export async function setCached(
  key: string,
  value: unknown,
  ttlSeconds: number,
): Promise<void> {
  try {
    await redisClient.setEx(key, ttlSeconds, JSON.stringify(value));
  } catch (error) {
    console.error('[cache] Failed to write to Redis:', error);
  }
}