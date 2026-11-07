import { createNotification } from '../models/notificationModel';
import { findCompanyById } from '../models/companyModel';
import { findJobByIdWithCompany } from '../models/jobModel';

const PRETTY_STATUS: Record<string, string> = {
  APPLIED: 'Applied',
  REVIEWING: 'Reviewing',
  SHORTLISTED: 'Shortlisted',
  INTERVIEW: 'Interview',
  HIRED: 'Hired',
  REJECTED: 'Not selected',
};

export async function notifyNewApplication(
  companyId: number,
  applicantName: string,
  jobTitle: string,
  applicationId: number,
): Promise<void> {
  try {
    const company = await findCompanyById(companyId);
    if (!company) return;

    await createNotification({
      userId: company.owner_id,
      title: 'New application received',
      message: `${applicantName} applied for ${jobTitle}`,
      type: 'NEW_APPLICATION',
      relatedId: applicationId,
    });
  } catch (error) {
    console.error('[notification] Failed to notify new application:', error);
  }
}

export async function notifyApplicationStatus(
  seekerUserId: number,
  jobId: number,
  newStatus: string,
  applicationId: number,
): Promise<void> {
  try {
    const job = await findJobByIdWithCompany(jobId);
    if (!job) return;

    await createNotification({
      userId: seekerUserId,
      title: 'Application status updated',
      message: `Your application for ${job.title} is now ${PRETTY_STATUS[newStatus] ?? newStatus}`,
      type: 'APPLICATION_STATUS',
      relatedId: applicationId,
    });
  } catch (error) {
    console.error('[notification] Failed to notify status change:', error);
  }
}