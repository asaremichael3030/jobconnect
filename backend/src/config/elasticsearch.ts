import { Client } from '@elastic/elasticsearch';

const node = process.env.ELASTICSEARCH_URL ?? 'http://localhost:9200';

export const esClient = new Client({
  node,
  maxRetries: 3,
  requestTimeout: 10000,
});

export async function testElasticsearchConnection(): Promise<boolean> {
  const health = await esClient.cluster.health();
  return health.status === 'green' || health.status === 'yellow';
}