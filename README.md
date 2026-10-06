# Moneyland Verified — Gurgaon Property Portal

Mobile-first static frontend + Supabase SQL starter.

## Branding / supplied details
- Moneyland Corporation
- Tagline: Gurgaon Ki Har Property, Sirf Ek Baar, Malik Se Direct
- Phone for all enquiries: +91 8178593108
- Email: rrahmawat@gmail.com
- Address: R1/205, M3M 65th Avenue, Sector 65, Gurgaon, Gurugram, Haryana - 122018
- HRERA registration shown in supplied certificate: RC/HARERA/GGM/4078/3673/2026/113
- GSTIN: NOT PROVIDED — add it before publishing.

## Important Aadhaar note
A static HTML site and Supabase Auth do not natively perform UIDAI Aadhaar authentication. The included Aadhaar screen is **testing/demo only** and intentionally does not store Aadhaar. For production, connect a compliant Aadhaar identity-verification provider and follow applicable law/privacy requirements. Never commit real Aadhaar data, secrets, service-role keys, or OTPs to GitHub.

## Supabase
1. Create a Supabase project.
2. Run `supabase.sql` in SQL Editor.
3. Create Storage buckets as specified in the SQL.
4. Put project URL + anon key in `supabase-config.js`.
5. Keep the Supabase service-role key server-side only; do not place it in HTML.

## Features in this frontend
- Mobile-first black / white / light-purple Moneyland visual system.
- Gurgaon sector/location search list and property-type filters.
- Residential + commercial + land categories.
- Owner listing form: document + max 10 photos + max 1 video.
- Owner dashboard with bid approve/reject concept; buyer/owner contact is not exposed.
- All enquiries route to Moneyland WhatsApp: +91 8178593108.
- Admin verification queue.
- Supplied RERA certificate and business card assets included.

## Before production
Connect real authentication, Supabase Storage uploads, RLS, admin authorization, field-verification workflow, WhatsApp backend, and compliant Aadhaar provider. Also add the actual GSTIN before claiming it publicly.
