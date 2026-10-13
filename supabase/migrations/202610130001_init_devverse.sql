-- DEVVERSE STUDIO initial schema. All timestamps are timestamptz (stored in UTC).
create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  timezone text not null default 'Asia/Kolkata',
  theme text not null default 'dark' check (theme in ('dark','light')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 120),
  description text not null default '', status text not null default 'active' check (status in ('active','on_hold','completed','archived')),
  priority text not null default 'medium' check (priority in ('low','medium','high')),
  color text not null default '#8b7cf6' check (color ~ '^#[0-9A-Fa-f]{6}$'), start_date date, deadline date,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (id,user_id), check (start_date is null or deadline is null or deadline >= start_date)
);
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  project_id uuid, title text not null check (char_length(trim(title)) between 1 and 240), description text not null default '',
  status text not null default 'todo' check (status in ('todo','in_progress','done')),
  priority text not null default 'medium' check (priority in ('low','medium','high')), due_date date,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key (project_id,user_id) references public.projects(id,user_id) on delete set null (project_id)
);
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 180), description text not null default '',
  start_at timestamptz not null, end_at timestamptz not null, all_day boolean not null default false,
  color text not null default '#8b7cf6' check (color ~ '^#[0-9A-Fa-f]{6}$'),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check (end_at > start_at)
);
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  project_id uuid, title text not null default 'Untitled note' check (char_length(title) <= 180),
  body text not null default '', created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key (project_id,user_id) references public.projects(id,user_id) on delete set null (project_id)
);
create table if not exists public.portfolio_items (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 140), description text not null default '',
  cover_url text, technologies text[] not null default '{}', category text not null default 'Project',
  repository_url text, demo_url text, is_published boolean not null default false,
  sort_order integer not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (repository_url is null or repository_url ~ '^https://'), check (demo_url is null or demo_url ~ '^https://'),
  check (cover_url is null or cover_url ~ '^https://')
);

create index if not exists projects_user_updated_idx on public.projects(user_id,updated_at desc);
create index if not exists tasks_user_due_idx on public.tasks(user_id,due_date,status);
create index if not exists tasks_project_idx on public.tasks(project_id);
create index if not exists events_user_start_idx on public.events(user_id,start_at);
create index if not exists notes_user_updated_idx on public.notes(user_id,updated_at desc);
create index if not exists portfolio_public_idx on public.portfolio_items(user_id,sort_order) where is_published;

do $$ declare t text; begin
  foreach t in array array['profiles','projects','tasks','events','notes','portfolio_items'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('drop trigger if exists set_updated_at on public.%I',t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',t);
  end loop;
end $$;

drop policy if exists "profile owner access" on public.profiles;
create policy "profile owner access" on public.profiles for all to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));
drop policy if exists "project owner access" on public.projects;
create policy "project owner access" on public.projects for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists "task owner access" on public.tasks;
create policy "task owner access" on public.tasks for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists "event owner access" on public.events;
create policy "event owner access" on public.events for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists "note owner access" on public.notes;
create policy "note owner access" on public.notes for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists "portfolio private and published access" on public.portfolio_items;
create policy "portfolio private and published access" on public.portfolio_items for select to anon, authenticated using (is_published or user_id = (select auth.uid()));
create policy "portfolio owner insert" on public.portfolio_items for insert to authenticated with check (user_id = (select auth.uid()));
create policy "portfolio owner update" on public.portfolio_items for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "portfolio owner delete" on public.portfolio_items for delete to authenticated using (user_id = (select auth.uid()));

-- Create a minimal profile for new accounts. Users can subsequently edit it via RLS.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data ->> 'display_name','')); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
