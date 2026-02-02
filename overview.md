### Overview

You've been tasked with modernizing a **legacy** shipping **application** that manages cargo arrivals and demurrage billing. The existing system uses an old MySQL database with French column names and lacks proper foreign key constraints.

The business has asked you to create a small Rails service that:

1. Generates demurrage invoices for overdue import cargo (**overdue BLs**).
2. Lists invoices that are themselves overdue (**overdue invoices**).
3. Handles multi-tenant access securely (**customer-scoped APIs**).

This challenge focuses on:

- Reverse-engineering a partial legacy schema into idiomatic Rails models.
- Implementing a small business process in a service layer.
- Exposing secure, well-structured JSON APIs.
- Writing realistic tests.
- Communicating your approach.

### Setup Notes

- **Framework:** Rails 7.x
- **Database:** SQL (MySQL, Postgres, SQLite)
- **Timebox:** Aim for ≤ 1.5 working days. Partial submissions are accepted.
- **Submission:** Public GitHub repo with commit history.

### Schema Fragment

You will only work with these four tables from the legacy schema.

[test_schema.sql](attachment:26446086-8cb0-4068-8849-7fd0c9c400cb:test_schema.sql)

| Domain Concept | Table | Key Columns Used | Purpose |
| --- | --- | --- | --- |
| Bill of Lading | `bl` | `id_bl`, `numero_bl`, `arrival_date`, `freetime`, `id_client`, `nbre_20`, `nbre_40`, `nbre_40hc`, `nbre_45`, `nbre_reefer`, `nbre_ot` | Arrival details for each import BL |
| Customer | `client` | `id_client`, `nom`, `code_client` | Cargo owner / consignee |
| Refund Request | `remboursement` | `id_remboursement`, `numero_bl`, `montant_demande`, `statut` | Deposit refund workflow |
| Invoice | `facture` | `id_facture`, `numero_bl`, `montant_facture`, `devise`, `statut`, `id_client` | Demurrage invoice issued to the customer |

**Caveats:**

- Field names are in French.
- Legacy schema lacks foreign keys.
- Field types and nullability are as in the original schema dump.
- The assumption is that a legacy db exists, so download the sql file and use as is.

### Business Rules

### 1. Overdue Bill of Lading (BL)

A BL is considered overdue on a given date if:

```
due_date = arrival_date + freetime (in days)
overdue when: due_date < current_date
```

For invoice generation, we process BLs that **became overdue yesterday** (simulating a nightly batch job).

### 2. Invoice Generation

- One invoice per overdue BL.
- Invoice amount = `containers_count × 80 × days_overdue` (USD).
- `containers_count` = sum of: `nbre_20 + nbre_40 + nbre_40hc + nbre_45 + nbre_reefer + nbre_ot`
- `days_overdue` = number of days since `due_date` (minimum 1).
- Skip BLs that already have an **open invoice** (any `statut` other than `'paid'`).
- Valid invoice statuses: `'draft'`, `'sent'`, `'paid'`, `'cancelled'`.

### 3. Overdue Invoice

An invoice is considered overdue if:

1. Its `statut` is not `'paid'` or `'cancelled'`, **and**
2. Its `due_date` is earlier than today's date.

Since the legacy schema has no `due_date` for invoices:

- Add a `due_date` column in your migration.
- Default: `due_date = created_at + 15 days`.
- **Bonus:** Make it configurable per customer via `client.payment_terms_days`.

### What to Build

### A. Domain Models & Migrations

- Create a new Rails 7.x project.
- Reverse-engineer the four tables into idiomatic ActiveRecord models:
    - `BillOfLading`
    - `Customer`
    - `RefundRequest`
    - `Invoice`
- Use correct associations, validations, and scopes.
- Add a non-NULL foreign key from `invoices.bl_number` → `bill_of_ladings.bl_number`.
- Create migrations that rename legacy columns to English (e.g., `numero_bl` → `bl_number`, `montant_facture` → `amount`) where it improves readability.

### B. Service Layer

Implement `Demurrage::InvoiceGenerator`:

- Finds BLs that became overdue as of yesterday.
- Creates invoices at the flat rate of USD 80 per container per day overdue.
- Skips BLs with an existing open invoice.
- Returns a result object summarizing created invoices and skipped BLs.

### C. JSON API Endpoints

### `GET /invoices/overdue`

- Returns JSON list of invoices whose `due_date` has passed and are unpaid.
- **Must be scoped to the authenticated customer** (see Security section).
- Response should include: invoice ID, BL number, amount, currency, status, due date, days overdue.

### `POST /invoices/generate`

- Triggers the `InvoiceGenerator` service.
- **Restricted to internal/admin callers only** (see Security section).
- Returns JSON summary: count of invoices created, total amount, list of skipped BL numbers with reasons.

### D. Security Requirements

### Authorization Model

Implement a lightweight authorization layer:

1. **Customer API Token:**
    - Requests include an `X-Api-Token` header.
    - Tokens map to a specific customer (add a `api_token` column to `Customer`).
    - `GET /invoices/overdue` must return **only** invoices belonging to the authenticated customer.
    - Return `401 Unauthorized` for missing/invalid tokens.
2. **Admin Token:**
    - A separate mechanism for internal endpoints.
    - `POST /invoices/generate` requires an `X-Admin-Token` header matching a configured secret (e.g., `Rails.application.credentials.admin_token` or ENV var).
    - Return `403 Forbidden` if called without valid admin token.

### Data Exposure Controls

- Use a serializer (ActiveModel Serializer, Blueprinter, or explicit `as_json`) to control API response shape.
- Do **not** expose: internal database IDs, full customer records, or sensitive fields like tokens.
- Use UUIDs or public-facing identifiers where appropriate.

### Audit Trail

- Log invoice creation events to an `audit_logs` table with: `event_type`, `actor` (system or customer), `resource_type`, `resource_id`, `metadata` (JSON), `created_at`.
- Invoice amounts should be immutable after creation—enforce via model callback or database constraint.

### Input Validation

- Ensure all query parameters and headers are sanitized.
- If you use any raw SQL, demonstrate awareness of injection prevention.

### E. Testing

- **Model specs:** associations, validations, scopes.
- **Request specs:** both API endpoints, including:
    - Happy path
    - Unauthorized/forbidden access
    - Customer scoping (ensure customer A cannot see customer B's invoices)
- **Service spec:** `InvoiceGenerator` logic including edge cases:
    - BL with zero containers
    - BL already has open invoice
    - Multiple BLs for same customer
- **Security specs:** token validation, audit log creation.

### Constraints & Tips

- **Don't** write: background scheduler, UI, password-based auth, or OAuth.
- Seed lightweight fixture data (FactoryBot or Rails fixtures) with at least 2 customers.
- Ignore currency conversions—everything is USD.
- Commit often with meaningful messages—we read your history.
- Keep controllers thin; business logic belongs in services.

## README Requirements

Your README must include:

1. **Setup steps** (`bin/setup` or `docker-compose up`)
2. **How to run tests** (`bundle exec rspec`)
3. **Sample curl commands** for both endpoints, demonstrating:
    - Successful requests with valid tokens
    - Rejected requests with invalid/missing tokens
4. **Design decisions** (≤ 1 page):
    - How you structured authorization
    - Why you chose your serialization approach
    - Any trade-offs or shortcuts taken
    - How you'd extend security for production (rate limiting, token rotation, etc.)

### Evaluation Criteria

| Area | Signals We Score |
| --- | --- |
| **Code Quality** | Separation of concerns, Rails conventions, naming, readability |
| **Migrations** | Correct associations, constraints, sensible renames with justification |
| **Security** | Token validation, customer scoping, no data leakage, audit trail, immutability |
| **Testing** | RSpec structure, realistic factories, edge cases, security scenarios |
| **Business Logic** | Correct overdue calculation, invoice generation, skip logic |
| **Communication** | Clear commits, README clarity, documented trade-offs |

### Bonus (Very Optional)

If you finish early and want to demonstrate more:

- Implement `GET /invoices/:id` with proper authorization (customer can only view their own).
- Add request rate limiting using `Rack::Attack` or similar.
- Implement token rotation: `POST /auth/rotate_token` that issues a new token and invalidates the old one.
- Add a `GET /health` endpoint that checks database connectivity (useful for ops).
