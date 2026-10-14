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

  // ---------------------------------------------------------------------------
  // Explore Section
  // ---------------------------------------------------------------------------
  String get exploreTitle => switch (language) {
    AppLanguage.sinhala => 'ස්ථාන ගවේෂණය',
    AppLanguage.tamil => 'இடங்களை ஆராய்க',
    AppLanguage.english => 'Explore Places',
  };

  String get exploreSearchHint => switch (language) {
    AppLanguage.sinhala => 'යුගය, කලාපය හෝ මූල පද අනුව සොයන්න...',
    AppLanguage.tamil => 'காலம், பிராந்தியம் அல்லது முக்கிய சொல் மூலம் தேடுக...',
    AppLanguage.english => 'Search places by era, region, or keyword...',
  };

  String get exploreRecommended => switch (language) {
    AppLanguage.sinhala => 'ඔබ වෙනුවෙන් නිර්දේශිතයි',
    AppLanguage.tamil => 'உங்களுக்காகப் பரிந்துரைக்கப்பட்டவை',
    AppLanguage.english => 'Recommended for You',
  };

  String get exploreSearchResults => switch (language) {
    AppLanguage.sinhala => 'සෙවුම් ප්‍රතිඵල',
    AppLanguage.tamil => 'தேடல் முடிவுகள்',
    AppLanguage.english => 'Search Results',
  };

  String get exploreJourneyBuilder => switch (language) {
    AppLanguage.sinhala => 'සංචාර සැලසුම්කරු',
    AppLanguage.tamil => 'பயணத் திட்டம்',
    AppLanguage.english => 'Journey Builder',
  };

  String get categoryAll => switch (language) {
    AppLanguage.sinhala => 'සියල්ල',
    AppLanguage.tamil => 'அனைத்தும்',
    AppLanguage.english => 'All',
  };

  String get categoryAncientRuins => switch (language) {
    AppLanguage.sinhala => 'පුරාණ නටබුන්',
    AppLanguage.tamil => 'பண்டைய இடிபாடுகள்',
    AppLanguage.english => 'Ancient Ruins',
  };

  String get categorySacredSites => switch (language) {
    AppLanguage.sinhala => 'පූජනීය ස්ථාන',
    AppLanguage.tamil => 'புனித தலங்கள்',
    AppLanguage.english => 'Sacred Sites',
  };

  String get categoryMuseums => switch (language) {
    AppLanguage.sinhala => 'කෞතුකාගාර',
    AppLanguage.tamil => 'அருங்காட்சியகங்கள்',
    AppLanguage.english => 'Museums',
  };

  String get categoryHeritageSites => switch (language) {
    AppLanguage.sinhala => 'උරුම ස්ථාන',
    AppLanguage.tamil => 'பாரம்பரிய தளங்கள்',
    AppLanguage.english => 'Heritage Sites',
  };

  String explorePlacesCount(int count) => switch (language) {
    AppLanguage.sinhala => 'ස්ථාන $count ක් ඇත',
    AppLanguage.tamil => '$count இடங்கள் உள்ளன',
    AppLanguage.english => '$count place${count == 1 ? '' : 's'}',
  };

  String get cachedData => switch (language) {
    AppLanguage.sinhala => 'හැඹිලි දත්ත',
    AppLanguage.tamil => 'தற்காலிக நினைவகத் தரவு',
    AppLanguage.english => 'Cached data',
  };

  String get partialResults => switch (language) {
    AppLanguage.sinhala => 'අසම්පූර්ණ ප්‍රතිඵල',
    AppLanguage.tamil => 'பகுதி முடிவுகள்',
    AppLanguage.english => 'Partial results',
  };

  String get planJourney => switch (language) {
    AppLanguage.sinhala => 'ගමන සැලසුම් කරන්න',
    AppLanguage.tamil => 'பயணத்தைத் திட்டமிடுங்கள்',
    AppLanguage.english => 'Plan Journey',
  };

  String get overview => switch (language) {
    AppLanguage.sinhala => 'දළ විශ්ලේෂණය',
    AppLanguage.tamil => 'கண்ணோட்டம்',
    AppLanguage.english => 'Overview',
  };

  String get historicalEra => switch (language) {
    AppLanguage.sinhala => 'ඓතිහාසික යුගය',
    AppLanguage.tamil => 'வரலாற்று காலம்',
    AppLanguage.english => 'Historical Era',
  };

  String get location => switch (language) {
    AppLanguage.sinhala => 'ස්ථානය',
    AppLanguage.tamil => 'அமைவிடம்',
    AppLanguage.english => 'Location',
  };

  // ---------------------------------------------------------------------------
  // 3D Map Section
  // ---------------------------------------------------------------------------
  String get mapSectionTitle => switch (language) {
    AppLanguage.sinhala => 'ත්‍රිමාණ සිතියමෙන් ගවේෂණය',
    AppLanguage.tamil => '3D வரைபடத்துடன் ஆராய்க',
    AppLanguage.english => 'Explore Things With 3D Map',
  };

  String get mapMode3D => switch (language) {
    AppLanguage.sinhala => 'ත්‍රිමාණ දසුන',
    AppLanguage.tamil => '3D பார்வை',
    AppLanguage.english => '3D View',
  };

  String get mapMode2D => switch (language) {
    AppLanguage.sinhala => 'ද්විමාණ සමතලා',
    AppLanguage.tamil => '2D தட்டையான',
    AppLanguage.english => '2D Flat',
  };

  String get mapDragHint => switch (language) {
    AppLanguage.sinhala => 'භ්‍රමණය කිරීමට අදින්න • පළාතක් පරීක්ෂා කිරීමට තට්ටු කරන්න',
    AppLanguage.tamil => 'சுழற்ற இழுக்கவும் • மாகாணத்தைத் தட்டவும்',
    AppLanguage.english => 'Drag to rotate & tilt • Tap province to inspect',
  };

  String get mapResetView => switch (language) {
    AppLanguage.sinhala => 'දසුන යළි පිහිටුවන්න',
    AppLanguage.tamil => 'பார்வையை மீட்டமைக்க',
    AppLanguage.english => 'Reset View',
  };

  String get mapExploreProvince => switch (language) {
    AppLanguage.sinhala => 'පළාත ගවේෂණය කරන්න',
    AppLanguage.tamil => 'மாகாணத்தை ஆராய்க',
    AppLanguage.english => 'Explore Province',
  };

  String get tapProvinceToExplore => switch (language) {
    AppLanguage.sinhala => 'ගවේෂණය කිරීමට පළාතක් තට්ටු කරන්න',
    AppLanguage.tamil => 'ஆராய மாகாணத்தைத் தட்டவும்',
    AppLanguage.english => 'Tap a province to explore',
  };

  String get historicalSites => switch (language) {
    AppLanguage.sinhala => 'ඓතිහාසික ස්ථාන',
    AppLanguage.tamil => 'வரலாற்று தளங்கள்',
    AppLanguage.english => 'Historical Sites',
  };

  // ---------------------------------------------------------------------------
  // Questions Section
  // ---------------------------------------------------------------------------
  String get questionsTitle => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්න සහ පිළිතුරු',
    AppLanguage.tamil => 'கேள்வி பதில் மன்றம்',
    AppLanguage.english => 'Q&A Forum',
  };

  String get askQuestionButton => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්නයක් අසන්න',
    AppLanguage.tamil => 'கேள்வி கேளுங்கள்',
    AppLanguage.english => 'Ask Question',
  };

  String get searchQuestionsHint => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්න හෝ මාතෘකා සොයන්න...',
    AppLanguage.tamil => 'கேள்விகள் அல்லது தலைப்புகளைத் தேடுக...',
    AppLanguage.english => 'Search questions or topics...',
  };

  String get tabAllQuestions => switch (language) {
    AppLanguage.sinhala => 'සියල්ල',
    AppLanguage.tamil => 'அனைத்தும்',
    AppLanguage.english => 'All',
  };

  String get tabTopQuestions => switch (language) {
    AppLanguage.sinhala => 'ප්‍රමුඛ',
    AppLanguage.tamil => 'முதன்மை',
    AppLanguage.english => 'Top',
  };

  String get tabUnanswered => switch (language) {
    AppLanguage.sinhala => 'පිළිතුරු නැති',
    AppLanguage.tamil => 'பதிலளிக்கப்படாதவை',
    AppLanguage.english => 'Unanswered',
  };

  String get tabRecent => switch (language) {
    AppLanguage.sinhala => 'නවතම',
    AppLanguage.tamil => 'சமீபத்தியவை',
    AppLanguage.english => 'Recent',
  };

  String answersCount(int count) => switch (language) {
    AppLanguage.sinhala => 'පිළිතුරු $count',
    AppLanguage.tamil => '$count பதில்கள்',
    AppLanguage.english => '$count answer${count == 1 ? '' : 's'}',
  };

  String viewsCount(int count) => switch (language) {
    AppLanguage.sinhala => 'නැරඹුම් $count',
    AppLanguage.tamil => '$count பார்வைகள்',
    AppLanguage.english => '$count view${count == 1 ? '' : 's'}',
  };

  String get writeYourAnswer => switch (language) {
    AppLanguage.sinhala => 'ඔබේ පිළිතුර ලියන්න...',
    AppLanguage.tamil => 'உங்கள் பதிலை எழுதுங்கள்...',
    AppLanguage.english => 'Write your answer...',
  };

  String get submitAnswer => switch (language) {
    AppLanguage.sinhala => 'පිළිතුර යොමු කරන්න',
    AppLanguage.tamil => 'பதிலைச் சமர்ப்பிக்க',
    AppLanguage.english => 'Submit Answer',
  };

  String get questionTitleLabel => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්නයේ මාතෘකාව',
    AppLanguage.tamil => 'கேள்வியின் தலைப்பு',
    AppLanguage.english => 'Question Title',
  };

  String get questionDetailsLabel => switch (language) {
    AppLanguage.sinhala => 'විස්තරය',
    AppLanguage.tamil => 'விவரங்கள்',
    AppLanguage.english => 'Details / Description',
  };

  String get questionCategoryLabel => switch (language) {
    AppLanguage.sinhala => 'ප්‍රවර්ගය',
    AppLanguage.tamil => 'வகை',
    AppLanguage.english => 'Category',
  };

  String get postQuestionButton => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්නය පළ කරන්න',
    AppLanguage.tamil => 'கேள்வியைப் பதிவிடுக',
    AppLanguage.english => 'Post Question',
  };

  String get noQuestionsFound => switch (language) {
    AppLanguage.sinhala => 'ප්‍රශ්න කිසිවක් හමු නොවීය',
    AppLanguage.tamil => 'கேள்விகள் எதுவும் கிடைக்கவில்லை',
    AppLanguage.english => 'No questions found',
  };

  String get noQuestionsSubtitle => switch (language) {
    AppLanguage.sinhala => 'වෙනත් සෙවුමක් උත්සාහ කරන්න හෝ නව ප්‍රශ්නයක් අසන්න.',
    AppLanguage.tamil => 'வேறொரு தேடலை முயற்சிக்கவும் அல்லது புதிய கேள்வியைத் தொடங்கவும்.',
    AppLanguage.english => 'Try another search or start a new thread.',
  };

  String get askCommunitySubtitle => switch (language) {
    AppLanguage.sinhala => 'මෙම ස්ථාන හොඳින් දන්නා අයගෙන් අසන්න',
    AppLanguage.tamil => 'இந்த இடங்களை அறிந்தவர்களிடம் கேளுங்கள்',
    AppLanguage.english => 'Ask the people who know these places',
  };

  String get categoryRituals => switch (language) {
    AppLanguage.sinhala => 'චාරිත්‍ර හා ආචාරධර්ම',
    AppLanguage.tamil => 'சடங்குகள் & நடத்தை',
    AppLanguage.english => 'Rituals & Etiquette',
  };

  String get categoryArchitecture => switch (language) {
    AppLanguage.sinhala => 'ගෘහ නිර්මාණ ශිල්පය',
    AppLanguage.tamil => 'கட்டிடக்கலை',
    AppLanguage.english => 'Architecture',
  };

  String get categoryLanguage => switch (language) {
    AppLanguage.sinhala => 'භාෂාව',
    AppLanguage.tamil => 'மொழி',
    AppLanguage.english => 'Language',
  };

  String get categoryHistory => switch (language) {
    AppLanguage.sinhala => 'ඉතිහාසය',
    AppLanguage.tamil => 'வரலாறு',
    AppLanguage.english => 'History',
  };

  String get categoryCrafts => switch (language) {
    AppLanguage.sinhala => 'අත්කම්',
    AppLanguage.tamil => 'கைவினைப்பொருட்கள்',
    AppLanguage.english => 'Crafts',
  };

  String get categoryGettingThere => switch (language) {
    AppLanguage.sinhala => 'ළඟාවීම',
    AppLanguage.tamil => 'சென்றடைவது எப்படி',
    AppLanguage.english => 'Getting There',
  };

  String get categoryFolklore => switch (language) {
    AppLanguage.sinhala => 'ජනප්‍රවාද',
    AppLanguage.tamil => 'நாட்டுப்புறக் கதைகள்',
    AppLanguage.english => 'Folklore',
  };

  String get verifiedBadge => switch (language) {
    AppLanguage.sinhala => 'තහවුරු කළ',
    AppLanguage.tamil => 'சரிபார்க்கப்பட்டது',
    AppLanguage.english => 'Verified',
  };

  String threadsCount(int count) => switch (language) {
    AppLanguage.sinhala => 'මාතෘකා $count',
    AppLanguage.tamil => '$count தலைப்புகள்',
    AppLanguage.english => '$count thread${count == 1 ? '' : 's'}',
  };

  // ---------------------------------------------------------------------------
  // Time Capsule Section
  // ---------------------------------------------------------------------------
  String get capsuleSectionTitle => switch (language) {
    AppLanguage.sinhala => 'කාල කරලිය',
    AppLanguage.tamil => 'நேர காப்ஸ்யூல்',
    AppLanguage.english => 'Time Capsule',
  };

  String get capsuleHeroTitle => switch (language) {
    AppLanguage.sinhala => 'ඔබේ කථාන්දර,\nසුරැකිව තබා ඇත.',
    AppLanguage.tamil => 'உங்கள் கதைகள்,\nஅழகாகப் பாதுகாக்கப்படுகின்றன.',
    AppLanguage.english => 'Your stories,\nbeautifully kept.',
  };

  String get capsuleHeroSubtitle => switch (language) {
    AppLanguage.sinhala => 'ආයුබෝවන් · ඔබේ උරුම සුරක්ෂිතාගාරය',
    AppLanguage.tamil => 'வணக்கம் · உங்கள் பாரம்பரிய பெட்டகம்',
    AppLanguage.english => 'Ayubowan · your legacy vault',
  };

  String get statCapsules => switch (language) {
    AppLanguage.sinhala => 'කරල්',
    AppLanguage.tamil => 'காப்ஸ்யூல்கள்',
    AppLanguage.english => 'Capsules',
  };

  String get statMemories => switch (language) {
    AppLanguage.sinhala => 'මතකයන්',
    AppLanguage.tamil => 'நினைவுகள்',
    AppLanguage.english => 'Memories',
  };

  String get statContributors => switch (language) {
    AppLanguage.sinhala => 'දායකයන්',
    AppLanguage.tamil => 'பங்களிப்பாளர்கள்',
    AppLanguage.english => 'Contributors',
  };

  String get statProtected => switch (language) {
    AppLanguage.sinhala => 'ආරක්ෂිතයි',
    AppLanguage.tamil => 'பாதுகாக்கப்பட்டது',
    AppLanguage.english => 'Protected',
  };

  String get plantCapsulePrompt => switch (language) {
    AppLanguage.sinhala => 'නව කරලක් තැන්පත් කරන්න',
    AppLanguage.tamil => 'புதிய காப்ஸ்யூலை நடவும்',
    AppLanguage.english => 'Plant a new capsule',
  };

  String get plantCapsuleSubtitle => switch (language) {
    AppLanguage.sinhala => 'අනාගතය සඳහා වටිනා ඡායාරූප, ශ්‍රව්‍ය සහ මතකයන් සුරක්ෂිත කරන්න.',
    AppLanguage.tamil => 'எதிர்காலத்திற்காக புகைப்படங்கள், ஆடியோ மற்றும் நினைவுகளைப் பாதுகாக்கவும்.',
    AppLanguage.english => 'Seal precious photos, audio, and memories for the future.',
  };

  String get yourTimeCapsules => switch (language) {
    AppLanguage.sinhala => 'ඔබගේ කාල කරල්',
    AppLanguage.tamil => 'உங்கள் நேர காப்ஸ்யூல்கள்',
    AppLanguage.english => 'YOUR TIME CAPSULES',
  };

  String get createCapsuleTitle => switch (language) {
    AppLanguage.sinhala => 'කාල කරලක් සාදන්න',
    AppLanguage.tamil => 'நேர காப்ஸ்யூலை உருவாக்கவும்',
    AppLanguage.english => 'Create Time Capsule',
  };

  String get capsuleNameLabel => switch (language) {
    AppLanguage.sinhala => 'කරලෙහි මාතෘකාව',
    AppLanguage.tamil => 'காப்ஸ்யூல் தலைப்பு',
    AppLanguage.english => 'Capsule Title',
  };

  String get capsuleDescLabel => switch (language) {
    AppLanguage.sinhala => 'විස්තරය',
    AppLanguage.tamil => 'விவரம்',
    AppLanguage.english => 'Description',
  };

  String get unlockDateLabel => switch (language) {
    AppLanguage.sinhala => 'විවෘත කරන දිනය',
    AppLanguage.tamil => 'திறக்கும் தேதி',
    AppLanguage.english => 'Unlock Date',
  };

  String get beneficiaryLabel => switch (language) {
    AppLanguage.sinhala => 'ප්‍රතිලාභියා / ලබන්නා',
    AppLanguage.tamil => 'பயனாளி / பெறுநர்',
    AppLanguage.english => 'Beneficiary / Recipient',
  };

  String get createCapsuleButton => switch (language) {
    AppLanguage.sinhala => 'මුද්‍රා තබා සාදන්න',
    AppLanguage.tamil => 'முத்திரையிட்டு உருவாக்கு',
    AppLanguage.english => 'Seal & Create Capsule',
  };

  String get addMemory => switch (language) {
    AppLanguage.sinhala => 'මතකයක් එක් කරන්න',
    AppLanguage.tamil => 'நினைவைச் சேர்க்க',
    AppLanguage.english => 'Add Memory',
  };

  String get familyReceiptTitle => switch (language) {
    AppLanguage.sinhala => 'පවුලේ සුරක්ෂිතාගාර රිසිට්පත',
    AppLanguage.tamil => 'குடும்ப பெட்டக ரசீது',
    AppLanguage.english => 'Family Vault Receipt',
  };

  String get familyMemoriesTitle => switch (language) {
    AppLanguage.sinhala => 'පවුලේ මතකයන්',
    AppLanguage.tamil => 'குடும்ப நினைவுகள்',
    AppLanguage.english => 'Family Memories',
  };

  String get mediaPhotos => switch (language) {
    AppLanguage.sinhala => 'ඡායාරූප',
    AppLanguage.tamil => 'புகைப்படங்கள்',
    AppLanguage.english => 'Photos',
  };

  String get mediaAudio => switch (language) {
    AppLanguage.sinhala => 'හඬ සටහන්',
    AppLanguage.tamil => 'குரல் குறிப்புகள்',
    AppLanguage.english => 'Voice Notes',
  };

  String get mediaLetters => switch (language) {
    AppLanguage.sinhala => 'ලිපි',
    AppLanguage.tamil => 'கடிதங்கள்',
    AppLanguage.english => 'Letters',
  };

  String get mediaVideos => switch (language) {
    AppLanguage.sinhala => 'වීඩියෝ',
    AppLanguage.tamil => 'வீடியோக்கள்',
    AppLanguage.english => 'Videos',
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

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
