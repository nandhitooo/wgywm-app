import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your\nAccount'**
  String get loginToAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @kCal.
  ///
  /// In en, this message translates to:
  /// **'kCal'**
  String get kCal;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY PROGRESS'**
  String get weeklyProgress;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITIES'**
  String get recentActivities;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noActivitiesToday.
  ///
  /// In en, this message translates to:
  /// **'No activities yet today.'**
  String get noActivitiesToday;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bahasaIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesia;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dash.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get dash;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @joinUsToday.
  ///
  /// In en, this message translates to:
  /// **'JOIN US TODAY'**
  String get joinUsToday;

  /// No description provided for @registerYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Your\nAccount'**
  String get registerYourAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype Password'**
  String get retypePassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Success!'**
  String get registrationSuccess;

  /// No description provided for @accountCreatedLogin.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created.\nPlease login to continue.'**
  String get accountCreatedLogin;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'LOGIN NOW'**
  String get loginNow;

  /// No description provided for @pickBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Pick birth date'**
  String get pickBirthDate;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get allFieldsRequired;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordNotMatch;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROFILE'**
  String get saveProfile;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get changeName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pickProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick Profile Photo'**
  String get pickProfilePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @autoCalculatedHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculated from duration and weight'**
  String get autoCalculatedHint;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @caloriesLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Calories Last 7 Days'**
  String get caloriesLast7Days;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @resetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get resetPasswordEmailSent;

  /// No description provided for @resetPasswordConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'We will send password reset instructions to {email}. Continue?'**
  String resetPasswordConfirmMsg(String email);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @historyActivities.
  ///
  /// In en, this message translates to:
  /// **'HISTORY ACTIVITIES'**
  String get historyActivities;

  /// No description provided for @logYourWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log your workout'**
  String get logYourWorkout;

  /// No description provided for @noActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet.'**
  String get noActivities;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivity;

  /// No description provided for @deleteActivity.
  ///
  /// In en, this message translates to:
  /// **'Delete Activity'**
  String get deleteActivity;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @workoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutName;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @repsOptional.
  ///
  /// In en, this message translates to:
  /// **'Reps (optional)'**
  String get repsOptional;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @chooseWorkoutType.
  ///
  /// In en, this message translates to:
  /// **'Choose Workout Type'**
  String get chooseWorkoutType;

  /// No description provided for @customWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Custom Workout Name'**
  String get customWorkoutName;

  /// No description provided for @addActivities.
  ///
  /// In en, this message translates to:
  /// **'ADD ACTIVITIES'**
  String get addActivities;

  /// No description provided for @saveActivity.
  ///
  /// In en, this message translates to:
  /// **'SAVE ACTIVITY'**
  String get saveActivity;

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'Activity saved!'**
  String get activitySaved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @pickWorkoutType.
  ///
  /// In en, this message translates to:
  /// **'Choose workout type or enter a name.'**
  String get pickWorkoutType;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?\nThis action cannot be undone.'**
  String deleteConfirmation(Object name);

  /// No description provided for @strengthTraining.
  ///
  /// In en, this message translates to:
  /// **'Strength Training'**
  String get strengthTraining;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @coreFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Core & Flexibility'**
  String get coreFlexibility;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @hiit.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get hiit;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @danceFun.
  ///
  /// In en, this message translates to:
  /// **'Dance & Fun'**
  String get danceFun;

  /// No description provided for @combat.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get combat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
