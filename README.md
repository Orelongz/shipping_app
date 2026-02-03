# Shipping App

Details about the test can be found in [overview.md](overview.md). The system processes overdue Bills of Lading (BLs), generates invoices, and exposes secure APIs with customer-scoped access.

## Setup

```bash
# Clone the repository
git clone <repo-url>

# Navigate to the cloned repo
cd shipping_app

# Run below to setup the app
bin/setup
```

## Running the Application

```bash
# Start the Rails server
rails s -p 3000

# The API will be available at http://localhost:3000
```

## Running Tests

```bash
# Run the full test suite
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/invoice_spec.rb
```

## API Endpoints

### GET /invoices/overdue

Returns a list of overdue invoices for the authenticated customer.

**Headers:**
- `X-Api-Token`: Customer API token (required)

**Example Request:**
```bash
curl -H "X-Api-Token: cust_abc123def456" http://localhost:3000/invoices/overdue
```

**Example Response:**
```json
{
  "invoices": [
    {
      "bl_number": "BL000001",
      "amount": "1920.00",
      "currency": "USD",
      "due_date": "2026-02-17T00:00:00.000Z",
      "days_overdue": 8,
      "status": "draft"
    }
  ]
}
```

**Status Codes:**
- `200 OK`: Success
- `401 Unauthorized`: Missing or invalid `X-Api-Token` header

### POST /invoices/generate

Generates new demurrage invoices for BLs that became overdue on the previous day. This is typically called as a nightly batch job.

**Headers:**
- `X-Admin-Token`: Admin/system token (required)

**Example Request:**
```bash
curl -X POST -H "X-Admin-Token: secret-admin-key" http://localhost:3000/invoices/generate
```

**Example Response:**
```json
{
  "created_count": 5,
  "skipped_count": 2,
  "total_amount": 12000,
  "skipped": [
    {
      "bl_number": "BL000010",
      "reason": "Bill of lading currently have zero containers"
    },
    {
      "bl_number": "BL000011",
      "reason": "Open invoice already exists"
    }
  ]
}
```

**Status Codes:**
- `200 OK`: Success
- `403 Forbidden`: Missing or invalid `X-Admin-Token` header


### GET /invoices/:id

Returns invoice details for the authenticated customer.

**Headers:**
- `X-Api-Token`: Customer API token (required)

**Example Request:**
```bash
curl -H "X-Api-Token: cust_abc123def456" http://localhost:3000/invoices/23
```

**Example Response:**
```json
{
  "bl_number": "BL000001",
  "amount": "1920.00",
  "currency": "USD",
  "status": "paid",
  "due_date": "2026-02-17T00:00:00.000Z",
  "days_overdue": 8,
}
```

**Status Codes:**
- `200 OK`: Success
- `401 Unauthorized`: Missing or invalid `X-Api-Token` header
- `404 Not Found`: Invoice does not exist or Invoice does not belong to current customer



## Design decisions

### Authorization structure

Authorization is enforced in the controller layer for all invoice endpoints. For non-admin customers, the request must include a request header with a valide `X-Api-Token` token. This token then matched against a customer record. The records (invoices in this case) only belonging to the found customer is then returned. A better authorization structure would have been to use [pundit](https://github.com/varvet/pundit) with policies and scopes that would ensure the right access.

### Serialization approach

The APIs use a dedicated blueprint to serialize invoices which is flexible and can be adapted for different scenarios. This is then reused in multiple places; controller, services, e.t.c. It also ensures that fields are not accidentally exposed.

### Trade-offs and shortcuts

- Token storage is simple and assumes a single active token per customer.
- Authorization is token-only; no scopes or roles are enforced yet.
- Simple error messages and no extensive error handling mechanism.

### Production security extensions

In production I would add:

- 
- Rate limiting per customer and per IP.
- Token rotation with expiry timestamps and a revoke list (I haven't done this before so very limited knowledge here)
- Audit logging for failed auth attempts and unusual access patterns.
- Stricter header validation.
- Bearer token VS passing api token as it is
- closely consider fields that needs to be indexed based on future use cases
