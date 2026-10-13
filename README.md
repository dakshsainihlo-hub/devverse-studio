# DEVVERSE STUDIO

DEVVERSE STUDIO is a personal workspace for projects, tasks, calendar events, notes, and a selectively published portfolio. It uses browser ES modules and Supabase Auth/Postgres. The browser uses only the Supabase project URL and publishable key; RLS enforces ownership.

## Setup

1. Use Python 3 or another static file server. Run `npm run serve` or `python3 -m http.server 4173`.
2. The app uses the Supabase client from esm.sh at runtime, so the browser needs access to that CDN.
3. Migrations are already applied to Supabase project `wszxwukdmigrgufvghnf`; `public/config.js` contains its API URL and publishable key. Never use a service-role key here.
4. In Supabase Auth, set the site URL and allowed redirect URLs for local development and the production domain. Configure email confirmation and SMTP according to the account's needs.

## Production

Deploy this directory as a static site; `vercel.json` describes static output. Vercel project creation and deployment still require an authorized Vercel connection or account UI. This project does not include privileged server credentials.

## Data and security

Tables: `profiles`, `projects`, `tasks`, `events`, `notes`, and `portfolio_items`. The migrations enable RLS on every table, apply owner policies, validate project ownership through composite foreign keys, and permit anonymous reads only for explicitly published portfolio items. Deleting a project detaches its tasks and notes; deleting an account cascades that user's data. Portfolio links must use HTTPS. Events use UTC `timestamptz`, displayed and edited in the profile's timezone.

## Current limits

The UI implements Supabase Auth (including reset flow), CRUD for projects, tasks, events, notes, and portfolio records, and profile/theme/timezone preferences. Portfolio editing is private by default; public profile pages, activity feeds, advanced analytics, and storage uploads are not part of this build. The analytics page reports record totals and project status distribution. No sample dashboard metrics are fabricated. Privacy and terms drafts need the operator identity, contact channel, jurisdiction and launch practices completed before public commercial launch.
