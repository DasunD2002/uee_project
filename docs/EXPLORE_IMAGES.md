# Explore Places photo fix

Date: 4 October 2026.

## What changed

Explore now uses actual place photos from Wikimedia metadata. The existing search, pagination, place details, map and Add to Journey actions retain their routes and data.

The live diagnosis found original-resolution Commons links returning HTTP 429. Their 960-pixel thumbnails returned HTTP 200. The backend also rejected the newer `thumb.wikimedia.org` host, and region images requested the unsupported 900-pixel size.

- The backend resolves Commons file references through the imageinfo API and requests a supported 960-pixel thumbnail.
- Missing primary photos are looked up in the same place's Wikipedia article, matching article files and Commons statements that explicitly depict that Wikidata entity.
- Unrelated template images, maps, book icons and keyword-search pictures of other places are rejected.
- A reviewed photo catalog provides explicit place-ID-to-file mappings when public metadata is incomplete. Athkanda Temple's verified photo is included.
- Photo results are cached; missing results expire after five minutes. Metadata requests use a descriptive User-Agent and back off after HTTP 429/503.
- Flutter normalizes old saved Commons references and thumbnail links. This also repairs those references in journeys and field notes.
- Missing photos use the place's text details. Failed downloads provide a visible Retry photo action that evicts the failed Flutter image entry. Decorative photo overlays allow that button to receive taps.

Image URLs and source-page attribution travel together. No selected user photo was uploaded as part of this work.

Wikimedia documents [supported thumbnail sizes](https://www.mediawiki.org/wiki/Common_thumbnail_sizes/en), the [imageinfo API](https://www.mediawiki.org/wiki/API:Imageinfo), [descriptive User-Agent requirements](https://foundation.wikimedia.org/wiki/Policy:Wikimedia_Foundation_User-Agent_Policy/en) and [entity-specific depicts searches](https://commons.wikimedia.org/wiki/Commons:Depicts/en).

## Apply the fix

1. Restart the Rootly backend using the updated source or rebuilt JAR.
2. Hot restart Flutter, or install the rebuilt debug APK.
3. Reopen Explore Places. The first lookup may take a few seconds; repeated lookups use the backend photo cache.

An already running backend may still serve its previous code. Hot reload of Flutter alone does not apply Java changes.

Build outputs:

- Flutter: `build/app/outputs/flutter-apk/app-debug.apk`
- Backend: `../Rootly_Backend/target/Rootly-0.0.1-SNAPSHOT.jar`

## Real source-photo gaps

The live sample covered the first 50 places from a 273-place catalog. Originally 38 had photo references; the new resolver supplied 42 actual photos, recovering All Saints' Church (Borella), Ariyalai Siddhivinayakar Temple, Athkanda Raja Maha Viharaya and Balana Fort. The tested repaired thumbnail downloads returned HTTP 200 with image content. Athkanda's small original, supplied by imageinfo, also returned HTTP 200.

Eight sampled places still lack a suitable photo through the verified lookups. This is a content gap, so the app keeps their details visible instead of substituting an unrelated picture. Coverage of every photo in the complete catalog was not established.

| Place | Wikidata ID |
| --- | --- |
| Arippu Fort | Q12973680 |
| Asgiri Maha Viharaya | Q31800102 |
| Belilena | Q4882839 |
| Buddama Raja Maha Vihara | Q28457340 |
| Cathedral of St. Anne | Q123048004 |
| Choleeswaram temple | Q4501090 |
| Colombo National Art Gallery | Q11302924 |
| Dambadeniya | Q1021154 |

To fill a verified Commons photo gap, add a reviewed entry to `../Rootly_Backend/src/main/resources/explore-photos.json` using the exact Wikidata ID and Commons `File:` title. Keep the source page, photographer, license and verification information with the entry. Restart the backend after changing the catalog.

Use a photo that depicts the actual site and is suitable for reuse. Several broad searches returned another cathedral, a temple in India, coin photos or unrelated portraits; these were not used. Sites with no suitable source photo need an appropriately licensed or owner-supplied photo asset before complete image coverage can be promised.

## Verification

The Flutter analyzer reported no issues. The complete Flutter suite has 96 tests, including encoded filename handling, removal of decorative image placeholders, retry behavior and existing journey navigation. The complete backend suite has 87 tests, including batched Commons resolution, article redirects, exact depicted-entity lookup, reviewed photo mapping, rejection of unrelated/invalid images, caching and provider backoff.

The complete suites passed: 96 Flutter tests and 87 backend tests. After the final focused fixes, the affected Explore backend tests and PMD were rerun. The Android debug APK and backend JAR were rebuilt successfully. No full phone UI inspection was performed.
