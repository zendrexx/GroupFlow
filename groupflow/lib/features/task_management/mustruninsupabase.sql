-- ─────────────────────────────────────────────────────────────────
-- GroupFlow · FR-005 Task Management
-- Run this in Supabase SQL Editor
-- Assumes: auth.users and a `project_members` table from FR-003/004
-- ─────────────────────────────────────────────────────────────────

create type task_priority as enum ('low', 'medium', 'high');
create type task_status   as enum ('todo', 'doing', 'done');

create table public.tasks (
  task_id      uuid primary key default gen_random_uuid(),
  project_id   uuid not null references public.projects(project_id) on delete cascade,
  title        text not null,
  description  text not null default '',
  assigned_to  uuid references auth.users(id) on delete set null,
  created_by   uuid not null references auth.users(id),
  priority     task_priority not null default 'medium',
  status       task_status   not null default 'todo',
  due_date     timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  completed_at timestamptz
);

-- Auto-update updated_at on every row change
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger tasks_updated_at
  before update on public.tasks
  for each row execute procedure public.set_updated_at();

-- Auto-set completed_at when status flips to done, clear when reopened
create or replace function public.handle_task_completion()
returns trigger language plpgsql as $$
begin
  if new.status = 'done' and old.status != 'done' then
    new.completed_at = now();
  elsif new.status != 'done' and old.status = 'done' then
    new.completed_at = null;
  end if;
  return new;
end;
$$;

create trigger tasks_completion
  before update on public.tasks
  for each row execute procedure public.handle_task_completion();

-- Indexes for common queries
create index tasks_project_id_idx  on public.tasks(project_id);
create index tasks_assigned_to_idx on public.tasks(assigned_to);
create index tasks_status_idx      on public.tasks(status);
create index tasks_due_date_idx    on public.tasks(due_date);

-- Enable realtime for live kanban updates
alter publication supabase_realtime add table public.tasks;

-- ─────────────────────────────────────────────────────────────────
-- Row Level Security
-- ─────────────────────────────────────────────────────────────────
alter table public.tasks enable row level security;

-- Helper: is the current user a member of the project?
create or replace function public.is_project_member(pid uuid)
returns boolean language sql security definer as $$
  select exists (
    select 1 from public.project_members
    where project_id = pid
      and user_id = auth.uid()
  );
$$;

-- Helper: is the current user an owner or admin of the project?
create or replace function public.is_project_admin(pid uuid)
returns boolean language sql security definer as $$
  select exists (
    select 1 from public.project_members
    where project_id = pid
      and user_id = auth.uid()
      and role in ('owner', 'admin')
  );
$$;

-- SELECT: any project member can read tasks
create policy "members can view tasks"
  on public.tasks for select
  using (public.is_project_member(project_id));

-- INSERT: only owner/admin can create tasks
create policy "admins can create tasks"
  on public.tasks for insert
  with check (public.is_project_admin(project_id));

-- UPDATE: owner/admin can update any field;
--         assigned member can update only status
create policy "admins can update tasks"
  on public.tasks for update
  using (public.is_project_admin(project_id));

create policy "assigned member can update status"
  on public.tasks for update
  using (assigned_to = auth.uid())
  with check (
    assigned_to = auth.uid()
    and project_id = (select project_id from public.tasks where task_id = tasks.task_id)
  );

-- DELETE: only owner/admin can delete tasks
create policy "admins can delete tasks"
  on public.tasks for delete
  using (public.is_project_admin(project_id));
