# Data Handling & Synchronization Guide

This document outlines the data handling strategies implemented for the **Shahirizada Fresh Market** application to ensure consistency across Mobile and Web platforms. It specifically details the handling of the `customers` table, unique constraints, and the synchronization logic for Phone Numbers and Emails.

## 1. Core Principles

The `customers` table (`public.customers`) serves as the source of truth for user profiles. To manage conflicts and data integrity, we have established the following rules:

### A. Phone Numbers: "Latest Wins" (Stealing Allowed)
*   **Rule:** Phone numbers are dynamic. If a user verifies/connects a phone number that is currently associated with another account (e.g., an old or abandoned account), the new user **claims** it.
*   **Mechanism:** The previous owner's `phone` field is set to `NULL`. The new owner gets the phone number.
*   **Implementation:** RPC Function `claim_phone_number(p_phone)`.

### B. Email Addresses: "First Come, First Served" (Strict Uniqueness)
*   **Rule:** E-mails are identity anchors. You CANNOT steal an email address that is already associated with *another* active user.
*   **Exception (Orphan Claiming):** You CAN claim a customer record that has your email but **NO** attached `auth_user_id` (an orphaned record). This fixes issues where a profile was created (e.g., via admin or import) before the user signed up properly.
*   **Implementation:** RPC Function `claim_orphan_email(p_email)`.

---

## 2. Database Functions (RPCs)

These functions have been deployed to both **Test** and **Production** Supabase environments.

#### `claim_phone_number(p_phone text)`
*   **Purpose:** Removes the given phone number from ANY record where `auth_user_id` is NOT the current user.
*   **Use Case:** Call this *before* updating the user's profile with a new phone number.

#### `claim_orphan_email(p_email text)`
*   **Purpose:** Checks if there is an existing customer record with `email = p_email` AND `auth_user_id IS NULL`. If found, it links that record to the current authenticated user.
*   **Use Case:** Call this *before* updating the user's profile with a new email logic.

---

## 3. Required Web Frontend Changes

To ensure the Website behaves identically to the Mobile App, you must update the profile update logic in your Web repository (`shahirizada_fresh_market`).

### Target File: `src/lib/auth/client.ts` (or equivalent profile service)

You likely have valid `ensureCustomer` or `updateProfile` logic. You need to inject the RPC calls before performing the `update` or `insert`.

#### **Current Logic (Generic Example):**
```typescript
const { data, error } = await supabase
  .from('customers')
  .upsert({ email, phone, ... })
```

#### **New Required Logic:**

```typescript
// 1. Handle Email Orphan Claiming (Safe)
if (email && email.toLowerCase() === currentUser.email?.toLowerCase()) {
  try {
    await supabase.rpc('claim_orphan_email', { p_email: email });
  } catch (e) {
    console.warn('Failed to claim orphan email', e);
  }
}

// 2. Handle Phone Number Stealing (Latest Wins)
if (phone) {
  try {
    await supabase.rpc('claim_phone_number', { p_phone: phone });
  } catch (e) {
    console.warn('Failed to claim phone', e);
  }
}

// 3. Proceed with standard Update/Upsert
const { data, error } = await supabase
  .from('customers')
  .upsert({ 
    auth_user_id: user.id,
    email, 
    phone, 
    first_name, 
    last_name,
    // ... other fields
  })
```

### Why this is critical for the Web App:
1.  **Prevent Errors:** Without `claim_orphan_email`, web users who try to sign up with an email that exists as an orphan (e.g., `partner@sfdify.com`) will get a "Duplicate Key" error and be unable to create their profile.
2.  **Data Consistency:** Without `claim_phone_number`, web users handles phone conflicts differently than mobile users, leading to database fragmentation.

---

## 4. Mobile Implementation Reference

The mobile implementation can be found in `lib/features/auth/providers/auth_provider.dart` inside the `ensureCustomer` method.

```dart
// Mobile implementation snippet
if (email.isNotEmpty && email == user.email) {
  await supabase.rpc('claim_orphan_email', params: {'p_email': email});
}

if (phone != null) {
  await supabase.rpc('claim_phone_number', params: {'p_phone': phone});
}
```
