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

ActiveRecord::Schema[8.1].define(version: 2025_11_27_171004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.text "notes"
    t.bigint "patient_id", null: false
    t.bigint "practitioner_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "scheduled_at"], name: "index_appointments_on_patient_id_and_scheduled_at"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["practitioner_id", "scheduled_at"], name: "index_appointments_on_practitioner_id_and_scheduled_at"
    t.index ["practitioner_id"], name: "index_appointments_on_practitioner_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "appointment_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date", null: false
    t.datetime "paid_at"
    t.bigint "patient_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_invoices_on_appointment_id"
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["patient_id"], name: "index_invoices_on_patient_id"
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "medical_records", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.datetime "created_at", null: false
    t.text "diagnosis"
    t.text "notes"
    t.bigint "patient_id", null: false
    t.bigint "practitioner_id", null: false
    t.text "treatment"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_medical_records_on_appointment_id"
    t.index ["patient_id"], name: "index_medical_records_on_patient_id"
    t.index ["practitioner_id"], name: "index_medical_records_on_practitioner_id"
  end

  create_table "patients", force: :cascade do |t|
    t.text "address"
    t.date "birth_date"
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_patients_on_cpf", unique: true
  end

  create_table "practitioners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "crm"
    t.string "name"
    t.string "phone"
    t.string "specialty"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["crm"], name: "index_practitioners_on_crm", unique: true
    t.index ["user_id"], name: "index_practitioners_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "practitioners"
  add_foreign_key "invoices", "appointments"
  add_foreign_key "invoices", "patients"
  add_foreign_key "medical_records", "appointments"
  add_foreign_key "medical_records", "patients"
  add_foreign_key "medical_records", "practitioners"
  add_foreign_key "practitioners", "users"
end
