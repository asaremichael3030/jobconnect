import { esClient } from '../config/elasticsearch';
import { JOBS_INDEX } from './searchIndexService';

export type SortOption =
  | 'Relevance'
  | 'Newest'
  | 'Salary: High to Low'
  | 'Salary: Low to High';

export interface SearchJobsOptions {
  query?: string;
  location?: string;
  workingModel?: string;
  jobType?: string;
  experienceLevel?: string;
  salaryMin?: number;
  salaryMax?: number;
  company?: string;
  postedAfter?: string;
  sort: SortOption;
  page: number;
  limit: number;
}

export interface JobSearchHit {
  id: number;
  companyId: number;
  title: string;
  description: string;
  location: string;
  workingModel: string;
  jobType: string;
  experienceLevel: string;
  salaryMin: number | null;
  salaryMax: number | null;
  companyName: string;
  companyLogoUrl: string | null;
  status: string;
  createdAt: string;
  score: number | null;
  matchScore: number | null;
}

export interface JobSearchResult {
  jobs: JobSearchHit[];
  total: number;
  page: number;
  limit: number;
}

function buildSort(sort: SortOption, hasQuery: boolean): string[] {
  switch (sort) {
    case 'Newest':
      return ['createdAt:desc'];
    case 'Salary: High to Low':
      return ['salaryMax:desc', 'createdAt:desc'];
    case 'Salary: Low to High':
      return ['salaryMin:asc', 'createdAt:desc'];
    case 'Relevance':
    default:
      return hasQuery ? ['_score'] : ['createdAt:desc'];
  }
}

export async function searchJobsES(
  options: SearchJobsOptions,
): Promise<JobSearchResult> {
  const must: Record<string, unknown>[] = [];
  const filter: Record<string, unknown>[] = [{ term: { status: 'ACTIVE' } }];

  if (options.query) {
    must.push({
      multi_match: {
        query: options.query,
        fields: ['title^3', 'companyName^2', 'description'],
        fuzziness: 'AUTO',
        operator: 'or',
      },
    });
  }

  if (options.location) {
    filter.push({ term: { location: options.location } });
  }
  if (options.workingModel) {
    filter.push({ term: { workingModel: options.workingModel } });
  }
  if (options.jobType) {
    filter.push({ term: { jobType: options.jobType } });
  }
  if (options.experienceLevel) {
    filter.push({ term: { experienceLevel: options.experienceLevel } });
  }

  if (options.salaryMin !== undefined || options.salaryMax !== undefined) {
    const salaryRange: Record<string, number> = {};
    if (options.salaryMin !== undefined) salaryRange.gte = options.salaryMin;
    if (options.salaryMax !== undefined) salaryRange.lte = options.salaryMax;
    filter.push({ range: { salaryMax: salaryRange } });
  }

  if (options.company) {
    filter.push({ match_phrase: { companyName: options.company } });
  }

  if (options.postedAfter) {
    filter.push({ range: { createdAt: { gte: options.postedAfter } } });
  }

  const from = (options.page - 1) * options.limit;

  const queryBody =
    must.length > 0
      ? { bool: { must, filter } }
      : { bool: { filter } };

  const response = await esClient.search({
    index: JOBS_INDEX,
    query: queryBody as never,
    from,
    size: options.limit,
    sort: buildSort(options.sort, must.length > 0),
    track_scores: must.length > 0,
  });

  const hits = response.hits.hits;

  const rawScores = hits.map((hit) =>
    typeof hit._score === 'number' ? hit._score : 0,
  );
  const topScore = rawScores.length > 0 ? Math.max(...rawScores) : 0;

  const jobs: JobSearchHit[] = hits.map((hit, index) => {
    const src = hit._source as Record<string, unknown>;
    const rawScore = rawScores[index];
    const matchScore =
      topScore > 0 && rawScore > 0
        ? Math.min(100, Math.round((rawScore / topScore) * 100))
        : null;

    return {
      id: src.id as number,
      companyId: src.companyId as number,
      title: src.title as string,
      description: src.description as string,
      location: (src.location as string) ?? '',
      workingModel: src.workingModel as string,
      jobType: src.jobType as string,
      experienceLevel: src.experienceLevel as string,
      salaryMin: (src.salaryMin as number | null) ?? null,
      salaryMax: (src.salaryMax as number | null) ?? null,
      companyName: src.companyName as string,
      companyLogoUrl: (src.companyLogoUrl as string | null) ?? null,
      status: src.status as string,
      createdAt: src.createdAt as string,
      score: typeof hit._score === 'number' ? hit._score : null,
      matchScore,
    };
  });

  const totalField = response.hits.total;
  const total =
    typeof totalField === 'number'
      ? totalField
      : typeof totalField === 'object' && totalField !== null
        ? totalField.value
        : 0;

  return { jobs, total, page: options.page, limit: options.limit };
}