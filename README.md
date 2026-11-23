# Futurevision Technologies — IT & AI Learning Center

**PLAY • LEARN • GROW • SUCCEED**

A mobile-first React + Vite Progressive Web App for Futurevision Technologies, including the IT & AI Learning Center and Game Bus & Learning Center.

## Included
- Responsive dashboard and installable PWA shell.
- Eight IT and AI course pathways with module player and local progress tracking.
- Twelve educational gaming categories and an interactive Python mini-game.
- Boot camp catalog, Game Bus program hub, project lab and portfolio.
- AI tutor interaction demo, achievement tracking and printable institutional certificate.
- Student/instructor/administrator role preview and Guardian Safety Mode preference.
- Supabase client adapter and PostgreSQL/RLS starter schema.
- Google OAuth / Classroom / Calendar / Meet connection status adapters (not falsely marked connected).

## Run locally
1. Install Node.js 20 or later.
2. Copy `.env.example` to `.env.local`.
3. Add Supabase Project URL and publishable key only if using Supabase.
4. Run `npm install`.
5. Run `npm run dev`.

## Build
Run `npm run build`.

## Logo
Upload the approved brand artwork to `public/futurevision-logo.png`. Until then, the app displays an FV fallback emblem.

## Supabase
Run `supabase/schema.sql` in the Supabase SQL editor. Configure Auth redirect URLs for the deployed origin. Assign instructor/admin roles only through a trusted administrative process; never expose service-role credentials in the browser.

## Google integrations
Configure a Google Cloud OAuth consent screen and client ID. Classroom, Calendar and Meet features require approved OAuth scopes, user consent, API enablement and secure token handling. A client ID alone does not complete the integration. Do not store Gemini API keys in VITE_ variables; AI requests must go through a trusted server endpoint.

## Deployment
Deploy the Vite `dist/` output to a static host. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in the host environment. Add the deployed origin to Supabase Auth redirect URLs. Verify HTTPS, service worker, manifest and install behavior on target devices.

## Safety and production readiness
Local demo progress is stored in the browser and is not a secure student record system. Role switching is a UI preview, not authorization. Guardian Safety Mode is a preference only, not a substitute for guardian consent, moderation, child privacy compliance or staff supervision. Before enrolling real students, complete privacy/legal review, accessibility review, security testing, backup/restore testing, storage policies, email delivery and role-scoped instructor authorization. Institutional certificates are not third-party professional certifications or accreditation.
