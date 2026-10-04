# Rootly persistence and finalization audit

Date: 4 October 2026  
Scope: the Flutter app and Rootly backend in this workspace.

## Result

The main save paths now use the authenticated user's MongoDB records. Journey Builder, Field Notes, place search history, translation saves, social collections and settings previously had device-only, screen-only or sample state; those paths now load and save account data. Several capsule and social buttons previously simulated actions; their supported actions now call the backend and show failures.

This is **not yet a fully finished production app**. Private media storage, several inactive features, account recovery and deployment configuration remain unfinished. Passing automated checks does not establish that selected-file uploads or every phone screen work against the deployed services.

The main route names, navigation destinations and form steps were retained. Capsule sample contents were replaced with actual records and a shared memory viewer. Capsule removal archives records and memories rather than permanently erasing them.

## What is saved and how ownership works

| Feature | MongoDB location | Ownership and behavior |
| --- | --- | --- |
| Journey Builder | account_data, key journey | Selected places, order, visit duration, date and named drafts belong to the JWT user. Draft save/delete awaits the database and restores the visible draft list on failure. |
| Field Notes | account_data, key field-notes | Notes, site/category, date, tags and image reference persist per user. Create/edit/delete and overlapping saves are supported. |
| Place search history | account_data, key search-history | Last eight queries, without case-insensitive duplicates. Overlapping searches preserve both entries. |
| Translation library | account_data, key translations | Existing bookmark and favourite controls, saved entry details and last six recent lookups persist per user. The shared dictionary remains in translations. |
| Private social state | account_data, key social | Collections, selected story IDs, submitted-report records and local activity/read state persist per user. This does not implement an administrator moderation inbox or notifications from other users. |
| Settings | account_data, key preferences | Notification/activity preference switches persist. The switches do not yet control a push delivery or presence service. |
| Posts and drafts | posts | Author comes from the JWT. Drafts/private posts are hidden from other users; publication validates required fields. Likes, saves and comments use authenticated user IDs. |
| Profile/password | users | Updates require the authenticated owner. Another user's email and phone are redacted. |
| Follows | user_follows | Relationship belongs to the authenticated follower; follow/unfollow is idempotent and counts come from stored relationships. Target account must exist. |
| Capsules | capsules | Creator comes from the JWT. Vault lists owned or explicitly shared/contributed capsules. Details update, invitations, sealing and archival have server-side access checks. Invitation target account must exist. |
| Capsule letters/memories | capsuleEntries | Entry author comes from the JWT. Members can read; permitted contributors can add while open; only the author can edit/archive an entry. Sealed reads are locked until the configured date and writes remain disabled after sealing. |
| Q&A | questions, questionComments, forumVotes, questionBookmarks | Existing services derive author/voter/bookmark owner from the principal and check edit ownership. Reviewed with existing regression tests. |
| Quiz sessions/answers | quiz_sessions | Existing sessions carry the principal's user ID; answers require a session belonging to that user. Reviewed with existing regression tests. |

Private document IDs use the authenticated user's ID plus the feature key. A caller-supplied nested userId cannot change ownership. Version checks return HTTP 409 for stale updates instead of overwriting another device's newer document. Client writes retain the session captured when the action began; queued operations and old responses cannot populate a newly logged-in account. Login/logout clears shared caches.

MongoDB creates the new collections on first write; no SQL migration is involved. Prototype global/device data was not assigned to users because its owner cannot be determined reliably.

## Verification

| Check | Result |
| --- | --- |
| Flutter analyzer | No issues found |
| Complete Flutter test suite | 96 passed |
| Maven verify: backend tests and PMD | 87 tests passed in the complete suite; affected Explore tests and PMD passed after final focused fixes |
| Real MongoDB/JWT integration scenarios | 7 passed, included in the 87 backend tests |
| Android debug APK | Built successfully from the final changes |

Commands: flutter analyze; flutter test; flutter build apk --debug; Maven wrapper verify with Java 17.

Build outputs:
- Flutter: build/app/outputs/flutter-apk/app-debug.apk
- Backend: ../Rootly_Backend/target/Rootly-0.0.1-SNAPSHOT.jar

The new backend integration suite performs actual MongoDB writes through the JWT/security filter. It uses random synthetic account IDs and a stub user repository for authentication fixtures; it does not register real accounts or prove the entire login flow against real user documents. Cleanup only removes the documents created for those synthetic accounts. Existing user records were not changed by the audit tests.

The Flutter persistence tests cover restoration in a new store, isolation between accounts, concurrent writes, failed draft operations and stale-version rejection. Existing screen tests cover navigation and interactions. No selected user photo was uploaded during this work.

## Explore photo follow-up

Explore now requests supported Wikimedia thumbnails, accepts the current image host and resolves missing primary photos using the same article, exact depicted entity and a reviewed place/photo catalog. Decorative image placeholders were removed and actual download failures have a retry action. Existing routes and journey actions were retained. The 50-place live sample resolved 42 photos; eight source-photo gaps still need suitable image assets. See [Explore image diagnosis and rollout](EXPLORE_IMAGES.md). This does not establish photo coverage for the entire catalog.

## Work still required

1. **Private capsule photo, video and voice memories.** The app currently supports saving letters. The media options explain that storage setup is incomplete. Cover-photo selection is wired to the existing Supabase bucket under a user-scoped path following explicit approval, but a live selected-file upload and the bucket's policies have not been verified. The separate request to enable memory media has not been approved in this chat.
   
   The existing upload helper uses public URLs and the anonymous Supabase client. Spring's JWT login does not itself establish a Supabase Storage identity. A user ID in a filename alone does not enforce ownership. Private capsule contents need a private bucket plus authenticated access or backend-authorized, short-lived signed URLs. Supabase documents that public bucket downloads bypass access controls, while private downloads require authorization or signed URLs. See [bucket fundamentals](https://supabase.com/docs/guides/storage/buckets/fundamentals) and [storage access control](https://supabase.com/docs/guides/storage/security/access-control). Keep any server/service storage credentials on the backend.

2. **Inactive existing features.** “Latest Events” and “Favourite places” are drawer labels with no destination/data implementation. They need an agreed existing screen or feature specification before connecting them; no new navigation flow was invented here. The older capsule-home prototype file is not the active /capsules route.

3. **Translation scanner and pronunciation playback.** These buttons had success-like messages without scanning or playback. They now state that the tools are not configured. Translation lookup, glossary and existing English speech input remain available.

4. **Notification delivery, presence and moderation.** Preferences, current-user activity/read state and report records are saved. Incoming social/push events, presence behavior and report handling by moderators are not implemented.

5. **Account recovery and email verification.** The forgot-password route explicitly has no reset implementation. The OTP screen accepts a fixed demonstration code and does not call a verification/delivery service. Existing routes were retained; these cannot be described as completed recovery/verification features.

6. **Deployment secrets and production configuration.** Main/test backend properties contain embedded MongoDB connection credentials. The main JWT setting has an environment override with an embedded fallback; test properties also contain a fixed secret. Move real credentials/secrets to deployment environment or secret storage and rotate exposed values before release. No secret values are reproduced here. Configure a deployed HTTPS API URL using API_BASE_URL, verify MongoDB access and configure Supabase bucket policies. The current LAN HTTP default is for local development. Release signing and deployment were not performed.

## Final device/service check

Run the rebuilt backend and install the debug APK against the same API URL, then:

- With account A, save/reopen a journey draft, a field note and translation bookmark/favourite; close/reopen the app and sign back in. Verify the saved data returns.
- Sign out and use account B; verify A's private records are absent. Return to A and confirm its records remain.
- Check draft publication, post like/save/comment, follow/unfollow, profile update and password change.
- Create/edit a capsule, add/edit a letter, invite a real account, and check permissions from that account. Set a future unlock date and seal; verify entries are locked before the date.
- Select a test cover photo and verify both the Supabase upload and the saved cover URL. Confirm the intended public/private policy before using personal media.

The APK is a debug build for validation, not a signed production release. iOS and other platforms were not built on this Windows host.
