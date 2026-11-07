import { Request, Response, NextFunction } from 'express';

import {
  countUnreadForUser,
  findNotificationsByUser,
  markAllRead,
  markNotificationRead,
  NotificationRecord,
} from '../models/notificationModel';
import { failure, success } from '../utils/response';

function toNotificationResponse(n: NotificationRecord) {
  return {
    id: n.id,
    title: n.title,
    message: n.message,
    type: n.type,
    relatedId: n.related_id,
    isRead: n.is_read,
    createdAt: n.created_at,
  };
}

export async function listMyNotifications(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const notifications = await findNotificationsByUser(userId);
    const unreadCount = await countUnreadForUser(userId);

    success(res, {
      notifications: notifications.map(toNotificationResponse),
      unreadCount,
    });
  } catch (error) {
    next(error);
  }
}

export async function getUnreadCount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const count = await countUnreadForUser(userId);
    success(res, { unreadCount: count });
  } catch (error) {
    next(error);
  }
}

export async function markRead(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    const idParam = req.params.id;
    const idString = Array.isArray(idParam) ? idParam[0] : idParam;
    const notificationId = parseInt(idString, 10);

    if (!Number.isInteger(notificationId) || notificationId < 1) {
      failure(res, 'Invalid notification id', 400);
      return;
    }

    const updated = await markNotificationRead(notificationId, userId);
    if (!updated) {
      failure(res, 'Notification not found', 404);
      return;
    }

    success(res, { message: 'Marked as read' });
  } catch (error) {
    next(error);
  }
}

export async function markAll(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user?.id;
    if (!userId) {
      failure(res, 'Authentication required', 401);
      return;
    }

    await markAllRead(userId);
    success(res, { message: 'All notifications marked as read' });
  } catch (error) {
    next(error);
  }
}