# Privacy Responses Guide for Shahirizada Mobile App

This document provides the recommended answers for the App Store Connect and Google Play Console privacy questionnaires, based on an analysis of your codebase (`shahirizada` Flutter app).

> **⚠️ Important:** The analysis is based on the current code. If you plan to add features (like Facebook Ads, Firebase Crashlytics, or In-App Chat) later, you must update these answers.

---

## 🍎 App Store Connect (iOS)

Go to **App Privacy** in App Store Connect.

### 1. Data Types
Based on your code (Supabase, Stripe, Google Maps, Location Service), here is what you are collecting:

| Data Type | Specific Data | Answer | Reason / Usage |
| :--- | :--- | :--- | :--- |
| **Contact Info** | Name | **Yes** | Account creation & management. |
| | Email Address | **Yes** | Auth, Receipts, Order updates. |
| | Phone Number | **Yes** | Auth, Delivery coordination. |
| | Physical Address | **Yes** | Delivery & Pickup locations. |
| **Health & Fitness** | | **No** | Not used. |
| **Financial Info** | Payment Info | **Yes** | **Crucial:** You use Stripe. You collect payment details (processed securely). |
| | Credit Info | **No** | Usually refers to credit scores, etc. |
| | Other Financial Info | **Yes** | Order history / Transaction history. |
| **Location** | Precise Location | **Yes** | Delivery tracking & address selection. |
| | Coarse Location | **Yes** | General area for service availability. |
| **Sensitive Info** | | **No** | Not used. |
| **Contacts** | | **No** | You do not read the user's address book. |
| **User Content** | Emails or Text Messages | **No*** | *Recommendation:* **Uncheck this.** Your app *sends* OTPs/Notifications but does not *read* the user's personal emails or texts from their inbox. |
| | Customer Support | **No*** | *Recommendation:* **Uncheck this.** Your app opens the phone dialer (`tel:`) or mail app (`mailto:`). It does not have an internal chat system that stores data *within the app's database* effectively (unless you log these externally). |
| **Browsing History** | | **No** | Not used. |
| **Search History** | | **No** | In-app search (like searching products) is usually covered under "Product Interaction", not "Search History" (which implies web browsing history). |
| **Identifiers** | User ID | **Yes** | Supabase Auth User ID (`auth.users`). |
| | Device ID | **Yes** | Stripe (Fraud detection) & Push Notifications. |
| **Usage Data** | Product Interaction | **Yes** | Order history, viewing products. |
| | Advertising Data | **No*** | *Recommendation:* **Uncheck this.** No Ad SDKs (Facebook, AdMob) were found. |
| **Diagnostics** | Crash Data | **No*** | *Recommendation:* **Uncheck this.** No Crashlytics/Sentry found. |
| | Performance Data | **Yes** | Stripe & Google Maps SDKs collect some performance metrics. |

### 2. Data Usage & Tracking
For each "Yes" above, you will be asked follow-up questions.

#### Contact Info (Name, Email, Phone, Address)
*   **Used for:** App Functionality, Product Personalization (Account).
*   **Linked to User Identity:** **Yes** (It is tied to their account).
*   **Used for Tracking:** **No** (You are not sharing this with data brokers for targeted ads).

#### Financial Info (Payment Info)
*   **Used for:** App Functionality (Processing payments).
*   **Linked to User Identity:** **Yes**.
*   **Used for Tracking:** **No**.

#### Location (Precise & Coarse)
*   **Used for:** App Functionality (Delivery), Product Personalization (Store locator).
*   **Linked to User Identity:** **Yes**.
*   **Used for Tracking:** **No**.

#### Identifiers (User ID, Device ID)
*   **Used for:** App Functionality, Security/Fraud Prevention (Stripe).
*   **Linked to User Identity:** **Yes**.
*   **Used for Tracking:** **No**.

#### Usage Data (Product Interaction)
*   **Used for:** App Functionality, Analytics (if you use Stripe/Google dashboards).
*   **Linked to User Identity:** **Yes**.
*   **Used for Tracking:** **No**.

---

## 🤖 Google Play Console (Android)

Go to **App Content** > **Data safety**.

### 1. Data Collection & Security
*   **Does your app collect or share any of the required user data types?** **Yes**
*   **Is all of the user data collected by your app encrypted in transit?** **Yes** (Supabase and Stripe use HTTPS/TLS).
*   **Do you provide a way for users to request that their data is deleted?** **Yes** (You should have a deletion request mechanism, usually in the privacy policy or profile settings. Your `HelpCenterScreen` mentions "Contact support to request deletion").

### 2. Data Types
Select the following categories:

#### Location
*   **Approximate location:** Selected.
*   **Precise location:** Selected.
    *   **Collected?** Yes.
    *   **Shared?** No (unless you use a 3rd party delivery fleet API, but usually "No" is safe if it stays within your system/Google Maps).
    *   **Processed ephemerally?** **No** (You store addresses).
    *   **Required or Optional?** **Required** (for delivery).
    *   **Purposes:** App functionality, Personalization.

#### Personal Info
*   **Name:** Selected. (Collected, Required, App functionality).
*   **Email address:** Selected. (Collected, Required, App functionality, Account management).
*   **User IDs:** Selected. (Collected, Required, App functionality).
*   **Address:** Selected. (Collected, Required, App functionality).
*   **Phone number:** Selected. (Collected, Required, App functionality).

#### Financial Info
*   **User payment info:** Selected. (Collected, Required, App functionality).
    *   *Note:* Even though Stripe handles it, Google often requires you to declare it if the payment happens *within* the app flow.
*   **Purchase history:** Selected. (Collected, Required, App functionality).

#### App Info and Performance
*   **Crash logs:** Not selected (unless you add Crashlytics).
*   **Diagnostics:** Selected (Stripe/Google Maps SDKs).
    *   **Purposes:** Analytics, Fraud prevention.

#### Device or other IDs
*   **Device or other IDs:** Selected.
    *   **Purposes:** App functionality, Fraud prevention (Stripe).

---

## 📝 Discrepancy Check (Your Prompt vs. Code)

| Item from your list | Codebase Status | Recommendation |
| :--- | :--- | :--- |
| **Contact Info** | ✅ Found | **Keep.** |
| **Location** | ✅ Found | **Keep.** |
| **User Content** | ❓ Ambiguous | **Remove/Uncheck.** App sends OTPs but doesn't "collect" user emails/texts in the privacy sense (reading inbox). Support is via external apps. |
| **Identifiers** | ✅ Found | **Keep.** |
| **Usage Data** | ✅ Found | **Keep.** (Product Interaction). |
| **Advertising Data** | ❌ Not Found | **Remove/Uncheck.** No Ad SDKs found. |
| **Crash Data** | ❌ Not Found | **Remove/Uncheck.** No Crashlytics found. |
| **Performance Data** | ✅ Found | **Keep.** (Stripe/Maps SDKs). |
