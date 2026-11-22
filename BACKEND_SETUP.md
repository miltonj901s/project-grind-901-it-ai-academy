# Backend setup — Project Grind 901 Academy

## Database
The initial Supabase schema is in `supabase/schema.sql`. It creates profiles, courses, enrollments, lessons, attendance, assignments, submissions, projects, exams, exam attempts, boot camps and boot camp enrollments with Row Level Security.

## Connect the browser app
1. In Supabase, open **Project Settings → API Keys**.
2. Copy the **Project URL** and **publishable key** only.
3. In GitHub, open `supabase-config.js`, tap the pencil (Edit), replace the two placeholder strings, and commit the change to `main`.
4. Do not use or publish the `service_role` or any secret key. This repository is public.
5. In Supabase, open **Authentication → URL Configuration**.
6. Set **Site URL** to the exact published site origin, e.g. `https://futurevisiontech.org`.
7. Add the exact portal URL to **Redirect URLs**, e.g. `https://futurevisiontech.org/portal.html`. If you also use the GitHub Pages hostname, add that exact portal URL too.
8. Open `https://futurevisiontech.org/portal.html`. Create a test account with an email you can access. If email confirmation is enabled, click the confirmation link before signing in.

## Test expectations
- A new account should be assigned the `student` role by the database trigger.
- The signed-in portal should display the account email and its own profile role.
- A student should not be able to read another student's profile or academic records.
- Never test with real student personal information until the full security review is complete.

## Important current limitations
The portal currently provides basic Supabase email/password registration, sign-in, session display and sign-out. It does not yet implement password reset, MFA, course enrollment UI, attendance capture, file uploads, grading, secure exam delivery or instructor-specific course permissions. The initial RLS policy grants staff-wide access only to administrators; instructor permissions need course-scoped policies before instructors use real records. Review privacy, consent, retention, backups, email delivery and applicable education-record requirements before production use.
