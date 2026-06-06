CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- USERS
-- ==========================================

CREATE TYPE auth_provider_enum AS ENUM (
    'EMAIL',
    'GOOGLE',
    'APPLE',
    'MICROSOFT'
);

CREATE TYPE user_status_enum AS ENUM (
    'ACTIVE',
    'PENDING_VERIFICATION',
    'SUSPENDED',
    'DELETED'
);

-- ==========================================
-- ORGANIZATIONS
-- ==========================================

CREATE TYPE organization_plan_enum AS ENUM (
    'FREE',
    'PREMIUM',
    'BUSINESS',
    'ENTERPRISE'
);

CREATE TYPE organization_status_enum AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED'
);

-- ==========================================
-- CURRENCY
-- ==========================================

CREATE TYPE currency_enum AS ENUM (
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AUD',
    'SGD'
);

-- ==========================================
-- CATEGORIES
-- ==========================================

CREATE TYPE category_type_enum AS ENUM (
    'EXPENSE',
    'INCOME'
);

-- ==========================================
-- EXPENSES
-- ==========================================

CREATE TYPE expense_type_enum AS ENUM (
    'PERSONAL',
    'BUSINESS'
);

CREATE TYPE payment_method_enum AS ENUM (
    'CASH',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'UPI',
    'BANK_TRANSFER',
    'WALLET',
    'OTHER'
);

CREATE TYPE expense_status_enum AS ENUM (
    'DRAFT',
    'SUBMITTED',
    'APPROVED',
    'REJECTED',
    'PAID'
);

-- ==========================================
-- ATTACHMENTS
-- ==========================================

CREATE TYPE storage_provider_enum AS ENUM (
    'LOCAL',
    'S3',
    'GOOGLE_DRIVE'
);

CREATE TYPE file_type_enum AS ENUM (
    'PDF',
    'JPG',
    'JPEG',
    'PNG',
    'WEBP',
    'DOC',
    'DOCX',
    'XLS',
    'XLSX',
    'OTHER'
);

-- ==========================================
-- INCOMES
-- ==========================================

CREATE TYPE income_source_enum AS ENUM (
    'SALARY',
    'BUSINESS',
    'FREELANCING',
    'INVESTMENT',
    'RENTAL',
    'INTEREST',
    'REFUND',
    'BONUS',
    'OTHER'
);

CREATE TYPE recurring_frequency_enum AS ENUM (
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'YEARLY'
);

-- ==========================================
-- ORGANIZATION MEMBERS
-- ==========================================

CREATE TYPE organization_role_enum AS ENUM (
    'OWNER',
    'ADMIN',
    'MANAGER',
    'EMPLOYEE'
);

CREATE TYPE organization_member_status_enum AS ENUM (
    'INVITED',
    'ACTIVE',
    'SUSPENDED',
    'REMOVED'
);

-- ==========================================
-- SUBSCRIPTIONS
-- ==========================================

CREATE TYPE subscription_plan_enum AS ENUM (
    'FREE',
    'PREMIUM',
    'BUSINESS',
    'ENTERPRISE'
);

CREATE TYPE subscription_status_enum AS ENUM (
    'TRIAL',
    'ACTIVE',
    'PAST_DUE',
    'EXPIRED',
    'CANCELLED'
);

CREATE TYPE billing_cycle_enum AS ENUM (
    'MONTHLY',
    'QUARTERLY',
    'YEARLY'
);

CREATE TYPE subscription_provider_enum AS ENUM (
    'RAZORPAY',
    'STRIPE',
    'MANUAL'
);

-- ==========================================
-- PAYMENTS
-- ==========================================

CREATE TYPE payment_status_enum AS ENUM (
    'PENDING',
    'SUCCESS',
    'FAILED',
    'REFUNDED',
    'PARTIALLY_REFUNDED'
);

CREATE TYPE payment_provider_enum AS ENUM (
    'RAZORPAY',
    'STRIPE'
);

-- ==========================================
-- BUDGETS
-- ==========================================

CREATE TYPE budget_period_enum AS ENUM (
    'MONTHLY',
    'QUARTERLY',
    'YEARLY'
);

CREATE TYPE budget_status_enum AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'EXPIRED',
    'CANCELLED'
);

-- ==========================================
-- AUDIT LOGS
-- ==========================================

CREATE TYPE audit_action_enum AS ENUM (
    'CREATE',
    'UPDATE',
    'DELETE',
    'APPROVE',
    'REJECT',
    'LOGIN',
    'LOGOUT',
    'INVITE',
    'PAYMENT',
    'SUBSCRIPTION_CHANGE'
);

CREATE TYPE audit_entity_type_enum AS ENUM (
    'USER',
    'ORGANIZATION',
    'EXPENSE',
    'INCOME',
    'CATEGORY',
    'BUDGET',
    'SUBSCRIPTION',
    'PAYMENT',
    'SYSTEM'
);

-- ==========================================
-- NOTIFICATIONS
-- ==========================================

CREATE TYPE notification_type_enum AS ENUM (
    'BUDGET_THRESHOLD_REACHED',
    'BUDGET_EXCEEDED',
    'EXPENSE_APPROVED',
    'EXPENSE_REJECTED',
    'SUBSCRIPTION_EXPIRING',
    'SUBSCRIPTION_EXPIRED',
    'PAYMENT_SUCCESS',
    'PAYMENT_FAILED',
    'MEMBER_INVITED',
    'SYSTEM'
);

CREATE TYPE notification_priority_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


-- ==========================================
-- USERS
-- ==========================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    password_hash TEXT NULL,
    profile_picture_url TEXT NULL,
    auth_provider auth_provider_enum NOT NULL,
    status user_status_enum NOT NULL DEFAULT 'ACTIVE',
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    CONSTRAINT chk_users_email_not_empty
        CHECK (email <> ''),
    CONSTRAINT chk_users_name_not_empty
        CHECK (name <> '')
);

CREATE INDEX idx_users_status
ON users(status);

CREATE INDEX idx_users_created_at
ON users(created_at);


-- ==========================================
-- ORGANIZATIONS
-- ==========================================

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    owner_id UUID NOT NULL,
    plan organization_plan_enum NOT NULL DEFAULT 'FREE',
    status organization_status_enum NOT NULL DEFAULT 'ACTIVE',
    currency currency_enum NOT NULL DEFAULT 'INR',
    timezone VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata',
    logo_url TEXT NULL,
    gst_number VARCHAR(50) NULL,
    company_size INTEGER NULL,
    country VARCHAR(100) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_organizations_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id),

    CONSTRAINT chk_organizations_name_not_empty
        CHECK (name <> ''),

    CONSTRAINT chk_company_size
        CHECK (
            company_size IS NULL
            OR company_size > 0
        ),

    CONSTRAINT uq_organization_name_owner
        UNIQUE(name, owner_id)
);

CREATE INDEX idx_organizations_owner_id
ON organizations(owner_id);

CREATE INDEX idx_organizations_plan
ON organizations(plan);

CREATE INDEX idx_organizations_status
ON organizations(status);

CREATE INDEX idx_organizations_country
ON organizations(country);


-- ==========================================
-- ORGANIZATION MEMBERS
-- ==========================================

CREATE TABLE organization_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL,
    user_id UUID NOT NULL,
    invited_by UUID NULL,
    role organization_role_enum NOT NULL,
    status organization_member_status_enum NOT NULL DEFAULT 'INVITED',
    invited_at TIMESTAMP NULL,
    joined_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_org_members_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_org_members_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_org_members_invited_by
        FOREIGN KEY (invited_by)
        REFERENCES users(id),

    CONSTRAINT uq_org_member
        UNIQUE (organization_id, user_id)
);


CREATE INDEX idx_org_members_organization_id
ON organization_members(organization_id);

CREATE INDEX idx_org_members_user_id
ON organization_members(user_id);

CREATE INDEX idx_org_members_role
ON organization_members(role);

CREATE INDEX idx_org_members_status
ON organization_members(status);