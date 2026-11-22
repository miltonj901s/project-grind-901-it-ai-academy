-- Project Grind 901 Academy: initial Supabase schema
-- Run in Supabase SQL Editor after creating a Supabase project.
-- New signups are always students. Promote staff manually from the Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'student' check (role in ('student','instructor','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), 'student')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Backfill profiles for users who registered before this schema was installed.
insert into public.profiles (id, full_name, role)
select id, coalesce(raw_user_meta_data->>'full_name',''), 'student'
from auth.users
on conflict (id) do nothing;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.profiles
    where id = auth.uid() and role = 'admin');
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.profiles
    where id = auth.uid() and role = 'admin');
$$;

-- Prevent a user from changing their own role through the profile editor.
create or replace function public.protect_profile_role()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  if new.role is distinct from old.role and auth.uid() = old.id then
    raise exception 'Users cannot change their own role.';
  end if;
  new.updated_at = now();
  return new;
end;
$$;
drop trigger if exists protect_profile_role_trigger on public.profiles;
create trigger protect_profile_role_trigger before update on public.profiles
for each row execute procedure public.protect_profile_role();

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  division text not null check (division in ('IT & AI Business School','Interactive Gaming Lab')),
  description text not null default '',
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  status text not null default 'active' check (status in ('active','completed','withdrawn')),
  enrolled_at timestamptz not null default now(),
  unique(student_id, course_id)
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  content text not null default '',
  sort_order integer not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  session_date date not null default current_date,
  status text not null check (status in ('present','absent','late','excused')),
  recorded_by uuid references public.profiles(id) on delete set null,
  notes text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  instructions text not null default '',
  due_at timestamptz,
  points integer not null default 100 check (points >= 0),
  published boolean not null default false,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references public.assignments(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  submission_text text not null default '',
  file_url text,
  status text not null default 'submitted' check (status in ('draft','submitted','graded','returned')),
  grade numeric(7,2),
  feedback text not null default '',
  submitted_at timestamptz not null default now(),
  graded_by uuid references public.profiles(id) on delete set null,
  unique(assignment_id, student_id)
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses(id) on delete set null,
  title text not null,
  description text not null default '',
  due_at timestamptz,
  status text not null default 'planned' check (status in ('planned','active','completed')),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  instructions text not null default '',
  opens_at timestamptz,
  closes_at timestamptz,
  duration_minutes integer check (duration_minutes is null or duration_minutes > 0),
  published boolean not null default false,
  created_by uuid references public.profiles(id) on delete set null
);

create table if not exists public.exam_attempts (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  score numeric(7,2),
  status text not null default 'in_progress' check (status in ('in_progress','submitted','graded')),
  unique(exam_id, student_id)
);

create table if not exists public.bootcamps (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  starts_at timestamptz,
  ends_at timestamptz,
  capacity integer check (capacity is null or capacity > 0),
  published boolean not null default false,
  created_by uuid references public.profiles(id) on delete set null
);

create table if not exists public.bootcamp_enrollments (
  id uuid primary key default gen_random_uuid(),
  bootcamp_id uuid not null references public.bootcamps(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'registered' check (status in ('registered','completed','cancelled')),
  registered_at timestamptz not null default now(),
  unique(bootcamp_id, student_id)
);

create index if not exists enrollments_student_idx on public.enrollments(student_id);
create index if not exists enrollments_course_idx on public.enrollments(course_id);
create index if not exists attendance_student_date_idx on public.attendance(student_id, session_date);
create index if not exists assignments_course_idx on public.assignments(course_id);
create index if not exists submissions_student_idx on public.submissions(student_id);
create index if not exists lessons_course_order_idx on public.lessons(course_id, sort_order);

-- Enable row-level security on every table containing academy data.
alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.enrollments enable row level security;
alter table public.lessons enable row level security;
alter table public.attendance enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.projects enable row level security;
alter table public.exams enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.bootcamps enable row level security;
alter table public.bootcamp_enrollments enable row level security;

-- Until course-specific instructor assignments are implemented, only administrators
-- receive staff-wide access to student records. Instructor role access is intentionally
-- restricted rather than granting every instructor access to every student's data.

-- Prevent students from editing grades, feedback or grading identity on their own work.
create or replace function public.protect_submission_grade()
returns trigger language plpgsql security definer set search_path = public
as $
begin
  if auth.uid() = old.student_id and (
    new.grade is distinct from old.grade or
    new.feedback is distinct from old.feedback or
    new.graded_by is distinct from old.graded_by or
    new.assignment_id is distinct from old.assignment_id or
    new.student_id is distinct from old.student_id
  ) then
    raise exception 'Students cannot change grading fields or submission ownership.';
  end if;
  return new;
end;
$;
drop trigger if exists protect_submission_grade_trigger on public.submissions;
create trigger protect_submission_grade_trigger before update on public.submissions
for each row execute procedure public.protect_submission_grade();

-- Prevent students from changing exam scores or attempt ownership.
create or replace function public.protect_exam_attempt_score()
returns trigger language plpgsql security definer set search_path = public
as $
begin
  if auth.uid() = old.student_id and (
    new.score is distinct from old.score or
    new.exam_id is distinct from old.exam_id or
    new.student_id is distinct from old.student_id
  ) then
    raise exception 'Students cannot change exam scores or attempt ownership.';
  end if;
  return new;
end;
$;
drop trigger if exists protect_exam_attempt_score_trigger on public.exam_attempts;
create trigger protect_exam_attempt_score_trigger before update on public.exam_attempts
for each row execute procedure public.protect_exam_attempt_score();

-- Profiles
drop policy if exists "Profiles view own or admin" on public.profiles;
create policy "Profiles view own or admin" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_admin());
drop policy if exists "Profiles update own or admin" on public.profiles;
create policy "Profiles update own or admin" on public.profiles for update to authenticated
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

-- Course catalog: published courses are visible to signed-in users; staff manage catalog.
drop policy if exists "Read published courses or staff" on public.courses;
create policy "Read published courses or staff" on public.courses for select to authenticated
using (status = 'published' or public.is_staff());
drop policy if exists "Staff manage courses" on public.courses;
create policy "Staff manage courses" on public.courses for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Enrollments: students see their own; staff manage and review.
drop policy if exists "Read own enrollments or staff" on public.enrollments;
create policy "Read own enrollments or staff" on public.enrollments for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "Students create own enrollment" on public.enrollments;
create policy "Students create own enrollment" on public.enrollments for insert to authenticated
with check (student_id = auth.uid());
drop policy if exists "Staff manage enrollments" on public.enrollments;
create policy "Staff manage enrollments" on public.enrollments for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Lessons
drop policy if exists "Read published lessons or staff" on public.lessons;
create policy "Read published lessons or staff" on public.lessons for select to authenticated
using (published or public.is_staff());
drop policy if exists "Staff manage lessons" on public.lessons;
create policy "Staff manage lessons" on public.lessons for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Attendance
drop policy if exists "Read own attendance or staff" on public.attendance;
create policy "Read own attendance or staff" on public.attendance for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "Staff manage attendance" on public.attendance;
create policy "Staff manage attendance" on public.attendance for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Assignments and submissions
drop policy if exists "Read published assignments or staff" on public.assignments;
create policy "Read published assignments or staff" on public.assignments for select to authenticated
using (published or public.is_staff());
drop policy if exists "Staff manage assignments" on public.assignments;
create policy "Staff manage assignments" on public.assignments for all to authenticated
using (public.is_staff()) with check (public.is_staff());
drop policy if exists "Read own submissions or staff" on public.submissions;
create policy "Read own submissions or staff" on public.submissions for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "Students submit own work" on public.submissions;
create policy "Students submit own work" on public.submissions for insert to authenticated
with check (student_id = auth.uid());
drop policy if exists "Students update own ungraded work" on public.submissions;
create policy "Students update own ungraded work" on public.submissions for update to authenticated
using (student_id = auth.uid() and status in ('draft','submitted'))
with check (student_id = auth.uid() and status in ('draft','submitted'));
drop policy if exists "Staff grade submissions" on public.submissions;
create policy "Staff grade submissions" on public.submissions for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Projects
drop policy if exists "Read projects or staff" on public.projects;
create policy "Read projects or staff" on public.projects for select to authenticated
using (public.is_staff() or exists (select 1 from public.enrollments e where e.course_id = projects.course_id and e.student_id = auth.uid() and e.status = 'active'));
drop policy if exists "Staff manage projects" on public.projects;
create policy "Staff manage projects" on public.projects for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Exams: students can see published exam descriptions, but not any answer key table (none is created here).
drop policy if exists "Read published exams or staff" on public.exams;
create policy "Read published exams or staff" on public.exams for select to authenticated
using (published or public.is_staff());
drop policy if exists "Staff manage exams" on public.exams;
create policy "Staff manage exams" on public.exams for all to authenticated
using (public.is_staff()) with check (public.is_staff());
drop policy if exists "Read own attempts or staff" on public.exam_attempts;
create policy "Read own attempts or staff" on public.exam_attempts for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "Students create own attempts" on public.exam_attempts;
create policy "Students create own attempts" on public.exam_attempts for insert to authenticated
with check (student_id = auth.uid());
drop policy if exists "Students update own attempts" on public.exam_attempts;
create policy "Students update own attempts" on public.exam_attempts for update to authenticated
using (student_id = auth.uid() and status = 'in_progress')
with check (student_id = auth.uid());

-- Boot camps
drop policy if exists "Read published bootcamps or staff" on public.bootcamps;
create policy "Read published bootcamps or staff" on public.bootcamps for select to authenticated
using (published or public.is_staff());
drop policy if exists "Staff manage bootcamps" on public.bootcamps;
create policy "Staff manage bootcamps" on public.bootcamps for all to authenticated
using (public.is_staff()) with check (public.is_staff());
drop policy if exists "Read own bootcamp enrollments or staff" on public.bootcamp_enrollments;
create policy "Read own bootcamp enrollments or staff" on public.bootcamp_enrollments for select to authenticated
using (student_id = auth.uid() or public.is_staff());
drop policy if exists "Students register themselves" on public.bootcamp_enrollments;
create policy "Students register themselves" on public.bootcamp_enrollments for insert to authenticated
with check (student_id = auth.uid());
drop policy if exists "Staff manage bootcamp enrollments" on public.bootcamp_enrollments;
create policy "Staff manage bootcamp enrollments" on public.bootcamp_enrollments for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- IMPORTANT: Keep Supabase service_role keys server-side only. Never put them in this repository or browser code.
