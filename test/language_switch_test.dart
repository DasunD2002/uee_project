import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/core/localization/app_language.dart';
import 'package:uee_project/core/localization/app_language_provider.dart';
import 'package:uee_project/core/localization/app_localizations.dart';
import 'package:uee_project/features/explorer/presentation/widgets/explorer_footer.dart';
import 'package:uee_project/features/home/presentation/widgets/home_drawer.dart';
import 'package:uee_project/features/settings/presentation/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguageProvider.instance.setLanguage(AppLanguage.english);
  });

  group('AppLanguage and Translations Unit Tests', () {
    test('AppLanguage enum properties are correct', () {
      expect(AppLanguage.english.code, 'en');
      expect(AppLanguage.sinhala.code, 'si');
      expect(AppLanguage.tamil.code, 'ta');

      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('si'), AppLanguage.sinhala);
      expect(AppLanguage.fromCode('ta'), AppLanguage.tamil);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.english);
    });

    test('Nav bar translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.navHome, 'Home');
      expect(si.navHome, 'මුල් පිටුව');
      expect(ta.navHome, 'முகப்பு');

      expect(en.navExplore, 'Explore');
      expect(si.navExplore, 'ගවේෂණය');
      expect(ta.navExplore, 'ஆராய்க');

      expect(en.navQuestions, 'Questions');
      expect(si.navQuestions, 'ප්‍රශ්න');
      expect(ta.navQuestions, 'கேள்விகள்');

      expect(en.navCapsule, 'Capsule');
      expect(si.navCapsule, 'කරලිය');
      expect(ta.navCapsule, 'காப்ஸ்யூல்');
    });

    test('Side bar / Drawer translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.drawerProfile, 'Profile');
      expect(si.drawerProfile, 'පැතිකඩ');
      expect(ta.drawerProfile, 'சுயவிவரம்');

      expect(en.drawerExplorePlaces, 'Explore Places');
      expect(si.drawerExplorePlaces, 'ස්ථාන ගවේෂණය');
      expect(ta.drawerExplorePlaces, 'இடங்களை ஆராய்க');

      expect(en.drawerQaForum, 'Q&A Forum');
      expect(si.drawerQaForum, 'ප්‍රශ්න සහ පිළිතුරු');
      expect(ta.drawerQaForum, 'கேள்வி பதில் மன்றம்');

      expect(en.drawerTimeCapsule, 'Time capsule');
      expect(si.drawerTimeCapsule, 'කාල කරලිය');
      expect(ta.drawerTimeCapsule, 'நேர காப்ஸ்யூல்');

      expect(en.drawerSavedPosts, 'Saved posts');
      expect(si.drawerSavedPosts, 'සුරකින ලද සටහන්');
      expect(ta.drawerSavedPosts, 'சேமிக்கப்பட்ட பதிவுகள்');

      expect(en.drawerSettings, 'Settings');
      expect(si.drawerSettings, 'සැකසීම්');
      expect(ta.drawerSettings, 'அமைப்புகள்');

      expect(en.drawerLogOut, 'Log Out');
      expect(si.drawerLogOut, 'ඉවත් වන්න');
      expect(ta.drawerLogOut, 'வெளியேறு');
    });

    test('Settings translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.settingsTitle, 'Settings');
      expect(si.settingsTitle, 'සැකසීම්');
      expect(ta.settingsTitle, 'அமைப்புகள்');

      expect(en.sectionLanguage, 'LANGUAGE');
      expect(si.sectionLanguage, 'භාෂාව');
      expect(ta.sectionLanguage, 'மொழி');

      expect(en.appLanguageTitle, 'App Language');
      expect(si.appLanguageTitle, 'යෙදුමේ භාෂාව');
      expect(ta.appLanguageTitle, 'பயன்பாட்டு மொழி');

      expect(en.myProfile, 'My profile');
      expect(si.myProfile, 'මගේ පැතිකඩ');
      expect(ta.myProfile, 'என் சுயவிவரம்');

      expect(en.changePassword, 'Change password');
      expect(si.changePassword, 'මුරපදය වෙනස් කරන්න');
      expect(ta.changePassword, 'கடவுச்சொல்லை மாற்றுக');
    });

    test('Profile section translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.editProfileData, 'Edit Profile Data');
      expect(si.editProfileData, 'පැතිකඩ සංස්කරණය');
      expect(ta.editProfileData, 'சுயவிவரத்தை திருத்து');

      expect(en.postsLabel, 'Posts');
      expect(si.postsLabel, 'සටහන්');
      expect(ta.postsLabel, 'பதிவுகள்');

      expect(en.followersLabel, 'Followers');
      expect(si.followersLabel, 'අනුගාමිකයන්');
      expect(ta.followersLabel, 'பின்தொடர்பவர்கள்');

      expect(en.followingLabel, 'Following');
      expect(si.followingLabel, 'අනුගමනය කරන');
      expect(ta.followingLabel, 'பின்தொடர்பவை');
    });

    test('Explore and 3D Map translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.exploreTitle, 'Explore Places');
      expect(si.exploreTitle, 'ස්ථාන ගවේෂණය');
      expect(ta.exploreTitle, 'இடங்களை ஆராய்க');

      expect(en.mapMode3D, '3D View');
      expect(si.mapMode3D, 'ත්‍රිමාණ දසුන');
      expect(ta.mapMode3D, '3D பார்வை');

      expect(en.mapMode2D, '2D Flat');
      expect(si.mapMode2D, 'ද්විමාණ සමතලා');
      expect(ta.mapMode2D, '2D தட்டையான');

      expect(en.mapExploreProvince, 'Explore Province');
      expect(si.mapExploreProvince, 'පළාත ගවේෂණය කරන්න');
      expect(ta.mapExploreProvince, 'மாகாணத்தை ஆராய்க');
    });

    test('Questions section translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.questionsTitle, 'Q&A Forum');
      expect(si.questionsTitle, 'ප්‍රශ්න සහ පිළිතුරු');
      expect(ta.questionsTitle, 'கேள்வி பதில் மன்றம்');

      expect(en.askQuestionButton, 'Ask Question');
      expect(si.askQuestionButton, 'ප්‍රශ්නයක් අසන්න');
      expect(ta.askQuestionButton, 'கேள்வி கேளுங்கள்');

      expect(en.tabAllQuestions, 'All');
      expect(si.tabAllQuestions, 'සියල්ල');
      expect(ta.tabAllQuestions, 'அனைத்தும்');

      expect(en.tabTopQuestions, 'Top');
      expect(si.tabTopQuestions, 'ප්‍රමුඛ');
      expect(ta.tabTopQuestions, 'முதன்மை');

      expect(en.tabUnanswered, 'Unanswered');
      expect(si.tabUnanswered, 'පිළිතුරු නැති');
      expect(ta.tabUnanswered, 'பதிலளிக்கப்படாதவை');
    });

    test('Capsule section translations for English, Sinhala, and Tamil', () {
      final en = AppLocalizations.current(AppLanguage.english);
      final si = AppLocalizations.current(AppLanguage.sinhala);
      final ta = AppLocalizations.current(AppLanguage.tamil);

      expect(en.capsuleSectionTitle, 'Time Capsule');
      expect(si.capsuleSectionTitle, 'කාල කරලිය');
      expect(ta.capsuleSectionTitle, 'நேர காப்ஸ்யூல்');

      expect(en.statCapsules, 'Capsules');
      expect(si.statCapsules, 'කරල්');
      expect(ta.statCapsules, 'காப்ஸ்யூல்கள்');

      expect(en.createCapsuleTitle, 'Create Time Capsule');
      expect(si.createCapsuleTitle, 'කාල කරලක් සාදන්න');
      expect(ta.createCapsuleTitle, 'நேர காப்ஸ்யூலை உருவாக்கவும்');

      expect(en.addMemory, 'Add Memory');
      expect(si.addMemory, 'මතකයක් එක් කරන්න');
      expect(ta.addMemory, 'நினைவைச் சேர்க்க');
    });
  });

  group('Widget Tests for Language Switching', () {
    testWidgets('ExplorerFooter updates labels when language changes', (tester) async {
      await tester.pumpWidget(
        ListenableBuilder(
          listenable: AppLanguageProvider.instance,
          builder: (context, _) => AppLocalizationsProvider(
            language: AppLanguageProvider.instance.currentLanguage,
            child: MaterialApp(
              home: Scaffold(
                bottomNavigationBar: ExplorerFooter(
                  selectedIndex: 0,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default English
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Capsule'), findsOneWidget);

      // Switch to Sinhala
      await AppLanguageProvider.instance.setLanguage(AppLanguage.sinhala);
      await tester.pumpAndSettle();

      expect(find.text('මුල් පිටුව'), findsOneWidget);
      expect(find.text('ගවේෂණය'), findsOneWidget);
      expect(find.text('ප්‍රශ්න'), findsOneWidget);
      expect(find.text('කරලිය'), findsOneWidget);

      // Switch to Tamil
      await AppLanguageProvider.instance.setLanguage(AppLanguage.tamil);
      await tester.pumpAndSettle();

      expect(find.text('முகப்பு'), findsOneWidget);
      expect(find.text('ஆராய்க'), findsOneWidget);
      expect(find.text('கேள்விகள்'), findsOneWidget);
      expect(find.text('காப்ஸ்யூல்'), findsOneWidget);
    });

    testWidgets('HomeDrawer shows localized menu items in English, Sinhala, Tamil', (tester) async {
      await tester.pumpWidget(
        ListenableBuilder(
          listenable: AppLanguageProvider.instance,
          builder: (context, _) => AppLocalizationsProvider(
            language: AppLanguageProvider.instance.currentLanguage,
            child: const MaterialApp(
              home: Scaffold(
                body: HomeDrawer(selectedSection: 'Home'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // English
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Explore Places'), findsOneWidget);
      expect(find.text('Q&A Forum'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Switch to Sinhala
      await AppLanguageProvider.instance.setLanguage(AppLanguage.sinhala);
      await tester.pumpAndSettle();

      expect(find.text('පැතිකඩ'), findsOneWidget);
      expect(find.text('ස්ථාන ගවේෂණය'), findsOneWidget);
      expect(find.text('ප්‍රශ්න සහ පිළිතුරු'), findsOneWidget);
      expect(find.text('සැකසීම්'), findsOneWidget);

      // Switch to Tamil
      await AppLanguageProvider.instance.setLanguage(AppLanguage.tamil);
      await tester.pumpAndSettle();

      expect(find.text('சுயவிவரம்'), findsOneWidget);
      expect(find.text('இடங்களை ஆராய்க'), findsOneWidget);
      expect(find.text('கேள்வி பதில் மன்றம்'), findsOneWidget);
      expect(find.text('அமைப்புகள்'), findsOneWidget);
    });

    testWidgets('Settings screen contains language switcher and updates UI reactively', (tester) async {
      await tester.pumpWidget(
        ListenableBuilder(
          listenable: AppLanguageProvider.instance,
          builder: (context, _) => AppLocalizationsProvider(
            language: AppLanguageProvider.instance.currentLanguage,
            child: const MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('LANGUAGE'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('සිංහල'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);

      // Tap Sinhala segment button
      await tester.tap(find.text('සිංහල'));
      await tester.pumpAndSettle();

      expect(AppLanguageProvider.instance.currentLanguage, AppLanguage.sinhala);
      expect(find.text('සැකසීම්'), findsOneWidget);
      expect(find.text('භාෂාව'), findsOneWidget);
      expect(find.text('යෙදුමේ භාෂාව'), findsOneWidget);

      // Tap Tamil segment button
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();

      expect(AppLanguageProvider.instance.currentLanguage, AppLanguage.tamil);
      expect(find.text('அமைப்புகள்'), findsOneWidget);
      expect(find.text('மொழி'), findsOneWidget);
      expect(find.text('பயன்பாட்டு மொழி'), findsOneWidget);
    });
  });
}
