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


-- ==========================================
-- CATEGORIES
-- ==========================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type category_type_enum NOT NULL,
    icon VARCHAR(255) NULL,
    color VARCHAR(20) NULL,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    organization_id UUID NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_categories_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT chk_category_name_not_empty
        CHECK (name <> ''),

    CONSTRAINT uq_category_name
        UNIQUE(name, type, organization_id)
);

CREATE INDEX idx_categories_type
ON categories(type);

CREATE INDEX idx_categories_organization_id
ON categories(organization_id);

CREATE INDEX idx_categories_is_system
ON categories(is_system);

CREATE INDEX idx_categories_is_active
ON categories(is_active);


-- ==========================================
-- EXPENSES
-- ==========================================

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    organization_id UUID NULL,
    category_id UUID NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency currency_enum NOT NULL,
    expense_type expense_type_enum NOT NULL,
    payment_method payment_method_enum NOT NULL,
    merchant_name VARCHAR(255) NULL,
    receipt_number VARCHAR(255) NULL,
    description TEXT NULL,
    expense_date DATE NOT NULL,
    is_reimbursable BOOLEAN NOT NULL DEFAULT FALSE,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurring_frequency recurring_frequency_enum NULL,
    status expense_status_enum NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_expenses_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_expenses_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_expenses_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id),

    CONSTRAINT chk_expense_amount
        CHECK (amount > 0),

    CONSTRAINT chk_expense_recurring
        CHECK (
            is_recurring = FALSE
            OR recurring_frequency IS NOT NULL
        )
);


CREATE INDEX idx_expenses_user_id
ON expenses(user_id);

CREATE INDEX idx_expenses_organization_id
ON expenses(organization_id);

CREATE INDEX idx_expenses_category_id
ON expenses(category_id);

CREATE INDEX idx_expenses_expense_date
ON expenses(expense_date);

CREATE INDEX idx_expenses_status
ON expenses(status);

CREATE INDEX idx_expenses_payment_method
ON expenses(payment_method);

-- ==========================================
-- ATTACHMENTS
-- ==========================================

CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id UUID NOT NULL,
    uploaded_by UUID NOT NULL,
    storage_provider storage_provider_enum NOT NULL,
    file_name VARCHAR(500) NOT NULL,
    file_type file_type_enum NOT NULL,
    mime_type VARCHAR(255) NULL,
    file_size BIGINT NOT NULL,
    storage_key TEXT NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_attachments_expense
        FOREIGN KEY (expense_id)
        REFERENCES expenses(id),

    CONSTRAINT fk_attachments_uploaded_by
        FOREIGN KEY (uploaded_by)
        REFERENCES users(id),

    CONSTRAINT chk_attachment_file_size
        CHECK (file_size > 0)
);

CREATE INDEX idx_attachments_expense_id
ON attachments(expense_id);

CREATE INDEX idx_attachments_uploaded_by
ON attachments(uploaded_by);

CREATE INDEX idx_attachments_storage_provider
ON attachments(storage_provider);


-- ==========================================
-- INCOMES
-- ==========================================

CREATE TABLE incomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    organization_id UUID NULL,
    category_id UUID NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency currency_enum NOT NULL,
    income_source income_source_enum NOT NULL,
    source_name VARCHAR(255) NULL,
    reference_number VARCHAR(255) NULL,
    description TEXT NULL,
    income_date DATE NOT NULL,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurring_frequency recurring_frequency_enum NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_incomes_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_incomes_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_incomes_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id),

    CONSTRAINT chk_income_amount
        CHECK (amount > 0),

    CONSTRAINT chk_income_recurring
        CHECK (
            is_recurring = FALSE
            OR recurring_frequency IS NOT NULL
        )
);

CREATE INDEX idx_incomes_user_id
ON incomes(user_id);

CREATE INDEX idx_incomes_organization_id
ON incomes(organization_id);

CREATE INDEX idx_incomes_category_id
ON incomes(category_id);

CREATE INDEX idx_incomes_income_date
ON incomes(income_date);

CREATE INDEX idx_incomes_income_source
ON incomes(income_source);


-- ==========================================
-- SUBSCRIPTIONS
-- ==========================================

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NULL,
    organization_id UUID NULL,
    plan subscription_plan_enum NOT NULL,
    status subscription_status_enum NOT NULL,
    billing_cycle billing_cycle_enum NOT NULL,
    provider subscription_provider_enum NOT NULL,
    provider_subscription_id VARCHAR(255) NULL,
    start_date DATE NOT NULL,
    trial_end_date DATE NULL,
    end_date DATE NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL,

    CONSTRAINT fk_subscriptions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_subscriptions_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT chk_subscription_owner
        CHECK (
            user_id IS NOT NULL
            OR organization_id IS NOT NULL
        ),

    CONSTRAINT chk_subscription_dates
        CHECK (
            start_date <= end_date
        )
);

CREATE INDEX idx_subscriptions_user_id
ON subscriptions(user_id);

CREATE INDEX idx_subscriptions_organization_id
ON subscriptions(organization_id);

CREATE INDEX idx_subscriptions_status
ON subscriptions(status);

CREATE INDEX idx_subscriptions_plan
ON subscriptions(plan);

CREATE INDEX idx_subscriptions_end_date
ON subscriptions(end_date);


-- ==========================================
-- PAYMENTS
-- ==========================================

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL,
    user_id UUID NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency currency_enum NOT NULL,
    status payment_status_enum NOT NULL,
    provider payment_provider_enum NOT NULL,
    payment_method payment_method_enum NOT NULL,
    provider_payment_id VARCHAR(255) NOT NULL,
    provider_order_id VARCHAR(255) NULL,
    provider_invoice_id VARCHAR(255) NULL,
    transaction_reference VARCHAR(255) NULL,
    invoice_url TEXT NULL,
    payment_date TIMESTAMP NOT NULL,
    refund_amount DECIMAL(15,2) NULL,
    refund_date TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(id),

    CONSTRAINT fk_payments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_refund_amount
        CHECK (
            refund_amount IS NULL
            OR refund_amount >= 0
        )
);


CREATE INDEX idx_payments_subscription_id
ON payments(subscription_id);

CREATE INDEX idx_payments_user_id
ON payments(user_id);

CREATE INDEX idx_payments_status
ON payments(status);

CREATE INDEX idx_payments_payment_date
ON payments(payment_date);

CREATE INDEX idx_payments_provider_payment_id
ON payments(provider_payment_id);


-- ==========================================
-- BUDGETS
-- ==========================================

CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    organization_id UUID NULL,
    category_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    spent_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    remaining_amount DECIMAL(15,2) NOT NULL,
    period budget_period_enum NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    alert_percentage INTEGER NOT NULL,
    status budget_status_enum NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_budgets_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_budgets_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_budgets_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id),

    CONSTRAINT chk_budget_amount
        CHECK (amount > 0),

    CONSTRAINT chk_budget_spent
        CHECK (spent_amount >= 0),

    CONSTRAINT chk_budget_remaining
        CHECK (remaining_amount >= 0),

    CONSTRAINT chk_budget_alert_percentage
        CHECK (alert_percentage BETWEEN 1 AND 100),

    CONSTRAINT chk_budget_dates
        CHECK (start_date <= end_date),

    CONSTRAINT uq_budget_period
        UNIQUE (
            user_id,
            category_id,
            start_date,
            end_date
        )
);


CREATE INDEX idx_budgets_user_id
ON budgets(user_id);

CREATE INDEX idx_budgets_organization_id
ON budgets(organization_id);

CREATE INDEX idx_budgets_category_id
ON budgets(category_id);

CREATE INDEX idx_budgets_status
ON budgets(status);

CREATE INDEX idx_budgets_period
ON budgets(period);


-- ==========================================
-- AUDIT LOGS
-- ==========================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    action audit_action_enum NOT NULL,
    entity_type audit_entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    old_value JSONB NULL,
    new_value JSONB NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
);


CREATE INDEX idx_audit_logs_user_id
ON audit_logs(user_id);

CREATE INDEX idx_audit_logs_entity_type
ON audit_logs(entity_type);

CREATE INDEX idx_audit_logs_entity_id
ON audit_logs(entity_id);

CREATE INDEX idx_audit_logs_created_at
ON audit_logs(created_at);


