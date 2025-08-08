-- 001_seed.sql
-- Seed sample tenant, user and some demo data.
-- Replace ids with your own values or run via Supabase SQL editor after creating tenant/user.

insert into tenants (id, name) values ('00000000-0000-0000-0000-000000000001','Demo Tenant') on conflict do nothing;
insert into users (id, email, name, tenant_id) values ('00000000-0000-0000-0000-000000000010','demo@example.com','Demo User','00000000-0000-0000-0000-000000000001') on conflict do nothing;

-- Sample transactions for demo user
insert into transactions (id, user_id, tenant_id, name, amount, type, category, date, currency) values
('tx_demo_1','00000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000001','Sueldo',1200,'income','Salario',now(),'USD')
on conflict do nothing;
