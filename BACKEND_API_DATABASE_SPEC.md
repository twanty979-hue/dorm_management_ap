# 🏢 Dormitory SaaS Backend Architecture, Database Schema & API Specification

เอกสารข้อกำหนดเชิงเทคนิคฉบับสมบูรณ์ (Production-ready Technical Specification) สำหรับระบบบริหารจัดการหอพักและอพาร์ตเมนต์แบบ **Multi-Tenant SaaS** ครอบคลุมโครงสร้างฐานข้อมูล PostgreSQL/Supabase, นโยบายความปลอดภัย Row Level Security (RLS), และ RESTful API Endpoints ครบทุกฟังก์ชัน พร้อม Request/Response Payloads

---

## 📌 สารบัญ (Table of Contents)
1. [สถาปัตยกรรมระบบและความปลอดภัย (Architecture & Multi-Tenancy)](#1-สถาปัตยกรรมระบบและความปลอดภัย-architecture--multi-tenancy)
2. [โครงสร้างฐานข้อมูลฉบับสมบูรณ์ (Complete Database Schema & DDL)](#2-โครงสร้างฐานข้อมูลฉบับสมบูรณ์-complete-database-schema--ddl)
3. [นโยบายความปลอดภัย Row Level Security (RLS Policies)](#3-นโยบายความปลอดภัย-row-level-security-rls-policies)
4. [มาตรฐาน RESTful API & Error Handling](#4-มาตรฐาน-restful-api--error-handling)
5. [ข้อกำหนด API รายโมดูล (API Endpoints Specification)](#5-ข้อกำหนด-api-รายโมดูล-api-endpoints-specification)
   - [5.1 ระบบยืนยันตัวตนและองค์กร (Auth & Organization)](#51-ระบบยืนยันตัวตนและองค์กร-auth--organization)
   - [5.2 ระบบหอพักและห้องพัก (Properties & Rooms)](#52-ระบบหอพักและห้องพัก-properties--rooms)
   - [5.3 ระบบผู้เช่าและสัญญาเช่า (Tenants & Leases)](#53-ระบบผู้เช่าและสัญญาเช่า-tenants--leases)
   - [5.4 ระบบจดเลขมิเตอร์น้ำ-ไฟ (Meter Reading)](#54-ระบบจดเลขมิเตอร์น้ำ-ไฟ-meter-reading)
   - [5.5 ระบบออกใบแจ้งหนี้และการชำระเงิน (Invoicing & Payments)](#55-ระบบออกใบแจ้งหนี้และการชำระเงิน-invoicing--payments)
   - [5.6 ระบบแจ้งซ่อมและงานช่าง (Maintenance Tickets)](#56-ระบบแจ้งซ่อมและงานช่าง-maintenance-tickets)
   - [5.7 ระบบเชื่อมต่อ LINE Official Account (LINE OA & Webhook)](#57-ระบบเชื่อมต่อ-line-official-account-line-oa--webhook)
   - [5.8 ระบบรายงานการเงินและแดชบอร์ด (Financial Analytics)](#58-ระบบรายงานการเงินและแดชบอร์ด-financial-analytics)

---

## 1. สถาปัตยกรรมระบบและความปลอดภัย (Architecture & Multi-Tenancy)

### 1.1 Multi-Tenant Data Isolation Strategy
- ใช้โมเดล **Shared Database, Shared Schema with Tenant Isolation** โดยทุกตารางในการดำเนินงานจะมีคอลัมน์ `org_id` (UUID) เป็น Foreign Key ผูกกับ `organizations.id`
- การแยกข้อมูลระหว่างลูกค้าแต่ละเจ้า (Data Isolation 100%) ถูกบังคับใช้ในระดับ Database Layer ผ่าน **PostgreSQL Row Level Security (RLS)**

### 1.2 สิทธิ์การใช้งาน (Role-Based Access Control - RBAC)
- **`owner`** (เจ้าของหอพัก / ผู้ดูแลหลัก): สิทธิ์เต็มทุกระบบ จัดการแพ็กเกจ SaaS, เพิ่ม-ลบทีมงาน, ลบข้อมูลหอพัก
- **`manager`** (ผู้จัดการหอพัก): จัดการห้องพัก, สัญญา, ออกบิล, ตรวจสลิป, ยิง LINE Broadcast (ไม่สามารถจัดการแพ็กเกจ SaaS ได้)
- **`staff`** (พนักงานนิติ/แอดมิน): จดมิเตอร์, รับแจ้งซ่อม, ดูข้อมูลผู้เช่า
- **`technician`** (ช่างประจำหอ): อัปเดตสถานะงานซ่อม, บันทึกค่าอะไหล่และค่าแรง

---

## 2. โครงสร้างฐานข้อมูลฉบับสมบูรณ์ (Complete Database Schema & DDL)

```sql
-- เปิดส่วนขยายที่จำเป็น
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================================
-- หมวดที่ 1: ระบบ SAAS & การเป็นสมาชิก (SAAS PLATFORM)
-- ========================================================

-- 1.1 ตารางแพ็กเกจราคา SaaS
CREATE TABLE public.subscription_plans (
    id text PRIMARY KEY,                               -- 'free', 'starter', 'pro', 'enterprise'
    name text NOT NULL,                                -- 'Free Tier', 'Starter', 'Pro', 'Enterprise'
    max_rooms integer NOT NULL,                        -- โควต้าจำนวนห้องสูงสุด (10, 35, 80, 99999)
    max_staff integer NOT NULL DEFAULT 1,              -- จำนวนแอดมินสูงสุด
    price_monthly numeric NOT NULL DEFAULT 0,
    price_yearly numeric NOT NULL DEFAULT 0,
    features jsonb NOT NULL DEFAULT '[]'::jsonb,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);

-- ข้อมูลแพ็กเกจเริ่มต้น
INSERT INTO public.subscription_plans (id, name, max_rooms, max_staff, price_monthly, price_yearly, features) VALUES
('free', 'Free Tier', 10, 1, 0, 0, '["room_management", "manual_bill_pdf", "single_admin"]'::jsonb),
('starter', 'Starter', 35, 2, 350, 3360, '["room_management", "auto_line_bill", "overdue_reminder", "2_staff"]'::jsonb),
('pro', 'Pro', 80, 5, 690, 6600, '["multi_branch", "maintenance_system", "financial_analytics", "excel_export", "5_staff"]'::jsonb),
('enterprise', 'Enterprise', 99999, 999, 1490, 14300, '["unlimited_rooms", "unlimited_branches", "custom_branding", "priority_support"]'::jsonb);

-- 1.2 ตารางบัญชีองค์กร / เจ้าของหอพัก (Organization / Tenant)
CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,                                -- เช่น 'บริษัท กรีน เรสซิเดนซ์ จำกัด'
    owner_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    tax_id text,
    phone text NOT NULL,
    email text,
    address text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 1.3 ตารางประวัติการสมัครแพ็กเกจของแต่ละองค์กร
CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    plan_id text NOT NULL REFERENCES public.subscription_plans(id),
    status text NOT NULL DEFAULT 'active' CHECK (status IN ('trialing', 'active', 'past_due', 'canceled')),
    current_period_start timestamp with time zone NOT NULL,
    current_period_end timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 1.4 ตารางสมาชิกทีมงานในองค์กร (RBAC)
CREATE TABLE public.org_members (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('owner', 'manager', 'staff', 'technician')),
    display_name text,
    phone text,
    created_at timestamp with time zone DEFAULT now(),
    UNIQUE (org_id, user_id)
);


-- ========================================================
-- หมวดที่ 2: หอพักและห้องพัก (PROPERTIES & ROOMS)
-- ========================================================

-- 2.1 ตารางข้อมูลหอพักแต่ละสาขา / แต่ละอาคาร
CREATE TABLE public.dorm_properties (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    name text NOT NULL,                                -- เช่น 'The Green Residence (สาขาหลัก)'
    address text NOT NULL,
    phone text,
    electric_rate numeric(8, 2) NOT NULL DEFAULT 8.00, -- ค่าไฟต่อหน่วย
    water_rate numeric(8, 2) NOT NULL DEFAULT 18.00,   -- ค่าน้ำต่อหน่วย
    common_fee numeric(8, 2) NOT NULL DEFAULT 300.00,  -- ค่าส่วนกลาง
    billing_cutoff_day integer NOT NULL DEFAULT 25 CHECK (billing_cutoff_day BETWEEN 1 AND 31),
    payment_due_day integer NOT NULL DEFAULT 5 CHECK (payment_due_day BETWEEN 1 AND 31),
    late_fee_per_day numeric(8, 2) NOT NULL DEFAULT 50.00,
    bank_account_name text,
    bank_account_number text,
    bank_name text,
    promptpay_id text,
    is_main_branch boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 2.2 ตารางข้อมูลห้องพัก
CREATE TABLE public.rooms (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id bigint NOT NULL REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_number text NOT NULL,                         -- เช่น '101', 'A204'
    floor integer NOT NULL,
    room_type text NOT NULL DEFAULT 'ห้องแอร์ • เตียงเดี่ยว',
    base_rent_price numeric(10, 2) NOT NULL,
    deposit_amount numeric(10, 2) NOT NULL DEFAULT 0,
    status text NOT NULL DEFAULT 'vacant' CHECK (status IN ('vacant', 'occupied', 'maintenance')),
    amenities jsonb DEFAULT '["แอร์", "เครื่องทำน้ำอุ่น", "เตียง 5 ฟุต", "ตู้เสื้อผ้า", "WiFi"]'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    UNIQUE (dorm_id, room_number)
);


-- ========================================================
-- หมวดที่ 3: ผู้เช่าและสัญญาเช่า (TENANTS & LEASES)
-- ========================================================

-- 3.1 ตารางข้อมูลผู้เช่า
CREATE TABLE public.tenants (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    full_name text NOT NULL,
    phone text NOT NULL,
    id_card_number text,
    line_user_id text,                                 -- LINE UID สำหรับยิง Flex Message
    line_display_name text,
    emergency_contact_name text,
    emergency_contact_phone text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 3.2 ตารางสัญญาเช่าห้องพัก
CREATE TABLE public.lease_agreements (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES public.rooms(id) ON DELETE RESTRICT,
    tenant_id bigint NOT NULL REFERENCES public.tenants(id) ON DELETE RESTRICT,
    start_date date NOT NULL,
    end_date date NOT NULL,
    monthly_rent numeric(10, 2) NOT NULL,
    deposit_amount numeric(10, 2) NOT NULL DEFAULT 0,
    contract_pdf_url text,
    status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expiring_soon', 'expired', 'terminated')),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


-- ========================================================
-- หมวดที่ 4: การดำเนินงานประจำเดือน (OPERATIONS & BILLING)
-- ========================================================

-- 4.1 ตารางบันทึกการจดเลขมิเตอร์น้ำ-ไฟ
CREATE TABLE public.meter_readings (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id bigint NOT NULL REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    billing_month date NOT NULL,                       -- วันที่ 1 ของเดือน เช่น '2026-08-01'
    prev_electric numeric(10, 2) NOT NULL,
    current_electric numeric(10, 2) NOT NULL,
    prev_water numeric(10, 2) NOT NULL,
    current_water numeric(10, 2) NOT NULL,
    recorded_by uuid REFERENCES auth.users(id),
    recorded_at timestamp with time zone DEFAULT now(),
    UNIQUE (room_id, billing_month)
);

-- 4.2 ตารางใบแจ้งหนี้ประจำเดือน (Invoices)
CREATE TABLE public.invoices (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id bigint NOT NULL REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    lease_id bigint NOT NULL REFERENCES public.lease_agreements(id) ON DELETE RESTRICT,
    meter_reading_id bigint REFERENCES public.meter_readings(id),
    invoice_number text NOT NULL UNIQUE,               -- เช่น 'INV-202608-101'
    billing_month date NOT NULL,
    rent_amount numeric(10, 2) NOT NULL,
    electric_units numeric(10, 2) NOT NULL DEFAULT 0,
    electric_rate numeric(8, 2) NOT NULL,
    electric_amount numeric(10, 2) NOT NULL DEFAULT 0,
    water_units numeric(10, 2) NOT NULL DEFAULT 0,
    water_rate numeric(8, 2) NOT NULL,
    water_amount numeric(10, 2) NOT NULL DEFAULT 0,
    common_fee_amount numeric(10, 2) NOT NULL DEFAULT 0,
    other_fees numeric(10, 2) NOT NULL DEFAULT 0,
    discount_amount numeric(10, 2) NOT NULL DEFAULT 0,
    total_amount numeric(10, 2) NOT NULL,
    due_date date NOT NULL,
    status text NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'pending_verification', 'paid', 'cancelled')),
    line_sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 4.3 ตารางการชำระเงินและสลิปโอนเงิน
CREATE TABLE public.payments (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    invoice_id bigint NOT NULL REFERENCES public.invoices(id) ON DELETE CASCADE,
    amount numeric(10, 2) NOT NULL,
    payment_method text NOT NULL DEFAULT 'PROMPTPAY' CHECK (payment_method IN ('PROMPTPAY', 'BANK_TRANSFER', 'CASH')),
    slip_image_url text,
    paid_at timestamp with time zone DEFAULT now(),
    verified_by uuid REFERENCES auth.users(id),
    verified_at timestamp with time zone,
    receipt_number text UNIQUE,                        -- เช่น 'REC-202608-101'
    receipt_pdf_url text,
    created_at timestamp with time zone DEFAULT now()
);

-- 4.4 ตารางรายการแจ้งซ่อม (Maintenance Tickets)
CREATE TABLE public.maintenance_tickets (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    dorm_id bigint NOT NULL REFERENCES public.dorm_properties(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    reported_by_tenant_id bigint REFERENCES public.tenants(id),
    title text NOT NULL,
    description text,
    image_urls jsonb DEFAULT '[]'::jsonb,
    priority text NOT NULL DEFAULT 'normal' CHECK (priority IN ('urgent', 'normal', 'low')),
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    technician_name text,
    repair_cost numeric(10, 2) DEFAULT 0,
    repair_notes text,
    created_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone
);

-- 4.5 ตารางการตั้งค่า LINE Official Account แยกรายองค์กร
CREATE TABLE public.line_oa_configs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL UNIQUE REFERENCES public.organizations(id) ON DELETE CASCADE,
    channel_id text NOT NULL,
    channel_secret text NOT NULL,
    channel_access_token text NOT NULL,
    auto_send_bill boolean DEFAULT true,
    auto_send_receipt boolean DEFAULT true,
    auto_remind_overdue boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 4.6 ตารางประวัติการส่งข้อความ LINE
CREATE TABLE public.line_messages (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    tenant_id bigint REFERENCES public.tenants(id) ON DELETE SET NULL,
    message_type text NOT NULL CHECK (message_type IN ('BILL', 'RECEIPT', 'REMINDER', 'BROADCAST', 'GENERAL')),
    message_title text,
    message_payload jsonb,
    delivery_status text NOT NULL DEFAULT 'sent' CHECK (delivery_status IN ('sent', 'delivered', 'read', 'failed')),
    sent_at timestamp with time zone DEFAULT now()
);

-- ========================================================
-- การสร้างดัชนีเพื่อเพิ่มประสิทธิภาพ (INDEXES)
-- ========================================================
CREATE INDEX idx_rooms_org_dorm ON public.rooms(org_id, dorm_id);
CREATE INDEX idx_rooms_status ON public.rooms(status);
CREATE INDEX idx_leases_org_room ON public.lease_agreements(org_id, room_id);
CREATE INDEX idx_leases_status ON public.lease_agreements(status);
CREATE INDEX idx_invoices_org_month ON public.invoices(org_id, billing_month);
CREATE INDEX idx_invoices_status ON public.invoices(status);
CREATE INDEX idx_meter_room_month ON public.meter_readings(room_id, billing_month);
CREATE INDEX idx_maintenance_org_status ON public.maintenance_tickets(org_id, status);
CREATE INDEX idx_line_messages_tenant ON public.line_messages(tenant_id);
```

---

## 3. นโยบายความปลอดภัย Row Level Security (RLS Policies)

```sql
-- เปิดใช้งาน RLS บนทุกตารางที่มี org_id
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dorm_properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lease_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meter_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.line_oa_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.line_messages ENABLE ROW LEVEL SECURITY;

-- นโยบายตรวจสอบว่าผู้ใช้งานเป็นสมาชิกขององค์กรนั้นๆ หรือไม่
CREATE OR REPLACE FUNCTION public.current_user_org_ids()
RETURNS TABLE (org_id uuid) AS $$
    SELECT org_id FROM public.org_members WHERE user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER;

-- RLS Policy: ตาราง Rooms
CREATE POLICY "Users can only access rooms within their organizations"
ON public.rooms FOR ALL
USING (org_id IN (SELECT org_id FROM public.current_user_org_ids()));

-- RLS Policy: ตาราง Invoices
CREATE POLICY "Users can only access invoices within their organizations"
ON public.invoices FOR ALL
USING (org_id IN (SELECT org_id FROM public.current_user_org_ids()));

-- RLS Policy: ตาราง Tenants
CREATE POLICY "Users can only access tenants within their organizations"
ON public.tenants FOR ALL
USING (org_id IN (SELECT org_id FROM public.current_user_org_ids()));

-- RLS Policy: ตาราง Maintenance Tickets
CREATE POLICY "Users can only access maintenance tickets within their organizations"
ON public.maintenance_tickets FOR ALL
USING (org_id IN (SELECT org_id FROM public.current_user_org_ids()));
```

---

## 4. มาตรฐาน RESTful API & Error Handling

### 4.1 Headers มาตรฐาน
- `Authorization: Bearer <JWT_TOKEN>`
- `Content-Type: application/json`
- `X-Organization-Id: <UUID>` *(จำเป็นสำหรับผู้ใช้ที่มีหลายองค์กร)*

### 4.2 รูปแบบ JSON Response มาตรฐาน

#### Success Response (200 OK, 201 Created):
```json
{
  "success": true,
  "message": "ดำเนินการสำเร็จ",
  "data": {},
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 50
  }
}
```

#### Error Response (400, 401, 403, 404, 422, 500):
```json
{
  "success": false,
  "error": {
    "code": "ROOM_QUOTA_EXCEEDED",
    "message": "จำนวนห้องพักเกินโควต้าแพ็กเกจปัจจุบัน กรุณาอัปเกรดแพ็กเกจเพื่อเพิ่มห้อง",
    "details": []
  }
}
```

---

## 5. ข้อกำหนด API รายโมดูล (API Endpoints Specification)

### 5.1 ระบบยืนยันตัวตนและองค์กร (Auth & Organization)

#### 1. `POST /api/v1/auth/register` (สมัครบัญชีเจ้าของหอพักใหม่)
- **Request Body:**
```json
{
  "email": "owner@greenresidence.com",
  "password": "SecurePassword123!",
  "fullName": "คุณณภัทร วุฒิเดช",
  "phone": "081-234-5678",
  "organizationName": "เดอะ กรีน เรสซิเดนซ์ จำกัด",
  "initialDormName": "The Green Residence (สาขาหลัก)"
}
```
- **Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "user": {
      "id": "u-8923-4819",
      "email": "owner@greenresidence.com",
      "fullName": "คุณณภัทร วุฒิเดช"
    },
    "organization": {
      "id": "org-9912-3841",
      "name": "เดอะ กรีน เรสซิเดนซ์ จำกัด",
      "plan": "free",
      "maxRooms": 10
    }
  }
}
```

---

### 5.2 ระบบหอพักและห้องพัก (Properties & Rooms)

#### 1. `GET /api/v1/properties` (ดึงรายชื่อหอพักทั้งหมดขององค์กร)
- **Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "The Green Residence",
      "address": "128/4 ซอยสุขุมวิท 101, บางนา, กทม.",
      "totalRooms": 50,
      "occupiedRooms": 45,
      "vacantRooms": 5,
      "monthlyRevenue": 248500,
      "electricRate": 8.00,
      "waterRate": 18.00,
      "isMainBranch": true
    }
  ]
}
```

#### 2. `GET /api/v1/rooms` (ดึงรายการห้องพักพร้อมฟิลเตอร์)
- **Query Params:** `dorm_id=1`, `floor=1`, `status=vacant`, `search=101`
- **Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 101,
      "roomNumber": "101",
      "floor": 1,
      "roomType": "ห้องแอร์ • เตียงเดี่ยว",
      "baseRentPrice": 4500.00,
      "status": "occupied",
      "tenant": {
        "id": 1,
        "name": "คุณสมศักดิ์ สุขใจ",
        "phone": "081-234-5678"
      }
    }
  ]
}
```

#### 3. `POST /api/v1/rooms` (เพิ่มห้องพักใหม่ - ตรวจโควต้าแพ็กเกจ SaaS อัตโนมัติ)
- **Request Body:**
```json
{
  "dormId": 1,
  "roomNumber": "105",
  "floor": 1,
  "roomType": "ห้องแอร์ • เตียงเดี่ยว",
  "baseRentPrice": 4500.00,
  "depositAmount": 9000.00,
  "amenities": ["แอร์", "เครื่องทำน้ำอุ่น", "เตียง 5 ฟุต", "WiFi"]
}
```

---

### 5.3 ระบบผู้เช่าและสัญญาเช่า (Tenants & Leases)

#### 1. `POST /api/v1/leases` (ทำสัญญาเช่าใหม่และผูกห้องพัก)
- **Request Body:**
```json
{
  "dormId": 1,
  "roomId": 103,
  "tenant": {
    "fullName": "คุณณภัทร วุฒิเดช",
    "phone": "089-111-2233",
    "idCardNumber": "1103701234567"
  },
  "startDate": "2026-04-01",
  "endDate": "2027-03-31",
  "monthlyRent": 4500.00,
  "depositAmount": 9000.00
}
```
- **Response (201 Created):**
```json
{
  "success": true,
  "message": "สร้างสัญญาเช่าและย้ายเข้าห้อง 103 เรียบร้อยแล้ว",
  "data": {
    "leaseId": 55,
    "status": "active"
  }
}
```

---

### 5.4 ระบบจดเลขมิเตอร์น้ำ-ไฟ (Meter Reading)

#### 1. `POST /api/v1/meters/batch-record` (บันทึกเลขมิเตอร์รายห้องหรือหลายห้อง)
- **Request Body:**
```json
{
  "dormId": 1,
  "billingMonth": "2026-08-01",
  "readings": [
    {
      "roomId": 101,
      "prevElectric": 1420.0,
      "currentElectric": 1512.0,
      "prevWater": 310.0,
      "currentWater": 324.0
    }
  ]
}
```

---

### 5.5 ระบบออกใบแจ้งหนี้และการชำระเงิน (Invoicing & Payments)

#### 1. `POST /api/v1/invoices/generate` (สร้างใบแจ้งหนี้รายห้อง)
- **Request Body:**
```json
{
  "leaseId": 55,
  "billingMonth": "2026-08-01",
  "dueDate": "2026-09-05",
  "includeCommonFee": true,
  "sendLineNotification": true
}
```
- **Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "invoiceNumber": "INV-202608-101",
    "rentAmount": 4500.00,
    "electricAmount": 736.00,
    "waterAmount": 252.00,
    "commonFeeAmount": 300.00,
    "totalAmount": 5788.00,
    "status": "unpaid",
    "promptpayQrUrl": "https://api.dorm.com/qr/INV-202608-101.png"
  }
}
```

#### 2. `PATCH /api/v1/payments/{paymentId}/approve` (อนุมัติสลิปโอนเงิน & สร้าง e-Receipt)
- **Response (200 OK):**
```json
{
  "success": true,
  "message": "อนุมัติการชำระเงินเรียบร้อยแล้ว",
  "data": {
    "receiptNumber": "REC-202608-101",
    "receiptPdfUrl": "https://storage.dorm.com/receipts/REC-202608-101.pdf",
    "invoiceStatus": "paid"
  }
}
```

---

### 5.6 ระบบแจ้งซ่อมและงานช่าง (Maintenance Tickets)

#### 1. `POST /api/v1/maintenance` (สร้างใบแจ้งซ่อมใหม่)
- **Request Body:**
```json
{
  "dormId": 1,
  "roomId": 104,
  "title": "เครื่องปรับอากาศมีน้ำหยด",
  "description": "แอร์มีน้ำหยดลงบนเตียง เย็นน้อยลง",
  "priority": "urgent",
  "imageUrls": ["https://storage.dorm.com/repair/img-1.jpg"]
}
```

#### 2. `PATCH /api/v1/maintenance/{ticketId}` (มอบหมายช่าง / บันทึกผลการซ่อม)
- **Request Body:**
```json
{
  "status": "completed",
  "technicianName": "ช่างสมเกียรติ",
  "repairCost": 500.00,
  "repairNotes": "ล้างแอร์และทำความสะอาดท่อน้ำทิ้งเรียบร้อย"
}
```

---

### 5.7 ระบบเชื่อมต่อ LINE Official Account (LINE OA & Webhook)

#### 1. `POST /api/v1/line/webhook` (Webhook รับ Event จาก LINE Platform)
- **ประมวลผลอัตโนมัติ:**
  - `follow`: ตรวจสอบและส่งข้อความต้อนรับ + ปุ่มลิงก์ผูกห้องพัก (LIFF)
  - `message:text` / `message:image`: ตรวจสอบสลิปโอนเงิน หรือตอบกลับคำถามอัตโนมัติ

#### 2. `POST /api/v1/line/send-bill` (ส่ง Flex Message ใบแจ้งหนี้หาผู้เช่า)
- **Request Body:**
```json
{
  "invoiceId": 1204,
  "tenantId": 1
}
```

---

### 5.8 ระบบรายงานการเงินและแดชบอร์ด (Financial Analytics)

#### 1. `GET /api/v1/reports/monthly-summary` (สรุปภาพรวมการเงินประจำเดือน)
- **Query Params:** `dorm_id=1`, `month=2026-08`
- **Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "month": "สิงหาคม 2026",
    "totalRevenue": 248500.00,
    "momGrowthPercent": 4.5,
    "netProfit": 213200.00,
    "totalExpenses": 35300.00,
    "collectionRatePercent": 94.2,
    "paidCount": 42,
    "unpaidCount": 3,
    "breakdown": {
      "rent": 195000.00,
      "electric": 32400.00,
      "water": 8100.00,
      "commonFee": 13000.00
    }
  }
}
```

---

## 🏁 สรุปคำแนะนำสำหรับการพัฒนา (Developer Implementation Guide)
1. **Database:** คัดลอก SQL DDL ในข้อ 2 ไปรันบน **PostgreSQL (Supabase, Neon, หรือ AWS RDS)** จะได้ตารางครบ 13 ตารางพร้อม Index และ Constraint ทันที
2. **Backend Framework:** แนะนำให้ใช้ **NestJS (TypeScript)**, **FastAPI (Python)**, หรือ **Go (Gin/Fiber)** เพื่อรองรับ High-performance และ Typed-schema
3. **Storage:** เก็บรูปสลิป, รูปงานซ่อม, และไฟล์สัญญา PDF บน **S3 / Supabase Storage Bucket**
4. **Job Queue:** ใช้ **BullMQ / Redis** สำหรับการส่งข้อความ LINE OA แบบ Batch และระบบแจ้งเตือนวันครบกำหนดชำระอัตโนมัติ (Cron Job ทุก 09:00 น.)
