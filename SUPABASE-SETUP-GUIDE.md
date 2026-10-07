# Moneyland Corporation — Supabase Setup Guide

## 1. Create / open your Supabase project
- Open your Supabase dashboard.
- Copy **Project URL** and **anon/public key**.
- Put them only in `supabase-config.js`.
- Never put a `service_role` key in browser code.

Example:
```js
window.SUPABASE_CONFIG={
  url:'https://YOUR-PROJECT.supabase.co',
  anonKey:'YOUR_PUBLIC_ANON_KEY'
};
```

## 2. Run the database SQL
1. Supabase → SQL Editor → New query.
2. Open `supabase.sql` from this ZIP.
3. Paste the complete SQL.
4. Run it.
5. Refresh Table Editor and confirm tables such as `profiles`, `properties`, `property_media`, `inquiries`, `bids`, `subscriptions`, `hero_slides`, `branding_assets`, `builder_partners`, `locations` and `projects`.

## 3. Storage buckets
Create the buckets described in `supabase.sql`:
- `property-media` — public/controlled listing media according to your final RLS policy.
- `property-documents` — **private**; never expose owner documents publicly.
- `branding` — logo/branding assets.
- `project-media` — official/licensed project images.

## 4. Admin user
For production, do **not** put an admin password in HTML/JS.
1. Supabase → Authentication → Users → Add user.
2. Create your personal admin email/password.
3. Add an admin role/custom claim using a secure server/Edge Function or your chosen role architecture.
4. Protect admin database actions with RLS.
5. Keep `admin.html` inaccessible to non-admin users at the application/auth layer.

The ZIP's `admin-login.html` is an entry/guide page, not a secure authentication system.

## 5. Add project details
Use the `projects` table for: name, developer, location, land parcel, tower/block count, building height, unit sizes, current/indicative pricing, brief and official/licensed image paths.

Important: use builder/RERA/official documents or properly licensed media. Do not copy Google Images or another portal's proprietary database into Moneyland without permission.

## 6. Add Gurgaon locations
Use the `locations` table for sectors, roads, colonies and villages/localities. Keep project names separate in `projects`.

## 7. Owner properties
The live version should insert verified properties into `properties`, media references into `property_media`, and keep documents in the private document bucket. Public listing approval should be controlled server-side/RLS.

## 8. Payments
The ₹5,000 rental bid deposit, ₹50,000 purchase bid deposit and ₹1,00,000 lifetime brokerage-free plan need a real payment gateway (e.g. Razorpay) with server-side order creation, webhook verification and refund handling. Do not trust browser-side payment success flags.

## 9. Aadhaar / identity
Do not store raw Aadhaar in localStorage or public tables. Use a compliant identity-verification provider and store only the minimum provider reference/verification metadata required for your workflow.

## 10. Deployment
After adding Supabase values and wiring the production Auth/DB functions, push the files to GitHub and deploy the root folder on Vercel.
