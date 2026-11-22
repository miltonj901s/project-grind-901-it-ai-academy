# Backend setup — Project Grind 901 Academy

This project currently has a static GitHub Pages front end. This guide prepares a secure backend using Supabase; the database is not connected to the website yet.

## 1. Create the Supabase project
1. Visit https://supabase.com/ and create/sign in to an account.
2. Create a new project named `project-grind-901-academy`.
3. Choose a strong database password and save it privately.
4. Select a region suitable for your users and wait for provisioning.

## 2. Create the initial database
1. In the Supabase project, open **SQL Editor**.
2. Choose **New query**.
3. Open `supabase/schema.sql` in this GitHub repository and copy its complete contents.
4. Paste into SQL Editor and click **Run**.
5. Confirm the query completes without errors. Review any error before retrying.

The schema creates profiles, courses, enrollments, lessons, attendance, assignments, submissions, projects, exams, exam attempts, boot camps and boot camp enrollments. Row Level Security is enabled. New accounts receive the student role by default; users cannot promote themselves through their profile. In this initial version, only administrators receive staff-wide data access. Instructor access is intentionally restricted until course-specific instructor assignments and policies are implemented.

## 3. Create the first administrator safely
After you register your own account through Supabase Authentication, find that account's UUID in **Authentication → Users**. In SQL Editor, run this statement after replacing the UUID:

```sql
update public.profiles
set role = 'admin'
where id = 'REPLACE-WITH-YOUR-AUTH-USER-UUID';
```

Do not make public signup assign instructor or administrator roles.

## 4. Keep credentials safe
- The Supabase project URL and publishable/anon key may be used by a browser app when Row Level Security is correctly enabled.
- Never expose the `service_role` key, database password, or other secret keys in GitHub, HTML, JavaScript, screenshots or public messages.
- Do not enter real student records until authentication, policies, storage permissions, backups and privacy requirements have been tested.

## 5. What is not connected yet
GitHub Pages remains a static host. This SQL schema is a backend foundation only; it does not itself create login screens, connect the site to Supabase, upload assignment files, or verify attendance. The next development step is a tested sign-in flow using the Supabase client and the public project URL/key, followed by role-aware pages.

## 6. Initial test plan
- Register a test student account.
- Verify a profile row is created with role `student`.
- Verify the student cannot read another student's profile or records.
- Verify the student cannot change their own role.
- Promote a test staff account only from the SQL Editor.
- Verify staff-only actions are unavailable to students.
