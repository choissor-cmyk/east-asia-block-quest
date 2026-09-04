create table if not exists public.history_attempts (
  student_id text primary key,
  student_name text not null,
  score integer not null default 0,
  total_questions integer not null default 15,
  completed boolean not null default false,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  duration_ms bigint,
  created_at timestamptz not null default now()
);

alter table public.history_attempts enable row level security;
revoke all on table public.history_attempts from anon, authenticated;

create or replace function public.start_attempt(p_student_id text,p_student_name text)
returns table(already_completed boolean,score integer,duration_ms bigint)
language plpgsql security definer set search_path=public as $$
declare r public.history_attempts;
begin
  select * into r from public.history_attempts where student_id=p_student_id;
  if found then return query select r.completed,r.score,r.duration_ms; return; end if;
  insert into public.history_attempts(student_id,student_name) values(p_student_id,p_student_name);
  return query select false,0,null::bigint;
end; $$;

create or replace function public.finish_attempt(p_student_id text,p_score integer,p_total_questions integer)
returns table(rank bigint,total_completed bigint,score integer,duration_ms bigint)
language plpgsql security definer set search_path=public as $$
declare r public.history_attempts;
begin
  update public.history_attempts set
    score=greatest(0,least(p_score,p_total_questions)), total_questions=p_total_questions,
    completed=true, finished_at=now(),
    duration_ms=greatest(0,floor(extract(epoch from (now()-started_at))*1000)::bigint)
  where student_id=p_student_id and completed=false;
  select * into r from public.history_attempts where student_id=p_student_id;
  return query with ranked as (
    select student_id,row_number() over(order by history_attempts.score desc,history_attempts.duration_ms asc,history_attempts.finished_at asc) rk
    from public.history_attempts where completed=true
  ) select ranked.rk,(select count(*) from public.history_attempts where completed=true),r.score,r.duration_ms
  from ranked where ranked.student_id=p_student_id;
end; $$;

create or replace function public.get_rank(p_student_id text)
returns table(rank bigint,total_completed bigint,score integer,duration_ms bigint)
language sql security definer set search_path=public as $$
  with ranked as (
    select student_id,history_attempts.score,history_attempts.duration_ms,
    row_number() over(order by history_attempts.score desc,history_attempts.duration_ms asc,history_attempts.finished_at asc) rk
    from public.history_attempts where completed=true
  )
  select rk,(select count(*) from public.history_attempts where completed=true),ranked.score,ranked.duration_ms
  from ranked where student_id=p_student_id;
$$;

grant execute on function public.start_attempt(text,text) to anon,authenticated;
grant execute on function public.finish_attempt(text,integer,integer) to anon,authenticated;
grant execute on function public.get_rank(text) to anon,authenticated;

-- 다음 반/다음 수업 전에 기록을 모두 지우려면 아래 명령만 별도로 실행하세요.
-- truncate table public.history_attempts;