## User Table Indexes:
UNIQUE(email)
INDEX(status)
INDEX(created_at)
## User Table constraints:
CHECK(email <> '')
CHECK(name <> '')

## income Table Indexes:
INDEX(user_id)
INDEX(organization_id)
INDEX(category_id)
INDEX(income_date)
INDEX(income_source)
## income Table constraints:
CHECK(amount > 0)
CHECK(is_recurring = false OR recurring_frequency IS NOT NULL)

## categories Table constraints:
CHECK(name <> '')
## categories Table Indexes:
INDEX(type)
INDEX(user_id)
INDEX(organization_id)
INDEX(parent_category_id)
INDEX(is_system)

## accounts Table constraints:
CHECK(name <> '')
CHECK(last_four IS NULL OR last_four is 4 digits)
## accounts Table Indexes:
INDEX(user_id)
INDEX(type)
INDEX(is_system)
INDEX(is_active)

## expenses Table Indexes:
INDEX(user_id)
INDEX(account_id)
INDEX(category_id)
INDEX(expense_date)
INDEX(organization_id)
INDEX(status)
## expenses Table constraints:
CHECK(amount > 0)

## attachments Table Indexes:
INDEX(expense_id)
INDEX(uploaded_by)
INDEX(storage_provider)
## attachments Table constraints:
CHECK(file_size > 0)

## subscriptions Table Indexes:
INDEX(user_id)
INDEX(organization_id)
INDEX(status)
INDEX(plan)
INDEX(end_date)
## subscriptions Table constraints:
CHECK(user_id IS NOT NULL OR organization_id IS NOT NULL)

## payments Table Indexes:
INDEX(subscription_id)
INDEX(user_id)
INDEX(provider_payment_id)
INDEX(status)
INDEX(payment_date)
## payments Table constraints:
CHECK(amount > 0)
CHECK(refund_amount >= 0)

## budgets Table Indexes:
INDEX(user_id)
INDEX(organization_id)
INDEX(account_id)
INDEX(category_id)
INDEX(status)
INDEX(start_date, end_date)
## budgets Table constraints:
CHECK(alert_percentage BETWEEN 1 AND 100)
CHECK(amount > 0)
CHECK(spent_amount >= 0)
CHECK(remaining_amount >= 0)
CHECK(start_date <= end_date)
UNIQUE(user_id, category_id, start_date, end_date)

## organizations Table Indexes:
INDEX(owner_id)
INDEX(plan)
INDEX(status)
INDEX(country)
## organizations Table constraints:
UNIQUE(name, owner_id)
CHECK(company_size > 0)

## Audit logs Table Indexes:
INDEX(user_id)
INDEX(organization_id)
INDEX(entity_type)
INDEX(entity_id)
INDEX(created_at)

## notifications Table Indexes:
INDEX(user_id)
INDEX(is_read)
INDEX(type)
INDEX(created_at)

## organization_members Table Indexes:
INDEX(organization_id)
INDEX(user_id)
INDEX(role)
INDEX(status)

## organization_members Table constraints:
UNIQUE(organization_id, user_id)


