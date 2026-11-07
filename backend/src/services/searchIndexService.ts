import { esClient } from '../config/elasticsearch';

export const JOBS_INDEX = 'jobs';

const jobsIndexMapping = {
  settings: {
    number_of_shards: 1,
    number_of_replicas: 0,
  },
  mappings: {
    properties: {
      id: { type: 'integer' },
      companyId: { type: 'integer' },
      title: {
        type: 'text',
        fields: {
          keyword: { type: 'keyword', ignore_above: 256 },
        },
      },
      description: { type: 'text' },
      location: { type: 'keyword' },
      workingModel: { type: 'keyword' },
      jobType: { type: 'keyword' },
      experienceLevel: { type: 'keyword' },
      salaryMin: { type: 'integer' },
      salaryMax: { type: 'integer' },
      companyName: {
        type: 'text',
        fields: {
          keyword: { type: 'keyword', ignore_above: 256 },
        },
      },
      companyLogoUrl: { type: 'keyword' },
      status: { type: 'keyword' },
      createdAt: { type: 'date' },
    },
  },
} as const;

export async function ensureJobsIndex(): Promise<void> {
  const exists = await esClient.indices.exists({ index: JOBS_INDEX });
  if (exists) return;

  await esClient.indices.create({
    index: JOBS_INDEX,
    settings: jobsIndexMapping.settings,
    mappings: jobsIndexMapping.mappings,
  });

  console.log(`[es] Created index "${JOBS_INDEX}"`);
}

export async function deleteJobsIndex(): Promise<void> {
  const exists = await esClient.indices.exists({ index: JOBS_INDEX });
  if (!exists) return;

  await esClient.indices.delete({ index: JOBS_INDEX });
  console.log(`[es] Deleted index "${JOBS_INDEX}"`);
}

export async function refreshJobsIndex(): Promise<void> {
  await esClient.indices.refresh({ index: JOBS_INDEX });
}