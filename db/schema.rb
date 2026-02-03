# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_03_175307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.string "event_type", null: false
    t.string "actor", null: false, comment: "system or customer identifier"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false, comment: "ID of the resource modified"
    t.jsonb "metadata", default: {}, comment: "Additional context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_audit_logs_on_event_type"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
  end

  create_table "bill_of_ladings", force: :cascade do |t|
    t.bigint "customer_id", comment: "Legacy id_client"
    t.string "bl_number", null: false, comment: "Legacy bl_number"
    t.datetime "arrival_date", null: false, comment: "Legacy arrival_date"
    t.integer "freetime", default: 0, null: false, comment: "Free time in days"
    t.integer "number_of_20ft_containers", default: 0, comment: "Translation for legacy nbre_20"
    t.integer "number_of_40ft_containers", default: 0, comment: "Translation for legacy nbre_40"
    t.integer "number_of_40ft_high_cube_containers", default: 0, comment: "Translation for legacy nbre_40hc"
    t.integer "number_of_45ft_containers", default: 0, comment: "Translation for legacy nbre_45"
    t.integer "number_of_reefer_containers", default: 0, comment: "Translation for legacy nbre_reefer"
    t.integer "number_of_other_containers", default: 0, comment: "Translation for legacy nbre_ot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_date"], name: "index_bill_of_ladings_on_arrival_date"
    t.index ["bl_number"], name: "index_bill_of_ladings_on_bl_number", unique: true
    t.index ["customer_id"], name: "index_bill_of_ladings_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false, comment: "Legacy nom"
    t.string "code", null: false, comment: "Legacy code_client"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_terms_days", default: 15, null: false, comment: "Number of days for payment terms"
    t.string "api_token", null: false, comment: "API token for authenticating API requests"
    t.index ["api_token"], name: "index_customers_on_api_token", unique: true
    t.index ["code"], name: "index_customers_on_code", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "customer_id", comment: "Legacy id_client"
    t.string "bl_number", null: false, comment: "Foreign key to bill_of_ladings"
    t.decimal "amount", precision: 12, null: false, comment: "Legacy montant_facture"
    t.string "currency", default: "USD", null: false, comment: "Legacy devise"
    t.string "status", default: "draft", null: false, comment: "Legacy statut (draft, sent, paid, overdue)"
    t.datetime "due_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bl_number"], name: "index_invoices_on_bl_number"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
  end

  create_table "refund_requests", force: :cascade do |t|
    t.string "bl_number", null: false, comment: "Legacy numero_bl"
    t.string "amount_requested", comment: "Legacy montant_demande"
    t.string "status", default: "PENDING", null: false, comment: "Legacy statut (PENDING, APPROVED, REJECTED, PAID)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bl_number"], name: "index_refund_requests_on_bl_number"
    t.index ["status"], name: "index_refund_requests_on_status"
  end

  add_foreign_key "bill_of_ladings", "customers"
  add_foreign_key "invoices", "bill_of_ladings", column: "bl_number", primary_key: "bl_number"
  add_foreign_key "invoices", "customers"
  add_foreign_key "refund_requests", "bill_of_ladings", column: "bl_number", primary_key: "bl_number"
end
