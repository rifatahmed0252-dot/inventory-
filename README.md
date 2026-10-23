# Inventory Manager — First Prototype

## What this package is
A mobile-friendly, bilingual (Bangla/English) local prototype for an aluminium and glass shop. It supports:
- Add/edit products and categories
- Units and optional section length (e.g. 21 ft, 18.5 ft)
- Stock in and stock out with movement history
- Basic sales and printable invoice
- BDT formatting
- Local JSON backup export/import
- PWA shell/service-worker caching

## Important limitations
This is **not yet a production multi-user cloud app**. Data is stored in the browser on the current device. Separate employee login, cloud sync, cross-device data sharing, robust offline conflict resolution, supplier purchase invoices, and secure permissions require a Supabase project and further integration/testing.

Do not enter sensitive business data into the prototype as if it were already backed up online. Export a JSON backup regularly while testing.

## Run locally
Open `index.html` in a modern browser for basic testing. PWA installation and service-worker offline caching generally require HTTPS or localhost. For a quick local server, use Python:
`python -m http.server 8000`
Then open `http://localhost:8000`.

## Suggested next step
1. Create a Supabase project.
2. Review `supabase_schema.sql` with a developer.
3. Apply the schema, enable Row Level Security on all tables, and write business-scoped policies.
4. Implement secure sign-in and role management.
5. Implement transactional sale posting and conflict-safe sync queue before production use.
6. Test two devices, offline edits, simultaneous sales, backup/restore, and employee permissions.

## Security
Never put a Supabase service-role key in client-side code. Use only the public anon/publishable key in the browser, with correct RLS policies.
