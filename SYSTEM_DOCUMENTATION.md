# สรุปภาพรวมระบบและการเชื่อมต่อ Database Supabase & Go Gin API

เอกสารสรุปการพัฒนา การแก้ปัญหา และการเชื่อมต่อฐานข้อมูลจริงของระบบบริหารจัดการหอพัก (**Dormitory Management SaaS Application**) ครอบคลุมทั้ง **Flutter Frontend (iOS Clean Design)**, **Go Gin Backend API**, และ **Supabase Database (PostgreSQL)**

---

## 1. ข้อมูลการเชื่อมต่อระบบ & ฐานข้อมูลจริง (Database Setup)

- **Supabase URL**: `https://jexqgxqawcgdrnvrgovl.supabase.co`
- **Default Organization ID**: `6008008f-e0f5-4970-a4ce-da2f8abaa607`
- **Default Dormitory ID**: `1` (The Green Residence)
- **Go Gin API Base URL**: `http://localhost:8080/api/v1`

---

## 2. โครงสร้าง Database Schema จริง (Supabase Database Mapping)

ระบบได้รับการปรับจูนโครงสร้างข้อมูลให้ตรงกับ Schema จริงใน Supabase ทุกประการ:

### 2.1 ตาราง `dorm_properties` (ข้อมูลหอพัก & อัตราค่าน้ำ-ไฟ)
| คอลัมน์ | ประเภทข้อมูล | รายละเอียด |
|---|---|---|
| `id` | bigint | รหัสหอพัก (Primary Key) |
| `org_id` | uuid | ผูกกับองค์กร `organizations(id)` |
| `name` | varchar | ชื่อหอพัก (เช่น The Green Residence) |
| `water_rate` | numeric | อัตราค่าน้ำต่อหน่วย (ค่าเริ่มต้น 18.00 ฿) |
| `electric_rate` | numeric | อัตราค่าไฟต่อหน่วย (ค่าเริ่มต้น 8.00 ฿) |
| `total_floors` | integer | จำนวนชั้นทั้งหมด (ค่าเริ่มต้น 5) |

### 2.2 ตาราง `rooms` (ห้องพัก)
| คอลัมน์ | ประเภทข้อมูล | รายละเอียด |
|---|---|---|
| `id` | bigint | รหัสห้อง (Primary Key) |
| `org_id` | uuid | ผูกกับองค์กร `organizations(id)` |
| `dorm_id` | bigint | ผูกกับหอพัก `dorm_properties(id)` |
| `room_number` | varchar | เลขห้องพัก (เช่น 101, 102, kuy) |
| `floor` | integer | ชั้นของห้อง |
| `room_type` | varchar | ประเภทห้องพัก |
| `base_rent_price`| numeric | ค่าเช่าห้องรายเดือน |
| `deposit_amount` | numeric | เงินประกันสัญญา |
| `status` | varchar | สถานะ (`vacant`, `occupied`, `maintenance`) |

### 2.3 ตาราง `tenants` (ข้อมูลผู้เช่า)
| คอลัมน์ | ประเภทข้อมูล | รายละเอียด |
|---|---|---|
| `id` | bigint | รหัสผู้เช่า (Primary Key) |
| `org_id` | uuid | ผูกกับองค์กร `organizations(id)` |
| `full_name` | varchar | ชื่อ-นามสกุล ผู้เช่า |
| `phone` | varchar | เบอร์โทรศัพท์ (ล็อก 10 หลัก) |
| `id_card_number` | varchar | เลขบัตรประชาชน (ล็อก 13 หลัก) |
| `line_user_id` | varchar | LINE ID สำหรับส่งการแจ้งเตือน |

### 2.4 ตาราง `lease_agreements` (สัญญาเช่า)
| คอลัมน์ | ประเภทข้อมูล | รายละเอียด |
|---|---|---|
| `id` | bigint | รหัสสัญญา (Primary Key) |
| `room_id` | bigint | ผูกกับ `rooms(id)` |
| `tenant_id` | bigint | ผูกกับ `tenants(id)` |
| `start_date` | date | วันที่เริ่มสัญญา |
| `end_date` | date | วันที่สิ้นสุดสัญญา |
| `monthly_rent` | numeric | ค่าเช่าที่ตกลงในสัญญา |
| `deposit_amount`| numeric | เงินประกันที่เรียกเก็บ |
| `status` | varchar | สถานะสัญญา (`active`, `terminated`, `expired`) |

### 2.5 ตาราง `meter_readings` (การจดมิเตอร์น้ำ-ไฟ)
| คอลัมน์ | ประเภทข้อมูล | รายละเอียด |
|---|---|---|
| `id` | bigint | รหัสการจดมิเตอร์ (Primary Key) |
| `org_id` | uuid | ผูกกับองค์กร `organizations(id)` |
| `dorm_id` | bigint | ผูกกับหอพัก `dorm_properties(id)` |
| `room_id` | bigint | ผูกกับห้องพัก `rooms(id)` |
| `billing_month` | varchar | รอบบิล (เช่น `2026-08`) |
| `electric_prev` | numeric | เลขมิเตอร์ไฟเดิม |
| `electric_curr` | numeric | เลขมิเตอร์ไฟใหม่ที่จด |
| `water_prev` | numeric | เลขมิเตอร์น้ำเดิม |
| `water_curr` | numeric | เลขมิเตอร์น้ำใหม่ที่จด |
| `recorded_at` | timestamptz | วันที่และเวลาที่บันทึกข้อมูล |

---

## 3. สรุปปัญหาที่พบและวิธีการแก้ไข (Bug Fixes & Solutions)

### 3.1 ปัญหาแถบลายทางสีดำ-เหลือง (`RenderFlex Overflow`)
- **สาเหตุ**: ข้อความใน `Row` หรือ `Button` มีขนาดยาวเกินความกว้างของหน้าจอมือถือ/เบราว์เซอร์
- **จุดที่แก้ไข**:
  1. ปุ่มในหน้าล็อกอิน (`login_form.dart`): ย่อข้อความจาก *"เข้าสู่ระบบผ่าน Go API (ยืนยันสิทธิ์จริง)"* เป็นคำว่า **"เข้าสู่ระบบ"** สั้น กระชับ สวยงาม
  2. แถบ Header ด้านบน (`home_header.dart`): ครอบด้วย `Expanded` และใส่ `TextOverflow.ellipsis` ให้ชื่อหอพัก
  3. การ์ดสถิติ (`home_bento_stats.dart`): ใส่ `Flexible` ป้องกันป้ายสถานะล้นขอบจอ

### 3.2 ปัญหา `Assertion failed: dropdown.dart:1028:10`
- **สาเหตุ**: Flutter Dropdown มีค่าตัวเลือกที่ซ้ำกัน (เช่น มีห้อง 101 มากกว่า 1 รายการ)
- **จุดที่แก้ไข**:
  - ทำระบบ **Deduplication** ด้วย Map กรองเลขห้องที่ซ้ำกันออก 100%
  - กำหนด Fallback ปลอดภัย (`safeSelectedRoom`) ป้องกันหน้าจอแดง

### 3.3 ปัญหาชื่อห้องกลายเป็น `101` ซ้ำกันทั้งหมด & ขึ้นเตือน `⚠️ ไม่มีห้องว่างใน DB`
- **สาเหตุ**:
  - ตาราง Supabase ส่งข้อมูลมาเป็น `snake_case` (`room_number`, `base_rent_price`, `full_name`)
  - แต่ Go Model ใช้ Tag `json:"roomNumber"` ทำให้ Unmarshal ไม่ติด ข้อมูลเลขห้องและชื่อจึงกลายเป็นค่าว่าง `null`
  - Flutter จึง Fallback ไปใช้ค่าเริ่มต้นเป็น `"101"` ทั้งหมด และเมื่อเลขห้องว่าง ฟอร์มจึงมองว่าไม่มีห้อง
- **จุดที่แก้ไข**:
  - ปรับ Go Backend (`room_handler.go`, `tenant_handler.go`) ให้รองรับและส่งข้อมูลครอบคลุมทั้ง `snake_case` และ `camelCase`
  - ปรับ Flutter ให้อ่านทั้งสองแบบ ดึงเลขห้องจริง (`101`, `kuy`) และชื่อผู้เช่าขึ้นแสดงได้อย่างถูกต้อง

---

## 4. คุณสมบัติของหน้าจอที่พัฒนาเสร็จสมบูรณ์

### 4.1 หน้าจัดการห้องพัก (`RoomManagementScreen`)
- ดึงห้องจริงจาก Supabase แบบ Real-time
- สลับมุมมองตารางได้ทั้งแบบ 3 คอลัมน์ และ 2 คอลัมน์
- กรองสถานะห้องว่าง / มีผู้เช่า / แจ้งซ่อม ได้อย่างรวดเร็ว

### 4.2 หน้าจัดการผู้เช่า & ทำสัญญา (`AddTenantModal` & `TenantDetailModal`)
- **ล็อกเบอร์โทรศัพท์ 10 หลัก**: กรอกได้เฉพาะตัวเลข และต้องขึ้นต้นด้วยเลข `0`
- **ล็อกบัตรประชาชน 13 หลัก**: ตรวจสอบความถูกต้องครบ 13 หลัก
- **เลือกห้องว่างจาก Database สดๆ**: โหลดเฉพาะห้องที่ `status = vacant`
- **นำกล่อง AI ออกตามคำขอ**: ลบแบนเนอร์สีม่วงที่ไม่จำเป็นออกทั้งหมด หน้าจอสะอาดตา

### 4.3 หน้าจดมิเตอร์น้ำ - มิเตอร์ไฟ (`MeterReadingScreen` & `MeterEntryCard`)
- โหลดห้องพักและชื่อผู้เช่าจริงจาก Database สดๆ (ไม่มี Mock Data)
- ดึงอัตราค่าน้ำ ค่าไฟ จริงจากหอพัก (เช่น ไฟ 8฿, น้ำ 18฿)
- **คำนวณอัตโนมัติ Real-time**: เมื่อพิมพ์เลขมิเตอร์ใหม่ ระบบจะคำนวณหน่วยที่ใช้และยอดเงินทันที: `(ใช้ X หน่วย = ฿Y)` พร้อมแสดงผลรวมค่าน้ำ + ค่าไฟเดือนนี้
- **ระบบบันทึกลง Database**:
  - **บันทึกแยกห้อง**: กดปุ่ม *"บันทึกมิเตอร์ห้องนี้"*
  - **บันทึกทั้งหมด (Batch Save)**: กดปุ่มมุมบนขวา บันทึกทุกห้องลงตาราง `meter_readings` ใน Supabase ทันที

---

## 5. วิธีการรันและการทดสอบระบบ (How to Run)

### ฝั่ง Backend (Go Gin API):
```powershell
cd "c:\Users\Por Woodden\Desktop\All-Project\dorm_management_app\backend-go"
go run main.go
```
*สังเกต Log ใน Terminal เมื่อเปิดหน้าต่างๆ จะมีคำสั่ง GET/POST วิ่งไปยัง Supabase ตลอดเวลา*

### ฝั่ง Frontend (Flutter):
- รีเฟรชหน้าเว็บเบราว์เซอร์ด้วยปุ่ม **F5** หรือ **Reload**
- หรือรันแอปใหม่ด้วยคำสั่ง:
```powershell
flutter run -d chrome
```
