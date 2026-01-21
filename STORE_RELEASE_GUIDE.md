# Store Release Guide (iOS App Store + Google Play)

This guide is written so an automated “browser AI” (or a human) can fill in **Apple Developer / App Store Connect** and **Google Play Console** forms with the correct values and avoid common review rejections—especially around **Stripe payments**, **location permissions**, and **privacy disclosures**.

It is not legal advice. Always confirm with your counsel and the latest Apple/Google policies.

---

## 0) App Identity (copy/paste)

**App name (display):** Shahirizada Fresh Market  
**App type:** E‑commerce / grocery / physical goods delivery (meat market)  
**Android package / applicationId:** `us.tabsy.shahirizada` (from `android/app/build.gradle`)  
**iOS bundle identifier:** `us.tabsy.shahirizada` (from `ios/Runner.xcodeproj/project.pbxproj`)  
**iOS URL scheme:** `shahirizada` (from `ios/Runner/Info.plist`)  
**Stripe merchant identifier (Apple Pay):** `merchant.us.tabsy.shahirizada` (from `ios/Runner/Runner.entitlements`)  
**Current version/build:** `2.4.2+22` (from `pubspec.yaml`)

**Contact email (in-app privacy text):** `shahirzadafreshmarket@gmail.com` (see `lib/features/profile/presentation/screens/privacy_policy_screen.dart`)

---

## 1) Critical policy checks (these block approval)

### 1.1 Stripe payments: allowed only for **physical goods/services**
Apple/Google allow external payments like Stripe when the purchase is for **physical goods** (e.g., groceries / delivery). They do **not** allow Stripe for **digital goods** that must use In‑App Purchase (Apple) / Play Billing (Google).

**Make sure your store listing and in‑app copy clearly describes physical goods delivery.**

### 1.2 Account deletion (Apple guideline 5.1.1)
If your app supports account creation/login, Apple generally requires **in‑app account deletion**.

Current in-app FAQ text says “Contact support to request account deletion” (`lib/features/profile/presentation/screens/help_center_screen.dart`). This is a common reason for rejection.

**Recommended before submission:**
- Add an in-app “Delete account” action that actually deletes the account (or starts an automated deletion flow).
- If deletion is not immediate (e.g., legal retention), clearly explain in the UI and in review notes.

### 1.3 Background location (Apple + Google are strict)
Android manifest currently requests:
- `ACCESS_BACKGROUND_LOCATION`

iOS `Info.plist` includes “Always” location usage descriptions.

Background location can trigger extra review scrutiny and Play Console declarations.

**Recommended before submission (if you don’t truly need background tracking):**
- Remove background location permission and only request “While in use”.
- If you truly need background location, be prepared to provide a strong justification and (on Google Play) complete the background location access declaration.

---

## 2) Links you MUST have ready (App Store Connect + Play Console)

You will need public URLs. Apple often rejects apps with missing or inaccessible links.

- **Privacy Policy URL:** `https://<your-domain>/privacy`
  - Source content: `PRIVACY_POLICY.md` in this repo.
- **Support URL:** `https://<your-domain>/support` (or a contact page)
- **Marketing URL (optional but recommended):** `https://<your-domain>/`
- **Terms of Use URL (recommended):** `https://<your-domain>/terms`

Notes:
- A GitHub “raw” URL is risky for App Review. Prefer a normal website page.
- Ensure pages are accessible without login.

---

## 3) Apple Developer setup (IDs, certificates, capabilities)

### 3.1 Apple Developer Program
You need an active Apple Developer Program membership for the owning organization.

### 3.2 Create the App ID
In Apple Developer → **Certificates, Identifiers & Profiles**:
- **Identifiers → App IDs → +**
  - **Bundle ID:** `us.tabsy.shahirizada`
  - **Description:** `Shahirizada Fresh Market`

### 3.3 Capabilities
Enable only what you actually use. Over-declaring can cause review questions.

**Apple Pay (only if used):**
- Ensure Apple Pay capability is enabled for the App ID.
- Create/confirm the **Merchant ID**: `merchant.us.tabsy.shahirizada`
- Link the Merchant ID to your App ID.

**Push notifications:** enable only if you actually send push (not just local notifications).

### 3.4 Certificates & profiles (for distribution)
You need:
- **iOS Distribution certificate**
- **App Store provisioning profile** for `us.tabsy.shahirizada`

If you use Codemagic:
- Upload the distribution certificate + provisioning profile in Codemagic and map to the workflow.

---

## 4) App Store Connect setup (what to enter)

### 4.1 Create the app record
App Store Connect → **Apps → + → New App**
- **Platform:** iOS
- **Name:** Shahirizada Fresh Market
- **Primary language:** <choose>
- **Bundle ID:** `us.tabsy.shahirizada`
- **SKU:** `shahirizada_fresh_market_ios` (any unique string)

### 4.2 App Information
- **Category:** Food & Drink (or Shopping)
- **Age rating:** complete questionnaire (likely “Unrestricted” unless you add restricted content)

### 4.3 Pricing and Availability
- Usually **Free** (you sell physical goods inside the app).

### 4.4 App Privacy (the questionnaire)
You must declare what data is collected, even if processed by third-party SDKs through your app.

Based on this repo (Stripe + Supabase + location + notifications), you will likely need to declare:

**Data that may be collected (common for this app type):**
- **Contact Info:** name, email, phone number
- **Identifiers:** user ID / device identifiers (if collected by SDKs)
- **Location:** if you use location for delivery/store proximity
- **Purchases:** order history (often counts as “Purchases”)
- **Financial Info:** payment information (Stripe)
- **User Content:** delivery address (may map to “Contact Info” or “User Content” depending on Apple’s categories)

**Tracking:** usually **No** unless you track users across apps/websites for advertising.

You must also choose purposes (e.g., “App Functionality”, “Analytics”, “Fraud Prevention”, “Personalization”). If you are not doing analytics/ads, don’t claim them.

> Important: Final answers must match actual behavior. If uncertain, audit your SDKs and backend logs.

### 4.5 Review Information (critical)
App Store Connect → **App Review Information**
- **Contact:** your real name/phone/email
- **Demo account:**
  - If login is required, provide a working test account.
  - Provide OTP/test email instructions if applicable.
- **Notes:**
  - Explicitly state: “This app sells physical goods (fresh meat/groceries) delivered to customers; payments are processed via Stripe.”
  - If you request location: explain why and when it is requested.
  - If Apple Pay is enabled: explain it is for physical goods checkout (via Stripe).

### 4.6 Export compliance (encryption)
`ios/Runner/Info.plist` has `ITSAppUsesNonExemptEncryption = false`.
In App Store Connect export compliance questions, this typically corresponds to:
- Uses only exempt encryption (standard HTTPS/TLS) → **No non-exempt encryption**.

### 4.7 Build upload and submission
- Upload your build (Codemagic/Xcode).
- Attach screenshots, app icon, and metadata.
- Submit for review.

---

## 5) Google Play Console setup (what to enter)

### 5.1 Create the app record
Google Play Console → **All apps → Create app**
- **App name:** Shahirizada Fresh Market
- **Default language:** <choose>
- **App or game:** App
- **Free or paid:** Free

### 5.2 App signing (IMPORTANT)
Play Console → **Setup → App integrity**
- Enable **Play App Signing**
- Upload your **upload key certificate** if required.

Your Gradle config uses `key.properties` locally; in CI you should inject signing securely (Codemagic environment variables / encrypted files).

### 5.3 Store listing
Fill:
- **Short description**
- **Full description**
- **Screenshots** (phone + tablet if you support it)
- **Privacy policy URL** (same as above)

### 5.4 Data Safety form
You must declare data collection/sharing. Expect to include:
- **Personal info:** name, email, phone, address
- **Financial info:** payment info (Stripe)
- **Location:** if used
- **App activity:** app interactions / order history (if applicable)

Specify:
- Collected vs shared
- Required vs optional
- Purpose (app functionality, fraud prevention, etc.)

### 5.5 Permissions declarations
Your Android manifest requests background location:
- `ACCESS_BACKGROUND_LOCATION`

If you keep this:
- Complete the **Background location** declaration
- Provide a clear in-app disclosure and obtain consent
- Provide a video demonstrating the feature that requires background location (Google often asks)

If you do not need it:
- Remove background location permission to simplify approval.

---

## 6) Stripe production readiness checklist

### 6.1 Stripe mode + keys
- Use **Live mode** keys for production builds.
- Ensure your app/environment switching cannot accidentally ship with test keys.

### 6.2 Webhooks
Configure webhooks for events your backend depends on (common):
- `payment_intent.succeeded`
- `payment_intent.payment_failed`
- `charge.refunded`
- `checkout.session.completed` (if using Checkout)

### 6.3 Apple Pay via Stripe (if enabled)
Your iOS entitlements include `merchant.us.tabsy.shahirizada`.

To avoid Apple Pay issues:
- Register and configure the Merchant ID in Apple Developer.
- Enable Apple Pay in your Stripe account.
- Ensure the merchant ID in Stripe matches: `merchant.us.tabsy.shahirizada`.

### 6.4 Review/testing strategy
Provide App Review / Play reviewers a way to test checkout without real charges:
- A “test environment” toggle (if you have one) plus test credentials, OR
- A coupon/100% discount flow, OR
- A clearly documented test card flow (Stripe test mode) if you submit a test build for review.

---

## 7) App permissions & what reviewers expect

### iOS permission strings (already present)
`ios/Runner/Info.plist` includes:
- Camera: card scanning
- Location (When In Use + Always variants)
- Notifications

Reviewers will check:
- The permission request occurs only when needed (not immediately on launch).
- The feature works without forcing “Always” location unless truly required.

### Android permissions (current)
`android/app/src/main/AndroidManifest.xml` includes:
- Fine/coarse/background location
- Post notifications
- Internet

Google will check:
- You don’t request background location unless essential.
- You provide in-app disclosure + consent if you do.

---

## 8) Submission “form-fill” template (for your browser AI)

Fill these placeholders before handing this section to automation:

```text
APP_NAME = Shahirizada Fresh Market
IOS_BUNDLE_ID = us.tabsy.shahirizada
ANDROID_PACKAGE_NAME = us.tabsy.shahirizada
VERSION = 2.4.2
BUILD_NUMBER = 22
MERCHANT_ID_APPLE_PAY = merchant.us.tabsy.shahirizada
SUPPORT_EMAIL = shahirzadafreshmarket@gmail.com
PRIVACY_POLICY_URL = https://<your-domain>/privacy
SUPPORT_URL = https://<your-domain>/support
MARKETING_URL = https://<your-domain>/
TERMS_URL = https://<your-domain>/terms
APP_CATEGORY_IOS = Food & Drink (or Shopping)
PAYMENTS_NOTE = Physical goods; payments processed with Stripe; no digital goods.
LOCATION_JUSTIFICATION = Used to set delivery address and estimate delivery/store proximity; request only when needed.
```

---

## 9) Recommended pre-submission sanity checklist

- Verify production builds point to **production Supabase** and **Stripe live** keys.
- Confirm you have an in-app **account deletion** flow (Apple).
- If you don’t need it, remove **background location** permissions (Apple/Google).
- Confirm Privacy Policy URL is live and matches what the app does.
- Create and test a reviewer account + a successful end-to-end order flow.
- Ensure “Sign up with Apple/Google” is not claimed in UI unless implemented (reviewers flag inconsistencies).

