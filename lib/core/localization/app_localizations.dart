import 'package:flutter/material.dart';
import 'app_language.dart';
import 'app_language_provider.dart';

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  static AppLocalizations of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_AppLocalizationsScope>();
    if (inherited != null) {
      return inherited.localizations;
    }
    return AppLocalizations(AppLanguageProvider.instance.currentLanguage);
  }

  static AppLocalizations current([AppLanguage? lang]) {
    return AppLocalizations(lang ?? AppLanguageProvider.instance.currentLanguage);
  }

  // ---------------------------------------------------------------------------
  // Navigation Bar (ExplorerFooter)
  // ---------------------------------------------------------------------------
  String get navHome => switch (language) {
    AppLanguage.sinhala => 'මුල් පිටුව',
    AppLanguage.tamil => 'முகப்பு',
    AppLanguage.english => 'Home',
  };

  String get navExplore => switch (language) {
    AppLanguage.sinhala => 'ගවේෂණය',
    AppLanguage.tamil => 'ஆராய்க',
    AppLanguage.english => 'Explore',
  };

  String get navQuestions => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්න',
    AppLanguage.tamil => 'கேள்விகள்',
    AppLanguage.english => 'Questions',
  };

  String get navCapsule => switch (language) {
    AppLanguage.sinhala => 'කරලිය',
    AppLanguage.tamil => 'காப்ஸ்யூல்',
    AppLanguage.english => 'Capsule',
  };

  // ---------------------------------------------------------------------------
  // Sidebar / Drawer (HomeDrawer)
  // ---------------------------------------------------------------------------
  String get sectionMain => switch (language) {
    AppLanguage.sinhala => 'ප්‍රධාන',
    AppLanguage.tamil => 'முக்கியம்',
    AppLanguage.english => 'Main',
  };

  String get sectionSaved => switch (language) {
    AppLanguage.sinhala => 'සුරකින ලද',
    AppLanguage.tamil => 'சேமிக்கப்பட்டவை',
    AppLanguage.english => 'Saved',
  };

  String get drawerProfile => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ',
    AppLanguage.tamil => 'சுயவிவரம்',
    AppLanguage.english => 'Profile',
  };

  String get drawerViewProfile => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ බලන්න',
    AppLanguage.tamil => 'சுயவிவரத்தைப் பார்க்க',
    AppLanguage.english => 'View Profile',
  };

  String get drawerHome => switch (language) {
    AppLanguage.sinhala => 'මුල් පිටුව',
    AppLanguage.tamil => 'முகப்பு',
    AppLanguage.english => 'Home',
  };

  String get drawerExplorePlaces => switch (language) {
    AppLanguage.sinhala => 'ස්ථාන ගවේෂණය',
    AppLanguage.tamil => 'இடங்களை ஆராய்க',
    AppLanguage.english => 'Explore Places',
  };

  String get drawerQaForum => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්න සහ පිළිතුරු',
    AppLanguage.tamil => 'கேள்வி பதில் மன்றம்',
    AppLanguage.english => 'Q&A Forum',
  };

  String get drawerTimeCapsule => switch (language) {
    AppLanguage.sinhala => 'කාල කරලිය',
    AppLanguage.tamil => 'நேர காப்ஸ்யூல்',
    AppLanguage.english => 'Time capsule',
  };

  String get drawerLatestEvents => switch (language) {
    AppLanguage.sinhala => 'නවතම සිදුවීම්',
    AppLanguage.tamil => 'சமீபத்திய நிகழ்வுகள்',
    AppLanguage.english => 'Latest Events',
  };

  String get drawerTranslation => switch (language) {
    AppLanguage.sinhala => 'පරිවර්තනය',
    AppLanguage.tamil => 'மொழிபெயர்ப்பு',
    AppLanguage.english => 'Translation',
  };

  String get drawerQuizzes => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්නාවලි',
    AppLanguage.tamil => 'வினாடி வினாக்கள்',
    AppLanguage.english => 'Quizzes',
  };

  String get drawerSavedPosts => switch (language) {
    AppLanguage.sinhala => 'සුරකින ලද සටහන්',
    AppLanguage.tamil => 'சேமிக்கப்பட்ட பதிவுகள்',
    AppLanguage.english => 'Saved posts',
  };

  String get drawerFavouritePlaces => switch (language) {
    AppLanguage.sinhala => 'ප්‍රියතම ස්ථාන',
    AppLanguage.tamil => 'விருப்பமான இடங்கள்',
    AppLanguage.english => 'Favourite places',
  };

  String get drawerCreatedTimeCapsules => switch (language) {
    AppLanguage.sinhala => 'සාදන ලද කාල කරල්',
    AppLanguage.tamil => 'உருவாக்கப்பட்ட நேர காப்ஸ்யூல்கள்',
    AppLanguage.english => 'Created Time Capsules',
  };

  String get drawerExplore3dMap => switch (language) {
    AppLanguage.sinhala => 'ත්‍රිමාණ සිතියමෙන් ගවේෂණය',
    AppLanguage.tamil => '3D வரைபடத்துடன் ஆராய்க',
    AppLanguage.english => 'Explore Things With 3D Map',
  };

  String get drawerSettings => switch (language) {
    AppLanguage.sinhala => 'සැකසීම්',
    AppLanguage.tamil => 'அமைப்புகள்',
    AppLanguage.english => 'Settings',
  };

  String get drawerLogOut => switch (language) {
    AppLanguage.sinhala => 'ඉවත් වන්න',
    AppLanguage.tamil => 'வெளியேறு',
    AppLanguage.english => 'Log Out',
  };

  String get drawerLanguage => switch (language) {
    AppLanguage.sinhala => 'භාෂාව',
    AppLanguage.tamil => 'மொழி',
    AppLanguage.english => 'Language',
  };

  String get copyrightNotice => switch (language) {
    AppLanguage.sinhala => '2026 සියලු හිමිකම් ඇවිරිණි\nV.2.1.1',
    AppLanguage.tamil => '2026 அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை\nV.2.1.1',
    AppLanguage.english => '2026 All Right Received\nV.2.1.1',
  };

  // ---------------------------------------------------------------------------
  // Settings Screen
  // ---------------------------------------------------------------------------
  String get settingsTitle => switch (language) {
    AppLanguage.sinhala => 'සැකසීම්',
    AppLanguage.tamil => 'அமைப்புகள்',
    AppLanguage.english => 'Settings',
  };

  String get makeRootlyYours => switch (language) {
    AppLanguage.sinhala => 'Rootly ඔබේ කරගන්න',
    AppLanguage.tamil => 'Rootly ஐ உங்கள் விருப்பப்படி மாற்றவும்',
    AppLanguage.english => 'Make Rootly yours',
  };

  String get manageAccountAndPreferences => switch (language) {
    AppLanguage.sinhala => 'ඔබේ ගිණුම සහ මනාප කළමනාකරණය කරන්න.',
    AppLanguage.tamil => 'உங்கள் கணக்கு மற்றும் விருப்பங்களை நிர்வகிக்கவும்.',
    AppLanguage.english => 'Manage your account and preferences.',
  };

  String get sectionLanguage => switch (language) {
    AppLanguage.sinhala => 'භාෂාව',
    AppLanguage.tamil => 'மொழி',
    AppLanguage.english => 'LANGUAGE',
  };

  String get appLanguageTitle => switch (language) {
    AppLanguage.sinhala => 'යෙදුමේ භාෂාව',
    AppLanguage.tamil => 'பயன்பாட்டு மொழி',
    AppLanguage.english => 'App Language',
  };

  String get selectLanguageTitle => switch (language) {
    AppLanguage.sinhala => 'භාෂාව තෝරන්න',
    AppLanguage.tamil => 'மொழியைத் தேர்ந்தெடுக்கவும்',
    AppLanguage.english => 'Select Language',
  };

  String get choosePreferredLanguage => switch (language) {
    AppLanguage.sinhala => 'ඔබ කැමති භාෂාව තෝරන්න',
    AppLanguage.tamil => 'விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்',
    AppLanguage.english => 'Choose your preferred language',
  };

  String get sectionAccount => switch (language) {
    AppLanguage.sinhala => 'ගිණුම',
    AppLanguage.tamil => 'கணக்கு',
    AppLanguage.english => 'ACCOUNT',
  };

  String get myProfile => switch (language) {
    AppLanguage.sinhala => 'මගේ පැතිකඩ',
    AppLanguage.tamil => 'என் சுயவிவரம்',
    AppLanguage.english => 'My profile',
  };

  String get changePassword => switch (language) {
    AppLanguage.sinhala => 'මුරපදය වෙනස් කරන්න',
    AppLanguage.tamil => 'கடவுச்சொல்லை மாற்றுக',
    AppLanguage.english => 'Change password',
  };

  String get sectionPreferences => switch (language) {
    AppLanguage.sinhala => 'මනාපයන්',
    AppLanguage.tamil => 'விருப்பத்தேர்வுகள்',
    AppLanguage.english => 'PREFERENCES',
  };

  String get notificationsTitle => switch (language) {
    AppLanguage.sinhala => 'දැනුම්දීම්',
    AppLanguage.tamil => 'அறிவிப்புகள்',
    AppLanguage.english => 'Notifications',
  };

  String get notificationsSubtitle => switch (language) {
    AppLanguage.sinhala => 'කථා සහ ප්‍රජා යාවත්කාලීන ලබාගන්න',
    AppLanguage.tamil => 'கதை மற்றும் சமூக புதுப்பிப்புகளைப் பெறுக',
    AppLanguage.english => 'Receive story and community updates',
  };

  String get activityStatusTitle => switch (language) {
    AppLanguage.sinhala => 'ක්‍රියාකාරකම් තත්ත්වය',
    AppLanguage.tamil => 'செயல்பாட்டு நிலை',
    AppLanguage.english => 'Activity status',
  };

  String get activityStatusSubtitle => switch (language) {
    AppLanguage.sinhala => 'ඔබ සක්‍රියව සිටින විට අන් අයට පෙන්වන්න',
    AppLanguage.tamil => 'நீங்கள் செயலில் இருக்கும்போது மற்றவர்கள் பார்க்க அனுமதிக்கவும்',
    AppLanguage.english => 'Let others see when you are active',
  };

  String get logOutButton => switch (language) {
    AppLanguage.sinhala => 'ඉවත් වන්න',
    AppLanguage.tamil => 'வெளியேறு',
    AppLanguage.english => 'Log out',
  };

  String get rootlyTagline => switch (language) {
    AppLanguage.sinhala => 'Rootly • සංස්කෘතිය ගවේෂණය කරන්න. ඔබේ කතාව බෙදාගන්න.',
    AppLanguage.tamil => 'Rootly • கலாச்சாரத்தை ஆராயுங்கள். உங்கள் கதையைப் பகிருங்கள்.',
    AppLanguage.english => 'Rootly • Explore culture. Share your story.',
  };

  String get couldNotSavePreference => switch (language) {
    AppLanguage.sinhala => 'ඔබගේ මනාපය සුරැකීමට නොහැකි විය. නැවත උත්සාහ කරන්න.',
    AppLanguage.tamil => 'விருப்பத்தைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
    AppLanguage.english => 'Could not save your preference. Please try again.',
  };

  // ---------------------------------------------------------------------------
  // Profile Section
  // ---------------------------------------------------------------------------
  String get editProfileData => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ සංස්කරණය',
    AppLanguage.tamil => 'சுயவிவரத்தை திருத்து',
    AppLanguage.english => 'Edit Profile Data',
  };

  String get profileSettingsTooltip => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ සැකසීම්',
    AppLanguage.tamil => 'சுயவிவர அமைப்புகள்',
    AppLanguage.english => 'Profile settings',
  };

  String get changeProfilePhotoTooltip => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ ඡායාරූපය වෙනස් කරන්න',
    AppLanguage.tamil => 'சுயவிவரப் படத்தை மாற்றுக',
    AppLanguage.english => 'Change profile photo',
  };

  String get changeCoverPhotoTooltip => switch (language) {
    AppLanguage.sinhala => 'කවර ඡායාරූපය වෙනස් කරන්න',
    AppLanguage.tamil => 'அட்டைப் படத்தை மாற்றுக',
    AppLanguage.english => 'Change cover photo',
  };

  String get postsLabel => switch (language) {
    AppLanguage.sinhala => 'සටහන්',
    AppLanguage.tamil => 'பதிவுகள்',
    AppLanguage.english => 'Posts',
  };

  String get followersLabel => switch (language) {
    AppLanguage.sinhala => 'අනුගාමිකයන්',
    AppLanguage.tamil => 'பின்தொடர்பவர்கள்',
    AppLanguage.english => 'Followers',
  };

  String get followingLabel => switch (language) {
    AppLanguage.sinhala => 'අනුගමනය කරන',
    AppLanguage.tamil => 'பின்தொடர்பவை',
    AppLanguage.english => 'Following',
  };

  String get createCollection => switch (language) {
    AppLanguage.sinhala => 'එකතුවක් සාදන්න',
    AppLanguage.tamil => 'தொகுப்பை உருவாக்கு',
    AppLanguage.english => 'Create Collection',
  };

  String get collectionName => switch (language) {
    AppLanguage.sinhala => 'එකතුවේ නම',
    AppLanguage.tamil => 'தொகுப்பின் பெயர்',
    AppLanguage.english => 'Collection name',
  };

  String get cancel => switch (language) {
    AppLanguage.sinhala => 'අවලංගු කරන්න',
    AppLanguage.tamil => 'ரத்து செய்',
    AppLanguage.english => 'Cancel',
  };

  String get create => switch (language) {
    AppLanguage.sinhala => 'සාදන්න',
    AppLanguage.tamil => 'உருவாக்கு',
    AppLanguage.english => 'Create',
  };

  String get save => switch (language) {
    AppLanguage.sinhala => 'සුරකින්න',
    AppLanguage.tamil => 'சேமி',
    AppLanguage.english => 'Save',
  };

  String get profileInformation => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ තොරතුරු',
    AppLanguage.tamil => 'சுயவிவரத் தகவல்',
    AppLanguage.english => 'Profile information',
  };

  String get nameLabel => switch (language) {
    AppLanguage.sinhala => 'නම',
    AppLanguage.tamil => 'பெயர்',
    AppLanguage.english => 'Name',
  };

  String get handleLabel => switch (language) {
    AppLanguage.sinhala => 'හැඳුනුම',
    AppLanguage.tamil => 'கைப்பிடி',
    AppLanguage.english => 'Handle',
  };

  String get bioLabel => switch (language) {
    AppLanguage.sinhala => 'විස්තරය',
    AppLanguage.tamil => 'சுயகுறிப்பு',
    AppLanguage.english => 'Bio',
  };

  String get locationLabel => switch (language) {
    AppLanguage.sinhala => 'ස්ථානය / දිස්ත්‍රික්කය',
    AppLanguage.tamil => 'இடம் / மாவட்டம்',
    AppLanguage.english => 'Location',
  };

  String get saveChanges => switch (language) {
    AppLanguage.sinhala => 'වෙනස්කම් සුරකින්න',
    AppLanguage.tamil => 'மாற்றங்களைச் சேமிக்க',
    AppLanguage.english => 'Save Changes',
  };

  String get postDeleted => switch (language) {
    AppLanguage.sinhala => 'සටහන මකා දමන ලදී.',
    AppLanguage.tamil => 'பதிவு நீக்கப்பட்டது.',
    AppLanguage.english => 'Post deleted.',
  };

  String get draftSaved => switch (language) {
    AppLanguage.sinhala => 'කෙටුම්පත සුරකින ලදී. ඔබගේ පැතිකඩෙන් එය දිගටම සංස්කරණය කළ හැක.',
    AppLanguage.tamil => 'வரைவு சேமிக்கப்பட்டது. சுயவிவரத்தில் இருந்து தொடர்ந்து திருத்தலாம்.',
    AppLanguage.english => 'Draft saved. You can continue editing it from your profile.',
  };

  String get postSaved => switch (language) {
    AppLanguage.sinhala => 'සටහන සුරකින ලදී.',
    AppLanguage.tamil => 'பதிவு சேமிக்கப்பட்டது.',
    AppLanguage.english => 'Post saved.',
  };

  String get profilePhotoUpdated => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ ඡායාරූපය යාවත්කාලීන කරන ලදී.',
    AppLanguage.tamil => 'சுயவிவரப் படம் புதுப்பிக்கப்பட்டது.',
    AppLanguage.english => 'Profile photo updated.',
  };

  String get coverPhotoUpdated => switch (language) {
    AppLanguage.sinhala => 'කවර ඡායාරූපය යාවත්කාලීන කරන ලදී.',
    AppLanguage.tamil => 'அட்டைப் படம் புதுப்பிக்கப்பட்டது.',
    AppLanguage.english => 'Cover photo updated.',
  };

  String get photoUpdateFailed => switch (language) {
    AppLanguage.sinhala => 'ඡායාරූපය යාවත්කාලීන කිරීමට නොහැකි විය. නැවත උත්සාහ කරන්න.',
    AppLanguage.tamil => 'படத்தைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
    AppLanguage.english => 'Could not update the photo. Please try again.',
  };

  String get profileLoadFailed => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ දත්ත පූරණය කිරීමට නොහැකි විය.',
    AppLanguage.tamil => 'சுயவிவரத் தரவை ஏற்றுவதில் தோல்வி.',
    AppLanguage.english => 'Failed to load profile data.',
  };

  String get profileUpdateFailed => switch (language) {
    AppLanguage.sinhala => 'පැතිකඩ යාවත්කාලීන කිරීමට නොහැකි විය.',
    AppLanguage.tamil => 'சுயவிவரத்தைப் புதுப்பிக்க முடியவில்லை.',
    AppLanguage.english => 'Failed to update profile.',
  };

  // ---------------------------------------------------------------------------
  // App Bar & Home & Global Actions
  // ---------------------------------------------------------------------------
  String get openMenuTooltip => switch (language) {
    AppLanguage.sinhala => 'මෙනුව විවෘත කරන්න',
    AppLanguage.tamil => 'பட்டியலைத் திறக்கவும்',
    AppLanguage.english => 'Open menu',
  };

  String get notificationsTooltip => switch (language) {
    AppLanguage.sinhala => 'දැනුම්දීම්',
    AppLanguage.tamil => 'அறிவிப்புகள்',
    AppLanguage.english => 'Notifications',
  };

  String get switchLanguageTooltip => switch (language) {
    AppLanguage.sinhala => 'භාෂාව මාරු කරන්න',
    AppLanguage.tamil => 'மொழியை மாற்றுக',
    AppLanguage.english => 'Switch language',
  };

  String get searchHint => switch (language) {
    AppLanguage.sinhala => 'සොයන්න...',
    AppLanguage.tamil => 'தேடுக...',
    AppLanguage.english => 'Search...',
  };

  String get noPostsYet => switch (language) {
    AppLanguage.sinhala => 'තවම සටහන් කිසිවක් නැත.',
    AppLanguage.tamil => 'இன்னும் பதிவுகள் இல்லை.',
    AppLanguage.english => 'No posts yet.',
  };

  String get loading => switch (language) {
    AppLanguage.sinhala => 'පූරණය වෙමින්...',
    AppLanguage.tamil => 'ஏற்றுகிறது...',
    AppLanguage.english => 'Loading...',
  };

  String get markAllAsRead => switch (language) {
    AppLanguage.sinhala => 'සියල්ල කියවූ ලෙස සලකුණු කරන්න',
    AppLanguage.tamil => 'அனைத்தையும் படித்ததாகக் குறிக்கவும்',
    AppLanguage.english => 'Mark all as read',
  };

  String get allNotificationsMarkedAsRead => switch (language) {
    AppLanguage.sinhala => 'සියලු දැනුම්දීම් කියවූ ලෙස සලකුණු කරන ලදී',
    AppLanguage.tamil => 'அனைத்து அறிவிப்புகளும் படித்ததாகக் குறிக்கப்பட்டன',
    AppLanguage.english => 'All notifications marked as read',
  };
}

class _AppLocalizationsScope extends InheritedWidget {
  const _AppLocalizationsScope({
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  @override
  bool updateShouldNotify(_AppLocalizationsScope oldWidget) =>
      localizations.language != oldWidget.localizations.language;
}

class AppLocalizationsProvider extends StatelessWidget {
  const AppLocalizationsProvider({
    super.key,
    required this.language,
    required this.child,
  });

  final AppLanguage language;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AppLocalizationsScope(
      localizations: AppLocalizations(language),
      child: child,
    );
  }
}
