import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendPasswordResetEmail(
  toEmail: string,
  resetToken: string,
): Promise<void> {
  const resetLink = `${process.env.FRONTEND_URL}/#/reset-password?token=${resetToken}`;

  const { error } = await resend.emails.send({
    from: 'JobConnect <onboarding@resend.dev>',
    to: toEmail,
    subject: 'Reset Your JobConnect Password',
    html: `
      <h2>Password Reset Request</h2>
      <p>You requested to reset your password. Click the link below to set a new password:</p>
      <a href="${resetLink}" style="background-color: #1B3CC9; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a>
      <p>This link will expire in 1 hour.</p>
      <p>If you didn't request this, please ignore this email.</p>
    `,
  });

  if (error) {
    console.error('[email] Failed to send:', error);
    throw new Error('Failed to send email');
  }
}