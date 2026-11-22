# Project Grind 901 Academy

Futurevision Technologies IT & AI Interactive Gaming Lab and Business School.

## Mobile-first application
- Responsive academy dashboard and course catalog
- IT & AI Business School and Interactive Gaming Lab divisions
- Student sign-in and registration portal (Supabase connection configuration required)
- Installable web-app manifest and basic offline app shell

## Supabase setup
1. Open `supabase-config.js` in GitHub and replace the two placeholders with your Supabase Project URL and **publishable** key.
2. Never put a Supabase secret key, service_role key or database password in this public repository.
3. In Supabase Authentication → URL Configuration, set the Site URL to your published site and add the exact portal URL to Redirect URLs, for example `https://futurevisiontech.org/portal.html`.
4. Open `https://futurevisiontech.org/portal.html` and test registration using a test email address.
5. New signups receive the student role. Promote staff only through a controlled administrator process.

The database schema is in `supabase/schema.sql`. See [BACKEND_SETUP.md](BACKEND_SETUP.md). Course records and student workflow screens are not yet fully connected.

## Security
The repository is public. Only the Supabase URL and publishable key belong in browser configuration. RLS must remain enabled. Do not enter real student records until authentication, policies, file storage, backups and privacy requirements are tested.
