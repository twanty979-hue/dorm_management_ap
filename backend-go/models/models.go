package models

import (
	"time"

	"github.com/google/uuid"
)

// 1. Subscription Plan
type SubscriptionPlan struct {
	ID           string    `gorm:"primaryKey" json:"id"`
	Name         string    `gorm:"not null" json:"name"`
	MaxRooms     int       `gorm:"not null" json:"maxRooms"`
	MaxStaff     int       `gorm:"default:1" json:"maxStaff"`
	PriceMonthly float64   `gorm:"not null;default:0" json:"priceMonthly"`
	PriceYearly  float64   `gorm:"not null;default:0" json:"priceYearly"`
	Features     string    `gorm:"type:jsonb;default:'[]'" json:"features"`
	IsActive     bool      `gorm:"default:true" json:"isActive"`
	CreatedAt    time.Time `json:"createdAt"`
}

// 2. Organization (SaaS Tenant)
type Organization struct {
	ID          uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	Name        string    `gorm:"not null" json:"name"`
	OwnerUserID uuid.UUID `gorm:"type:uuid;not null" json:"ownerUserId"`
	TaxID       string    `json:"taxId"`
	Phone       string    `gorm:"not null" json:"phone"`
	Email       string    `json:"email"`
	Address     string    `json:"address"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

// 3. Organization Member (RBAC)
type OrgMember struct {
	ID          uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	OrgID       uuid.UUID `gorm:"type:uuid;not null" json:"orgId"`
	UserID      uuid.UUID `gorm:"type:uuid;not null" json:"userId"`
	Role        string    `gorm:"not null" json:"role"` // owner, manager, staff, technician
	DisplayName string    `json:"displayName"`
	Phone       string    `json:"phone"`
	CreatedAt   time.Time `json:"createdAt"`
}

// 4. Dormitory Property / Branch
type DormProperty struct {
	ID                int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID             uuid.UUID `gorm:"type:uuid;not null" json:"orgId"`
	Name              string    `gorm:"not null" json:"name"`
	Address           string    `gorm:"not null" json:"address"`
	Phone             string    `json:"phone"`
	ElectricRate      float64   `gorm:"not null;default:8.0" json:"electricRate"`
	WaterRate         float64   `gorm:"not null;default:18.0" json:"waterRate"`
	CommonFee         float64   `gorm:"not null;default:300.0" json:"commonFee"`
	BillingCutoffDay  int       `gorm:"not null;default:25" json:"billingCutoffDay"`
	PaymentDueDay     int       `gorm:"not null;default:5" json:"paymentDueDay"`
	LateFeePerDay     float64   `gorm:"not null;default:50.0" json:"lateFeePerDay"`
	BankAccountName   string    `json:"bankAccountName"`
	BankAccountNumber string    `json:"bankAccountNumber"`
	BankName          string    `json:"bankName"`
	PromptPayID       string    `json:"promptpayId"`
	IsMainBranch      bool      `gorm:"default:false" json:"isMainBranch"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`
}

// 5. Room
type Room struct {
	ID            int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID         uuid.UUID `gorm:"type:uuid;not null" json:"orgId"`
	DormID        int64     `gorm:"not null" json:"dormId"`
	RoomNumber    string    `gorm:"not null" json:"roomNumber"`
	Floor         int       `gorm:"not null" json:"floor"`
	RoomType      string    `gorm:"not null;default:'ห้องแอร์ • เตียงเดี่ยว'" json:"roomType"`
	BaseRentPrice float64   `gorm:"not null" json:"baseRentPrice"`
	DepositAmount float64   `gorm:"not null;default:0" json:"depositAmount"`
	WaterRate     float64   `gorm:"column:water_rate" json:"waterRate"`
	ElectricRate  float64   `gorm:"column:electric_rate" json:"electricRate"`
	Status        string    `gorm:"not null;default:'vacant'" json:"status"` // vacant, occupied, maintenance
	Amenities     string    `gorm:"type:jsonb;default:'[]'" json:"amenities"`
	CreatedAt     time.Time `json:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt"`
}

// 6. Tenant
type Tenant struct {
	ID                    int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID                 uuid.UUID `gorm:"type:uuid;not null" json:"orgId"`
	FullName              string    `gorm:"not null" json:"fullName"`
	Phone                 string    `gorm:"not null" json:"phone"`
	IDCardNumber          string    `json:"idCardNumber"`
	LineUserID            string    `json:"lineUserId"`
	LineDisplayName       string    `json:"lineDisplayName"`
	EmergencyContactName  string    `json:"emergencyContactName"`
	EmergencyContactPhone string    `json:"emergencyContactPhone"`
	CreatedAt             time.Time `json:"createdAt"`
	UpdatedAt             time.Time `json:"updatedAt"`
}

// 7. Lease Agreement
type LeaseAgreement struct {
	ID             int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID          uuid.UUID `gorm:"type:uuid;not null" json:"orgId"`
	DormID         int64     `gorm:"not null" json:"dormId"`
	RoomID         int64     `gorm:"not null" json:"roomId"`
	TenantID       int64     `gorm:"not null" json:"tenantId"`
	StartDate      time.Time `gorm:"not null" json:"startDate"`
	EndDate        time.Time `gorm:"not null" json:"endDate"`
	MonthlyRent    float64   `gorm:"not null" json:"monthlyRent"`
	DepositAmount  float64   `gorm:"default:0" json:"depositAmount"`
	WaterRate      float64   `gorm:"column:water_rate" json:"waterRate"`
	ElectricRate   float64   `gorm:"column:electric_rate" json:"electricRate"`
	ContractPDFURL string    `json:"contractPdfUrl"`
	Status         string    `gorm:"not null;default:'active'" json:"status"` // active, expiring_soon, expired, terminated
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`

	// Relational joins
	Room   *Room   `gorm:"foreignKey:RoomID" json:"room,omitempty"`
	Tenant *Tenant `gorm:"foreignKey:TenantID" json:"tenant,omitempty"`
}

// 8. Meter Reading
type MeterReading struct {
	ID              int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID           uuid.UUID  `gorm:"type:uuid;not null" json:"orgId"`
	DormID          int64      `gorm:"not null" json:"dormId"`
	RoomID          int64      `gorm:"not null" json:"roomId"`
	BillingMonth    time.Time  `gorm:"not null" json:"billingMonth"`
	PrevElectric    float64    `gorm:"not null" json:"prevElectric"`
	CurrentElectric float64    `gorm:"not null" json:"currentElectric"`
	PrevWater       float64    `gorm:"not null" json:"prevWater"`
	CurrentWater    float64    `gorm:"not null" json:"currentWater"`
	RecordedBy      *uuid.UUID `gorm:"type:uuid" json:"recordedBy,omitempty"`
	RecordedAt      time.Time  `json:"recordedAt"`
}

// 9. Invoice
type Invoice struct {
	ID               int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID            uuid.UUID  `gorm:"type:uuid;not null" json:"orgId"`
	DormID           int64      `gorm:"not null" json:"dormId"`
	LeaseID          int64      `gorm:"not null" json:"leaseId"`
	MeterReadingID   *int64     `json:"meterReadingId,omitempty"`
	InvoiceNumber    string     `gorm:"not null;unique" json:"invoiceNumber"`
	BillingMonth     time.Time  `gorm:"not null" json:"billingMonth"`
	RentAmount       float64    `gorm:"not null" json:"rentAmount"`
	ElectricUnits    float64    `gorm:"default:0" json:"electricUnits"`
	ElectricRate     float64    `gorm:"not null" json:"electricRate"`
	ElectricAmount   float64    `gorm:"default:0" json:"electricAmount"`
	WaterUnits       float64    `gorm:"default:0" json:"waterUnits"`
	WaterRate        float64    `gorm:"not null" json:"waterRate"`
	WaterAmount      float64    `gorm:"default:0" json:"waterAmount"`
	CommonFeeAmount  float64    `gorm:"default:0" json:"commonFeeAmount"`
	OtherFees        float64    `gorm:"default:0" json:"otherFees"`
	DiscountAmount   float64    `gorm:"default:0" json:"discountAmount"`
	TotalAmount      float64    `gorm:"not null" json:"totalAmount"`
	DueDate          time.Time  `gorm:"not null" json:"dueDate"`
	Status           string     `gorm:"not null;default:'unpaid'" json:"status"` // unpaid, pending_verification, paid, cancelled
	LineSentAt       *time.Time `json:"lineSentAt,omitempty"`
	CreatedAt        time.Time  `json:"createdAt"`
	UpdatedAt        time.Time  `json:"updatedAt"`

	Lease *LeaseAgreement `gorm:"foreignKey:LeaseID" json:"lease,omitempty"`
}

// 10. Payment
type Payment struct {
	ID            int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID         uuid.UUID  `gorm:"type:uuid;not null" json:"orgId"`
	InvoiceID     int64      `gorm:"not null" json:"invoiceId"`
	Amount        float64    `gorm:"not null" json:"amount"`
	PaymentMethod string     `gorm:"not null;default:'PROMPTPAY'" json:"paymentMethod"` // PROMPTPAY, BANK_TRANSFER, CASH
	SlipImageURL  string     `json:"slipImageUrl"`
	PaidAt        time.Time  `json:"paidAt"`
	VerifiedBy    *uuid.UUID `gorm:"type:uuid" json:"verifiedBy,omitempty"`
	VerifiedAt    *time.Time `json:"verifiedAt,omitempty"`
	ReceiptNumber string     `json:"receiptNumber"`
	ReceiptPDFURL string     `json:"receiptPdfUrl"`
	CreatedAt     time.Time  `json:"createdAt"`
}

// 11. Maintenance Ticket
type MaintenanceTicket struct {
	ID                 int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID              uuid.UUID  `gorm:"type:uuid;not null" json:"orgId"`
	DormID             int64      `gorm:"not null" json:"dormId"`
	RoomID             int64      `gorm:"not null" json:"roomId"`
	ReportedByTenantID *int64     `json:"reportedByTenantId,omitempty"`
	Title              string     `gorm:"not null" json:"title"`
	Description        string     `json:"description"`
	ImageURLs          string     `gorm:"type:jsonb;default:'[]'" json:"imageUrls"`
	Priority           string     `gorm:"not null;default:'normal'" json:"priority"` // urgent, normal, low
	Status             string     `gorm:"not null;default:'pending'" json:"status"`   // pending, in_progress, completed, cancelled
	TechnicianName     string     `json:"technicianName"`
	RepairCost         float64    `gorm:"default:0" json:"repairCost"`
	RepairNotes        string     `json:"repairNotes"`
	CreatedAt          time.Time  `json:"createdAt"`
	CompletedAt        *time.Time `json:"completedAt,omitempty"`
}

// 12. LINE OA Config
type LineOAConfig struct {
	ID                 int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	OrgID              uuid.UUID `gorm:"type:uuid;not null;unique" json:"orgId"`
	ChannelID          string    `gorm:"not null" json:"channelId"`
	ChannelSecret      string    `gorm:"not null" json:"channelSecret"`
	ChannelAccessToken string    `gorm:"not null" json:"channelAccessToken"`
	AutoSendBill       bool      `gorm:"default:true" json:"autoSendBill"`
	AutoSendReceipt    bool      `gorm:"default:true" json:"autoSendReceipt"`
	AutoRemindOverdue  bool      `gorm:"default:true" json:"autoRemindOverdue"`
	CreatedAt          time.Time `json:"createdAt"`
	UpdatedAt          time.Time `json:"updatedAt"`
}
