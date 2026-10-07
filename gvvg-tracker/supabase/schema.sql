-- PPL(A) / SPL Revision Tracker — schéma Supabase (à exécuter dans SQL Editor)

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text not null default '' check (char_length(first_name) <= 60),
  last_name  text not null default '' check (char_length(last_name)  <= 60),
  quizlet_link text check (quizlet_link is null or quizlet_link ~* '^https://([a-z0-9-]+\.)*quizlet\.com(/|$)'),
  created_at timestamptz not null default now()
);

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_date date not null,
  minutes int not null check (minutes between 1 and 600),
  subject text not null check (subject in ('010','020','030','040','050','060','070','080','090')),
  note text check (note is null or char_length(note) <= 80),
  created_at timestamptz not null default now()
);
create index sessions_user_date_idx on public.sessions (user_id, session_date);

create table public.goals (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  subject text not null check (subject in ('010','020','030','040','050','060','070','080','090')),
  hours numeric not null check (hours >= 0 and hours <= 2000),
  primary key (user_id, subject)
);

-- Profil créé automatiquement à l'inscription (prénom / nom viennent du formulaire)
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, first_name, last_name)
  values (new.id,
          left(coalesce(new.raw_user_meta_data->>'first_name',''), 60),
          left(coalesce(new.raw_user_meta_data->>'last_name',''), 60));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Row Level Security : chaque utilisateur n'accède qu'à ses propres lignes
alter table public.profiles enable row level security;
alter table public.sessions enable row level security;
alter table public.goals    enable row level security;

revoke all on public.profiles, public.sessions, public.goals from anon;

create policy "profil: lecture" on public.profiles for select to authenticated using (id = (select auth.uid()));
create policy "profil: modification" on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "séances: lecture" on public.sessions for select to authenticated using (user_id = (select auth.uid()));
create policy "séances: ajout" on public.sessions for insert to authenticated with check (user_id = (select auth.uid()));
create policy "séances: modification" on public.sessions for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "séances: suppression" on public.sessions for delete to authenticated using (user_id = (select auth.uid()));

create policy "objectifs: lecture" on public.goals for select to authenticated using (user_id = (select auth.uid()));
create policy "objectifs: ajout" on public.goals for insert to authenticated with check (user_id = (select auth.uid()));
create policy "objectifs: modification" on public.goals for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "objectifs: suppression" on public.goals for delete to authenticated using (user_id = (select auth.uid()));
