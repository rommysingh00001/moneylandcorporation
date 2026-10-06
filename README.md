# Moneyland Corporation — upgraded Gurgaon property portal

Implemented in this package:
- Moneyland image logo used consistently across public HTML pages.
- Login/Register replaces Aadhaar Login as the public account entry.
- Aadhaar is requested only during owner/property verification, with a clear notice.
- Original/correct property-document data notice on listing form.
- Gurgaon locality/sector directory expanded with sectors 1–115 plus major corridors/localities.
- Public inventory focused on Fresh Booking; owner/resale listings remain hidden until approval.
- Fresh-booking project directory UI with builder/project/location cards and image URLs.
- Enquiry copy no longer exposes internal routing/workflow.
- Bid gate: ₹5,000 minimum token for rent and ₹50,000 for sale; bid unlocks only after admin approval state.
- Owner listing approval state; listings are public only after approval.
- GSTIN configured as 06CKJPR5013B1ZH.
- Premium responsive real-estate UI, stronger homepage, filters, project cards and mobile navigation.

Important production note:
The token payment and admin approval controls in this static package are demo/browser-local state. For production, connect the payment gateway, Supabase authentication, server-side admin roles, payment webhooks, storage and RLS policies before accepting real Aadhaar or payment data.
