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

ActiveRecord::Schema[8.1].define(version: 101) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "bcc"
    t.text "body"
    t.string "cc"
    t.string "content_type"
    t.datetime "created_at", precision: nil
    t.string "from"
    t.string "subject"
    t.string "template_name"
    t.datetime "updated_at", precision: nil
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "roles_mask"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.integer "work_experience_mentor_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "work_experience_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "minimum_hours"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "work_experience_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.decimal "week_1", precision: 10, scale: 2
    t.decimal "week_2", precision: 10, scale: 2
    t.decimal "week_3", precision: 10, scale: 2
    t.decimal "week_4", precision: 10, scale: 2
    t.decimal "week_5", precision: 10, scale: 2
    t.integer "work_experience_record_id"
    t.integer "work_experience_subcategory_id"
    t.index ["work_experience_record_id"], name: "index_work_experience_entries_on_work_experience_record_id"
  end

  create_table "work_experience_outside_mentors", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "regulated_profession"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id", "user_type"], name: "index_work_experience_outside_mentors_on_user_id_and_user_type", unique: true
  end

  create_table "work_experience_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_on"
    t.string "name"
    t.date "start_on"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id", "user_type"], name: "index_work_experience_projects_on_user_id_and_user_type"
  end

  create_table "work_experience_records", force: :cascade do |t|
    t.boolean "backdated", default: false
    t.datetime "created_at", null: false
    t.date "month"
    t.datetime "reviewed_at", precision: nil
    t.string "status"
    t.text "status_steps"
    t.datetime "submitted_at", precision: nil
    t.decimal "total_hours", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id", "user_type"], name: "index_work_experience_records_on_user_id_and_user_type"
  end

  create_table "work_experience_subcategories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "minimum_hours"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "work_experience_category_id"
  end

  create_table "work_experience_summaries", force: :cascade do |t|
    t.text "comments"
    t.datetime "created_at", null: false
    t.date "end_on"
    t.integer "mentor_id"
    t.string "mentor_type"
    t.string "recommendation"
    t.datetime "reviewed_at", precision: nil
    t.date "start_on"
    t.string "status"
    t.text "status_steps"
    t.datetime "submitted_at", precision: nil
    t.integer "supervisor_id"
    t.string "supervisor_type"
    t.string "token"
    t.decimal "total_hours", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.text "wizard_steps"
    t.index ["mentor_id", "mentor_type"], name: "index_work_experience_summaries_on_mentor_id_and_mentor_type"
    t.index ["user_id", "user_type"], name: "index_work_experience_summaries_on_user_id_and_user_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
