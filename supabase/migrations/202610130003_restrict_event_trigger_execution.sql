-- This pre-existing event-trigger helper is not part of the product API.
-- Revoking RPC execution does not disable its database event-trigger binding.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
