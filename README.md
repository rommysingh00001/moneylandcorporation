# Moneyland Corporation — Gurgaon Verified Property Portal

This ZIP is a static HTML/CSS/JS front-end plus a production-oriented Supabase SQL blueprint.

## Included
- Gurgaon-first search directory with sectors 1–115 and a broad seed of roads, colonies, corridors and project/locality names.
- Zoomable OpenStreetMap/Leaflet map.
- Structured property-posting form covering flats, luxury/builder floors, villas, plots, retail, showrooms, food courts, offices, industrial land, agricultural land, farmhouses, warehouses, rental/PG and commercial assets.
- Owner verification queue and admin approval UI.
- Public verified-listing concept: one public listing per property identity.
- WhatsApp enquiry CTA throughout the site.
- Bid flow messaging: ₹5,000 refundable rental security deposit; ₹50,000 refundable purchase security deposit.
- ₹1,00,000 lifetime brokerage-free plan page; otherwise stated 1% brokerage subject to final agreed terms.
- About / vision / Career / Contact pages.
- Admin CMS structure for hero slides, listings, locations, partners and media.
- Supabase schema with profiles, properties, media, inquiries, bids, subscriptions, hero slides, locations and builder partners, plus RLS starter policies.

## Company details
Moneyland Corporation
R1/205, M3M 65th Avenue, Sector 65, Gurgaon, Gurugram, Haryana - 122018
Phone / WhatsApp: 8178593108
Email: rrahmawat@gmail.com
GSTIN: 06CKJPR5013B1ZH
RERA: RC/HARERA/GGM/4078/3673/2026/113
Tagline: Gurgaon Ki Har Property, Sirf Ek Baar, Malik Se Direct

## Important production/security note
A pure HTML website cannot safely implement Aadhaar authentication, real ownership verification, payment settlement/refunds, or privileged admin access by itself. This build therefore does NOT store raw Aadhaar numbers in localStorage and does not pretend that browser-side approval is a secure verification system.

For live production:
1. Connect Supabase Auth.
2. Use a compliant identity/Aadhaar verification provider through a server/Edge Function; store only provider reference + minimal verification metadata, not raw Aadhaar in public tables.
3. Put property documents and private owner media in private Supabase Storage buckets.
4. Use Supabase RLS + admin custom claims/role table for admin operations.
5. Connect Razorpay (or another compliant gateway) through server-side order creation and webhook verification for bid deposits/subscription.
6. Implement automated refund workflow for refundable bid deposits according to the published terms.
7. Replace seed project images/details with official/licensed builder/RERA sources before publishing as factual project information.
8. Populate the location CMS with the exact Gurgaon locality/road dataset you want to maintain; no third-party portal's proprietary database is copied.

## Deployment
You can host the static files on GitHub Pages, Vercel static hosting or any web server. For the full live version, connect the Supabase project and implement the server-side verification/payment functions described above.
