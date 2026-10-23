# Thai Glass Inventory V4

## Included
- Product/stock management, sales invoices, daily accounts, monthly summary, JSON export/import.
- Per-product fixed or percentage pricing: chart/base price × buy percentage and sell percentage.
- Supabase email/password account UI, create a shared shop workspace, add existing employee accounts, and cloud JSON sync.
- Local-first storage: changes are saved on the device and queued for cloud sync when connected. Sync merges records by ID, but this is not a transaction-safe accounting system.

## Important: cloud sync requires one-time setup
1. Create a Supabase project.
2. Open **SQL Editor** and run the entire `supabase_schema.sql` file.
3. In Supabase Authentication settings, configure email sign-up. If email confirmation is enabled, users must confirm their email before signing in.
4. Open the app Settings. Enter the Project URL and the anon/publishable key from Project Settings → API. Never use the `service_role` key in the browser.
5. Create an account, sign in, then click **Create workspace**.
6. For an employee, have them create an account in the same Supabase project. The owner then enters their exact email under “Add employee”.
7. Open the same deployed app on the other device, enter the same URL/key, sign in with a member account, and sync.

## Data safety / limitations
- Do not rely on this prototype as the only accounting record until you test with sample data and export backups.
- Offline records are stored locally and sync on reconnect or after changes. If multiple devices edit the same existing record simultaneously, the simple JSON merge may not resolve every conflict safely.
- Current role support controls workspace membership only. The UI does not yet enforce different page/action permissions for employee vs manager; both roles can edit shared app data. Do not add staff accounts until that permission model is acceptable.
- Current daily report is a summary, not a full double-entry accounting ledger. Sales − purchases − expenses is an estimate, not audited profit.
- The legacy normalized SQL tables are schema groundwork; the current UI syncs the complete app state in `business_app_state`.
- Test purchases, sales, stock levels, backup restore, multi-device sync and employee access before real use.

## Deploy
Back up the current GitHub Pages files, then upload the contents of this folder. On iPhone, refresh the site after deployment; if an older page persists, close it and reopen after the service worker cache refreshes.
