# Project Grind 901 Academy

Futurevision Technologies IT & AI Interactive Gaming Lab and Business School.

## Mobile-first application
- Responsive dashboard and navigation
- IT & AI Business School and Interactive Gaming Lab divisions
- Sample course catalog
- Preview areas for attendance, coursework, homework, projects, exams, boot camps and administration
- Installable web-app manifest and basic offline app shell

## Backend foundation
The `supabase/schema.sql` file defines the initial Supabase database and row-level security policies. Follow [BACKEND_SETUP.md](BACKEND_SETUP.md) to configure it. The database is not yet connected to the public website; the current GitHub Pages site is a front-end prototype.

## Publish with GitHub Pages
Repository **Settings → Pages → Deploy from a branch → main → /(root)**.

## Security notice
Do not enter real student information yet. Live authentication, secure file storage, grading workflows, exam controls, backups, privacy review and full security testing are not complete. Never put Supabase service-role keys or database passwords in this public repository.

## Roadmap
1. Configure Supabase and run the schema
2. Test student registration and role protection
3. Connect the website to Supabase authentication
4. Build course enrollment and lesson delivery
5. Build verified attendance and assignment submissions
6. Add projects, exams, grading and feedback
7. Add boot camp registration and certificates
