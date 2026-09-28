# CampusCanteen — Canteen Preorder App

A Flutter app for college canteen preordering with a **Supabase backend**: real-time
sync between staff and students, **advance booking** (today or tomorrow), and an
in-app + device **notification system**.

## Features

- **Auth** with Supabase (email/password, session persistence)
- **Menu** stored in Supabase; staff availability/price edits sync live to students
- **Advance booking** — students choose Today or Tomorrow on checkout, and pick a
  30-minute slot (booked volume shown per slot)
- **Real-time order sync** — staff and students see order status changes instantly,
  no reload or refresh needed (Supabase Realtime)
- **Notifications** — in-app inbox + banner for every order event (order placed for
  staff, status changed for students), plus device notifications on Android/iOS

## Setup

### 1. Create a Supabase project

Go to https://supabase.com → New project. Copy the **Project URL** and the **anon
public key** from *Settings → API*.

### 2. Run the database schema

Open `supabase/schema.sql` and run the **whole file** in the Supabase SQL editor.
This creates all tables, row-level security, the ordering RPCs, and realtime
publications. There is no seed menu — as **canteen staff**, add menu items from
the **Menu** tab inside the app so students can see and order them.

### 3. Configure the app

Copy `.env.example` to `.env` and fill in your credentials. `.env` is git-ignored.

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
```

**Email confirmation is ON.** After signing up, the app waits for you to click
the confirmation link in your inbox; the link opens the app again and signs you
in automatically.

**Required:** in Supabase → Authentication → URL Configuration → Redirect URLs,
add

```
canteen://auth-callback
```

Leave **Confirm email** enabled (Authentication → Sign In / Providers). Turning
it off also works — accounts then activate instantly and skip the email step
entirely — but the redirect URL above should be registered either way.

### 4. Run

```bash
flutter pub get
flutter run
```

If credentials are missing, the app shows an on-screen setup guide instead of
crashing.

## Using it

1. **Sign up** accounts choosing one of the **three roles** at sign-up:
   - **Student** — browse and order. Roll number is asked here only.
   - **College Staff** — sees the staff dashboard (orders + analytics).
   - **Canteen Staff** — staff dashboard **plus** the **Menu** tab, the only role
     allowed to add / edit / delete menu items.
2. Students browse the menu, add to cart, choose **Today / Tomorrow**, pick a time
   slot, and pay (payment is simulated; slot capacity is enforced server-side).
3. Staff see new orders appear instantly in **Orders** (Pending Approval) and move
   them through Preparing → Ready for Pickup → Completed.
4. Every status change pushes a notification to the student (bell icon, banner, and
   an OS notification on Android/iOS).
5. Menu availability toggles / new items added by canteen staff appear instantly on
   all devices.

## Test accounts

There are no seeded accounts — create accounts via **Sign Up**. The role chosen in
the signup form decides the home screen: **Student**, **College Staff**, or
**Canteen Staff** (the only role with menu management).

## Notes

- **Payment** is simulated (`PaymentService`). Swap in a real gateway later.
- **Background push** (device in kill state) needs Firebase Cloud Messaging. The app
  currently delivers notifications in-app, in the foreground, and as local
  notifications on device. See `LocalNotifier`.

## Testing

```bash
flutter analyze
flutter test
```