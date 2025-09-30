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

ActiveRecord::Schema[7.2].define(version: 2025_09_25_045745) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.bigint "patient_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "disease"
    t.datetime "scheduled_at"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "availables", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.jsonb "available_days", default: [], null: false
    t.time "start_time"
    t.time "end_time"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_availables_on_doctor_id"
  end

  create_table "bills", force: :cascade do |t|
    t.date "bill_date"
    t.decimal "tot_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "paid_amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "appointment_id"
    t.boolean "is_assigned"
    t.index ["appointment_id"], name: "index_bills_on_appointment_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "license_id"
    t.integer "experience"
    t.string "type_of_degree"
    t.decimal "salary", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "doctors_specializations", id: false, force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.bigint "specialization_id", null: false
    t.index ["doctor_id"], name: "index_doctors_specializations_on_doctor_id"
    t.index ["specialization_id"], name: "index_doctors_specializations_on_specialization_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "blood_group"
    t.boolean "organ_donor", default: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "bill_id", null: false
    t.string "payment_method"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount_to_be_paid"
    t.index ["bill_id"], name: "index_payments_on_bill_id"
  end

  create_table "specializations", force: :cascade do |t|
    t.string "specialization", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string "shift"
    t.decimal "salary", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_permanant"
    t.string "qualification"
  end

  create_table "users", force: :cascade do |t|
    t.string "userable_type"
    t.bigint "userable_id"
    t.string "name"
    t.date "dob"
    t.integer "age"
    t.string "gender"
    t.string "phone_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable"
  end

  add_foreign_key "appointments", "doctors"
  add_foreign_key "appointments", "patients"
  add_foreign_key "availables", "doctors"
  add_foreign_key "bills", "appointments"
  add_foreign_key "payments", "bills"
end
