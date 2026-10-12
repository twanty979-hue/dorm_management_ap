-- ==============================================================================
-- 🏢 DORMITORY SAAS SUPABASE POSTGRESQL SCHEMA (CLEAN RE-INIT SCRIPT)
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop existing partial tables to ensure clean schema
DROP TABLE IF EXISTS public.invoices CASCADE;
DROP TABLE IF EXISTS public.meter_readings CASCADE;
DROP TABLE IF EXISTS public.maintenance_tickets CASCADE;
DROP TABLE IF EXISTS public.lease_agreements CASCADE;
DROP TABLE IF EXISTS public.tenants CASCADE;
DROP TABLE IF EXISTS public.rooms CASCADE;
DROP TABLE IF EXISTS public.dorm_properties CASCADE;
DROP TABLE IF EXISTS public.organizations CASCADE;

-- 3. Organizations Table
CREATE TABLE public.organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_user_id UUID,
    phone VARCHAR(50),
    email VARCHAR(255),
    plan VARCHAR(50) DEFAULT 'pro',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Dorm Properties (หอพัก / สาขา)
CREATE TABLE public.dorm_properties (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    total_floors INT DEFAULT 5,
    water_rate NUMERIC(10,2) DEFAULT 18.00,
    electric_rate NUMERIC(10,2) DEFAULT 8.00,
    is_main_branch BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Rooms (ห้องพัก)
CREATE TABLE public.rooms (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id BIGINT REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_number VARCHAR(50) NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    room_type VARCHAR(100) DEFAULT 'ห้องแอร์ • เตียงเดี่ยว',
    base_rent_price NUMERIC(10,2) NOT NULL DEFAULT 4500.00,
    deposit_amount NUMERIC(10,2) DEFAULT 9000.00,
    status VARCHAR(50) NOT NULL DEFAULT 'vacant',
    amenities TEXT DEFAULT 'แอร์, เครื่องทำน้ำอุ่น, เตียง 5 ฟุต, ตู้เสื้อผ้า, WiFi',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Tenants (ผู้เช่า)
CREATE TABLE public.tenants (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    id_card_number VARCHAR(20),
    line_user_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Lease Agreements (สัญญาเช่า)
CREATE TABLE public.lease_agreements (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id BIGINT REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id BIGINT REFERENCES public.rooms(id) ON DELETE CASCADE,
    tenant_id BIGINT REFERENCES public.tenants(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_rent NUMERIC(10,2) NOT NULL,
    deposit_amount NUMERIC(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Maintenance Tickets (รายการแจ้งซ่อม)
CREATE TABLE public.maintenance_tickets (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id BIGINT REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id BIGINT REFERENCES public.rooms(id) ON DELETE CASCADE,
    tenant_id BIGINT REFERENCES public.tenants(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'normal',
    status VARCHAR(50) DEFAULT 'pending',
    technician_name VARCHAR(100),
    cost NUMERIC(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Meter Readings (จดมิเตอร์น้ำ-ไฟ)
CREATE TABLE public.meter_readings (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id BIGINT REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id BIGINT REFERENCES public.rooms(id) ON DELETE CASCADE,
    billing_month VARCHAR(7) NOT NULL,
    water_prev NUMERIC(10,2) DEFAULT 0,
    water_curr NUMERIC(10,2) NOT NULL,
    electric_prev NUMERIC(10,2) DEFAULT 0,
    electric_curr NUMERIC(10,2) NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Invoices (บิลใบแจ้งหนี้)
CREATE TABLE public.invoices (
    id BIGSERIAL PRIMARY KEY,
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id BIGINT REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id BIGINT REFERENCES public.rooms(id) ON DELETE CASCADE,
    tenant_id BIGINT REFERENCES public.tenants(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    billing_month VARCHAR(7) NOT NULL,
    rent_amount NUMERIC(10,2) NOT NULL,
    water_units NUMERIC(10,2) DEFAULT 0,
    water_total NUMERIC(10,2) DEFAULT 0,
    electric_units NUMERIC(10,2) DEFAULT 0,
    electric_total NUMERIC(10,2) DEFAULT 0,
    additional_fee NUMERIC(10,2) DEFAULT 0,
    discount NUMERIC(10,2) DEFAULT 0,
    grand_total NUMERIC(10,2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'unpaid',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Disable RLS for sandbox direct read/write
ALTER TABLE public.organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.dorm_properties DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lease_agreements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.meter_readings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices DISABLE ROW LEVEL SECURITY;

-- 12. Insert Default Org & Main Branch
DO $$
DECLARE
    default_org_id UUID := '6008008f-e0f5-4970-a4ce-da2f8abaa607';
BEGIN
    INSERT INTO public.organizations (id, name, email, plan)
    VALUES (default_org_id, 'The Green Residence', 'admin@greenresidence.com', 'pro')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.dorm_properties (id, org_id, name, address, water_rate, electric_rate, is_main_branch)
    VALUES (1, default_org_id, 'The Green Residence (สาขาหลัก)', '123 ถนนสุขุมวิท กรุงเทพฯ', 18.00, 8.00, true)
    ON CONFLICT (id) DO NOTHING;
END $$;
