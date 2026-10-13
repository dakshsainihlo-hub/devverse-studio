-- Limit browser-visible grants to intended operations; RLS remains authoritative.
revoke all on table public.profiles, public.projects, public.tasks, public.events, public.notes, public.portfolio_items from anon;
revoke all on table public.profiles, public.projects, public.tasks, public.events, public.notes, public.portfolio_items from public;
grant select on table public.portfolio_items to anon;
grant select, insert, update, delete on table public.profiles, public.projects, public.tasks, public.events, public.notes, public.portfolio_items to authenticated;

alter function public.set_updated_at() set search_path = '';
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.set_updated_at() from public, anon, authenticated;
