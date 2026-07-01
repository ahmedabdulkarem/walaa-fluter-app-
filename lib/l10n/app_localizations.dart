import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Al-Walaa Medical Team'**
  String get appName;

  /// No description provided for @appNameShort.
  ///
  /// In en, this message translates to:
  /// **'Al-Walaa'**
  String get appNameShort;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'ltr'**
  String get direction;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorAuth;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorPermission;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid input data.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorSessionExpired;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @loginAs.
  ///
  /// In en, this message translates to:
  /// **'Login as'**
  String get loginAs;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @sessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get sessionDuration;

  /// No description provided for @session6h.
  ///
  /// In en, this message translates to:
  /// **'6 Hours'**
  String get session6h;

  /// No description provided for @session7h.
  ///
  /// In en, this message translates to:
  /// **'7 Hours'**
  String get session7h;

  /// No description provided for @session8h.
  ///
  /// In en, this message translates to:
  /// **'8 Hours'**
  String get session8h;

  /// No description provided for @accountExpired.
  ///
  /// In en, this message translates to:
  /// **'Account Expired'**
  String get accountExpired;

  /// No description provided for @accountExpiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Your admin account has expired. Please contact the super admin.'**
  String get accountExpiredDesc;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. You will need to log in again.'**
  String get sessionExpiredDesc;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get roleSuperAdmin;

  /// No description provided for @roleSubAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sub Admin'**
  String get roleSubAdmin;

  /// No description provided for @roleVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get roleVolunteer;

  /// No description provided for @roleGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get roleGuest;

  /// No description provided for @permPublishPosts.
  ///
  /// In en, this message translates to:
  /// **'Publish Posts'**
  String get permPublishPosts;

  /// No description provided for @permEditDeletePosts.
  ///
  /// In en, this message translates to:
  /// **'Edit/Delete Posts'**
  String get permEditDeletePosts;

  /// No description provided for @permManageDetachment.
  ///
  /// In en, this message translates to:
  /// **'Manage Detachment'**
  String get permManageDetachment;

  /// No description provided for @permRecordDetachmentShifts.
  ///
  /// In en, this message translates to:
  /// **'Record Detachment Shifts'**
  String get permRecordDetachmentShifts;

  /// No description provided for @permAddPatientStats.
  ///
  /// In en, this message translates to:
  /// **'Add Patient Stats'**
  String get permAddPatientStats;

  /// No description provided for @permManageWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Manage Workshops'**
  String get permManageWorkshops;

  /// No description provided for @permAddWorkshopAttendees.
  ///
  /// In en, this message translates to:
  /// **'Add Workshop Attendees'**
  String get permAddWorkshopAttendees;

  /// No description provided for @permConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get permConfirmPayment;

  /// No description provided for @permRecordWorkshopAttendance.
  ///
  /// In en, this message translates to:
  /// **'Record Workshop Attendance'**
  String get permRecordWorkshopAttendance;

  /// No description provided for @permViewGeneralStats.
  ///
  /// In en, this message translates to:
  /// **'View General Stats'**
  String get permViewGeneralStats;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @statsSummary.
  ///
  /// In en, this message translates to:
  /// **'Stats Summary'**
  String get statsSummary;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @postBody.
  ///
  /// In en, this message translates to:
  /// **'Post Content'**
  String get postBody;

  /// No description provided for @postCategory.
  ///
  /// In en, this message translates to:
  /// **'Post Category'**
  String get postCategory;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @pinPost.
  ///
  /// In en, this message translates to:
  /// **'Pin Post'**
  String get pinPost;

  /// No description provided for @unpinPost.
  ///
  /// In en, this message translates to:
  /// **'Unpin Post'**
  String get unpinPost;

  /// No description provided for @markUrgent.
  ///
  /// In en, this message translates to:
  /// **'Mark as Urgent'**
  String get markUrgent;

  /// No description provided for @unmarkUrgent.
  ///
  /// In en, this message translates to:
  /// **'Remove Urgent'**
  String get unmarkUrgent;

  /// No description provided for @pinnedPosts.
  ///
  /// In en, this message translates to:
  /// **'Pinned Posts'**
  String get pinnedPosts;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts'**
  String get noPosts;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get categoryMedical;

  /// No description provided for @categoryUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get categoryUrgent;

  /// No description provided for @categoryEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get categoryEvent;

  /// No description provided for @categoryWorkshopNotice.
  ///
  /// In en, this message translates to:
  /// **'Workshop Notice'**
  String get categoryWorkshopNotice;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get urgent;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @teamInfo.
  ///
  /// In en, this message translates to:
  /// **'Team Info'**
  String get teamInfo;

  /// No description provided for @aboutTeam.
  ///
  /// In en, this message translates to:
  /// **'About the Team'**
  String get aboutTeam;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @vision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get vision;

  /// No description provided for @values.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get values;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @leadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get leadership;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @fieldActivities.
  ///
  /// In en, this message translates to:
  /// **'Field Activities'**
  String get fieldActivities;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @detachment.
  ///
  /// In en, this message translates to:
  /// **'Detachment'**
  String get detachment;

  /// No description provided for @detachmentDay.
  ///
  /// In en, this message translates to:
  /// **'Detachment Day'**
  String get detachmentDay;

  /// No description provided for @noDetachmentToday.
  ///
  /// In en, this message translates to:
  /// **'No detachment today'**
  String get noDetachmentToday;

  /// No description provided for @createDetachmentDay.
  ///
  /// In en, this message translates to:
  /// **'Create Detachment Day'**
  String get createDetachmentDay;

  /// No description provided for @editDetachmentDay.
  ///
  /// In en, this message translates to:
  /// **'Edit Detachment Day'**
  String get editDetachmentDay;

  /// No description provided for @detachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Detachment Title'**
  String get detachmentTitle;

  /// No description provided for @detachmentLocation.
  ///
  /// In en, this message translates to:
  /// **'Detachment Location'**
  String get detachmentLocation;

  /// No description provided for @detachmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detachmentDescription;

  /// No description provided for @detachmentDate.
  ///
  /// In en, this message translates to:
  /// **'Detachment Date'**
  String get detachmentDate;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @addShift.
  ///
  /// In en, this message translates to:
  /// **'Add Shift'**
  String get addShift;

  /// No description provided for @shiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift Name'**
  String get shiftLabel;

  /// No description provided for @shiftStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get shiftStartTime;

  /// No description provided for @shiftEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get shiftEndTime;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked In'**
  String get checkedIn;

  /// No description provided for @assignedAdmins.
  ///
  /// In en, this message translates to:
  /// **'Assigned Admins'**
  String get assignedAdmins;

  /// No description provided for @patientStats.
  ///
  /// In en, this message translates to:
  /// **'Patient Statistics'**
  String get patientStats;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @addPatientStats.
  ///
  /// In en, this message translates to:
  /// **'Add Patient Stats'**
  String get addPatientStats;

  /// No description provided for @patientCategory.
  ///
  /// In en, this message translates to:
  /// **'Patient Category'**
  String get patientCategory;

  /// No description provided for @patientCount.
  ///
  /// In en, this message translates to:
  /// **'Patient Count'**
  String get patientCount;

  /// No description provided for @detachmentHistory.
  ///
  /// In en, this message translates to:
  /// **'Detachment History'**
  String get detachmentHistory;

  /// No description provided for @detachmentSummary.
  ///
  /// In en, this message translates to:
  /// **'Detachment Summary'**
  String get detachmentSummary;

  /// No description provided for @workshops.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get workshops;

  /// No description provided for @workshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get workshop;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @createWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Create Workshop'**
  String get createWorkshop;

  /// No description provided for @editWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Edit Workshop'**
  String get editWorkshop;

  /// No description provided for @workshopTitle.
  ///
  /// In en, this message translates to:
  /// **'Workshop Title'**
  String get workshopTitle;

  /// No description provided for @workshopDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get workshopDesc;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @workshopLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get workshopLocation;

  /// No description provided for @workshopDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get workshopDateTime;

  /// No description provided for @workshopEndDateTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get workshopEndDateTime;

  /// No description provided for @isOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get isOnline;

  /// No description provided for @meetingLink.
  ///
  /// In en, this message translates to:
  /// **'Meeting Link'**
  String get meetingLink;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @subscriptionFee.
  ///
  /// In en, this message translates to:
  /// **'Subscription Fee'**
  String get subscriptionFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Workshop Staff'**
  String get staff;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get addStaff;

  /// No description provided for @attendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get attendees;

  /// No description provided for @addAttendee.
  ///
  /// In en, this message translates to:
  /// **'Add Attendee'**
  String get addAttendee;

  /// No description provided for @attendeeName.
  ///
  /// In en, this message translates to:
  /// **'Attendee Name'**
  String get attendeeName;

  /// No description provided for @allAttendees.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAttendees;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @copyNames.
  ///
  /// In en, this message translates to:
  /// **'Copy Names'**
  String get copyNames;

  /// No description provided for @namesCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} names copied'**
  String namesCopied(Object count);

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @notPaid.
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get notPaid;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @markPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark Present'**
  String get markPresent;

  /// No description provided for @markAbsent.
  ///
  /// In en, this message translates to:
  /// **'Mark Absent'**
  String get markAbsent;

  /// No description provided for @attendanceStatus.
  ///
  /// In en, this message translates to:
  /// **'Attendance Status'**
  String get attendanceStatus;

  /// No description provided for @totalRegistered.
  ///
  /// In en, this message translates to:
  /// **'Total Registered'**
  String get totalRegistered;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid Subscription'**
  String get totalPaid;

  /// No description provided for @totalAttended.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get totalAttended;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @cannotMarkUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Cannot mark attendance for unpaid attendee'**
  String get cannotMarkUnpaid;

  /// No description provided for @adminManagement.
  ///
  /// In en, this message translates to:
  /// **'Admin Management'**
  String get adminManagement;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @addAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add Admin'**
  String get addAdmin;

  /// No description provided for @editAdmin.
  ///
  /// In en, this message translates to:
  /// **'Edit Admin Permissions'**
  String get editAdmin;

  /// No description provided for @adminPermissions.
  ///
  /// In en, this message translates to:
  /// **'Admin Permissions'**
  String get adminPermissions;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @credentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'New Admin Credentials'**
  String get credentialsTitle;

  /// No description provided for @credentialsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get credentialsUsername;

  /// No description provided for @credentialsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get credentialsPassword;

  /// No description provided for @credentialsValidity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get credentialsValidity;

  /// No description provided for @copyUsername.
  ///
  /// In en, this message translates to:
  /// **'Copy Username'**
  String get copyUsername;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy Password'**
  String get copyPassword;

  /// No description provided for @deactivateAdmin.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Admin'**
  String get deactivateAdmin;

  /// No description provided for @reactivateAdmin.
  ///
  /// In en, this message translates to:
  /// **'Reactivate Admin'**
  String get reactivateAdmin;

  /// No description provided for @deleteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Delete Admin'**
  String get deleteAdmin;

  /// No description provided for @deleteAdminConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this admin? The account will be permanently deleted.'**
  String get deleteAdminConfirm;

  /// No description provided for @adminActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminActive;

  /// No description provided for @adminExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get adminExpired;

  /// No description provided for @adminDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get adminDeactivated;

  /// No description provided for @sessionRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get sessionRemaining;

  /// No description provided for @noAdmins.
  ///
  /// In en, this message translates to:
  /// **'No sub-admins'**
  String get noAdmins;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenter;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @ticketSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get ticketSubject;

  /// No description provided for @ticketMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get ticketMessage;

  /// No description provided for @ticketCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ticketCategory;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @ticketStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket Status'**
  String get ticketStatus;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notificationPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get notificationPost;

  /// No description provided for @notificationWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop Update'**
  String get notificationWorkshop;

  /// No description provided for @notificationDetachment.
  ///
  /// In en, this message translates to:
  /// **'Detachment Update'**
  String get notificationDetachment;

  /// No description provided for @notificationSystem.
  ///
  /// In en, this message translates to:
  /// **'System Notification'**
  String get notificationSystem;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Al-Walaa Medical Team — Internal management platform for the volunteer medical team.'**
  String get aboutDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
