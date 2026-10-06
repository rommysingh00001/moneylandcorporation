# Moneyland Corporation – Premium Gurgaon Property Portal

Tagline used across the website: **Gurgaon Ki Har Property, Sirf Ek Baar, Malik Se Direct**

## Implemented in this build
- Full name **Moneyland Corporation** used throughout public UI.
- Premium dark/glass visual system with stronger mobile design, ambient bottom glow, hover depth, responsive navigation and fixed mobile bottom navigation.
- New local SVG logo: `assets/moneyland-corporation-logo.svg`.
- About page with the core vision:
  - one property = one public listing,
  - owner + Moneyland Corporation verification,
  - fewer listings but more genuine listings,
  - eligible buyer can bid directly on a verified owner listing after the required token/approval flow.
- Career page with direct resume email to `rrahmawat@gmail.com`.
- Gurgaon location directory expanded across sectors/localities.
- Gurgaon project directory expanded to **122 project entries** from major developer/project names represented in the frontend dataset.
- Dynamic project detail page based on the selected project URL.
- Builder floor vs flat/apartment property type is stored separately so an official image can be attached to the correct project/property type later.
- Public owner resale listings remain approval-gated.
- Bid gate remains: minimum token ₹50,000 for sale and ₹5,000 for rent, with admin approval required.
- Aadhaar login remains removed; Aadhaar is requested only in the owner listing verification workflow.

## Important source-verification rule
This environment does not provide live Google/web browsing for this build. Because the user explicitly requested **original/non-fake project imagery and accurate project facts**, this version intentionally does **not** invent project elevations, land-parcel sizes, tower counts, possession dates, prices or approvals. Project cards therefore show a source-verification placeholder when no verified official image is available.

Before production publication, each project should be populated from the builder's official website / latest RERA filing with:
- official project elevation/gallery image,
- land parcel size,
- project type,
- towers / floors where officially published,
- unit configurations,
- possession / construction status,
- RERA registration,
- current price/inventory,
- official source URL and source date.

This is deliberate: a blank verified field is safer than a fake fact or wrong project image.

## Production security note
The current login, bid approval and owner approval are frontend/demo state using browser localStorage. Do **not** use this implementation as a production Aadhaar/payment/admin system. A production release should use secure server-side authentication, Supabase/Postgres RLS, payment gateway webhooks, encrypted/controlled document storage and server-side admin permissions. Aadhaar should not be stored in browser localStorage or exposed in public HTML.
