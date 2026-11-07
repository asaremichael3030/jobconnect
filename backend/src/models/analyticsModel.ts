import { pool } from '../config/db';

export interface LogSearchFields {
  userId?: number;
  query: string;
  resultCount: number;
  latencyMs: number;
  cacheHit: boolean;
}

export async function logSearch(fields: LogSearchFields): Promise<void> {
  await pool.query(
    `INSERT INTO search_analytics (user_id, query, result_count, latency_ms, cache_hit)
     VALUES ($1, $2, $3, $4, $5)`,
    [
      fields.userId ?? null,
      fields.query.toLowerCase().trim(),
      fields.resultCount,
      fields.latencyMs,
      fields.cacheHit,
    ],
  );
}

export interface PopularSearch {
  query: string;
  count: number;
}

export interface SearchStats {
  totalSearches: number;
  averageLatency: number;
  cacheHitRate: number;
  popularSearches: PopularSearch[];
}

export async function getSearchStats(): Promise<SearchStats> {
  const totalResult = await pool.query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM search_analytics',
  );
  const totalSearches = parseInt(totalResult.rows[0]?.count ?? '0', 10);

  const latencyResult = await pool.query<{ avg: string }>(
    'SELECT COALESCE(AVG(latency_ms), 0)::text AS avg FROM search_analytics',
  );
  const averageLatency = Math.round(parseFloat(latencyResult.rows[0]?.avg ?? '0'));

  const hitResult = await pool.query<{ hits: string }>(
    'SELECT COUNT(*)::text AS hits FROM search_analytics WHERE cache_hit = TRUE',
  );
  const hits = parseInt(hitResult.rows[0]?.hits ?? '0', 10);
  const cacheHitRate = totalSearches > 0 ? (hits / totalSearches) * 100 : 0;

  const popularResult = await pool.query<PopularSearch>(
    `SELECT query, COUNT(*)::int AS count
     FROM search_analytics
     WHERE query != ''
     GROUP BY query
     ORDER BY count DESC
     LIMIT 5`,
  );

  return {
    totalSearches,
    averageLatency,
    cacheHitRate: Math.round(cacheHitRate * 10) / 10,
    popularSearches: popularResult.rows,
  };
}