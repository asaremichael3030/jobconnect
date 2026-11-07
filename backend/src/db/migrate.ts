import 'dotenv/config';
import { readFileSync } from 'fs';
import { join } from 'path';
import { pool } from '../config/db';

async function migrate(): Promise<void> {
  const schemaPath = join(process.cwd(), 'src', 'db', 'schema.sql');
  const sql = readFileSync(schemaPath, 'utf-8');

  const client = await pool.connect();
  try {
    await client.query(sql);
    console.log('[migrate] Schema applied successfully');
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('[migrate] Failed:', message);
    process.exitCode = 1;
  } finally {
    client.release();
    await pool.end();
  }
}

migrate();