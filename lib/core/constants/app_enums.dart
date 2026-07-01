// lib/core/constants/app_enums.dart
// WHY: Typed enums for roles, permissions, post categories, and statuses.

enum UserRole {
  superAdmin,
  subAdmin,
  volunteer,
  guest;

  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isSubAdmin => this == UserRole.subAdmin;
  bool get isVolunteer => this == UserRole.volunteer;

  static UserRole fromString(String value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'sub_admin':
        return UserRole.subAdmin;
      case 'volunteer':
        return UserRole.volunteer;
      default:
        return UserRole.guest;
    }
  }

  String get toFirestore {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.subAdmin:
        return 'sub_admin';
      case UserRole.volunteer:
        return 'volunteer';
      case UserRole.guest:
        return 'guest';
    }
  }
}

enum PostCategory {
  general,
  medical,
  urgent,
  event,
  workshopNotice;

  static PostCategory fromString(String value) {
    switch (value) {
      case 'medical':
        return PostCategory.medical;
      case 'urgent':
        return PostCategory.urgent;
      case 'event':
        return PostCategory.event;
      case 'workshop_notice':
        return PostCategory.workshopNotice;
      default:
        return PostCategory.general;
    }
  }

  String get toFirestore {
    switch (this) {
      case PostCategory.general:
        return 'general';
      case PostCategory.medical:
        return 'medical';
      case PostCategory.urgent:
        return 'urgent';
      case PostCategory.event:
        return 'event';
      case PostCategory.workshopNotice:
        return 'workshop_notice';
    }
  }
}

enum WorkshopStatus {
  upcoming,
  active,
  completed,
  cancelled;

  static WorkshopStatus fromString(String value) {
    switch (value) {
      case 'active':
        return WorkshopStatus.active;
      case 'completed':
        return WorkshopStatus.completed;
      case 'cancelled':
        return WorkshopStatus.cancelled;
      default:
        return WorkshopStatus.upcoming;
    }
  }

  String get toFirestore {
    switch (this) {
      case WorkshopStatus.upcoming:
        return 'upcoming';
      case WorkshopStatus.active:
        return 'active';
      case WorkshopStatus.completed:
        return 'completed';
      case WorkshopStatus.cancelled:
        return 'cancelled';
    }
  }
}

enum AttendanceStatus {
  notRecorded,
  present,
  absent;

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.notRecorded;
    }
  }

  String get toFirestore {
    switch (this) {
      case AttendanceStatus.notRecorded:
        return 'not_recorded';
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  String get toFirestore {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }
}

enum NotificationType {
  post,
  workshop,
  detachment,
  system;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'workshop':
        return NotificationType.workshop;
      case 'detachment':
        return NotificationType.detachment;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.post;
    }
  }

  String get toFirestore => name;
}