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

ActiveRecord::Schema[7.2].define(version: 2026_02_12_034428) do
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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
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

  create_table "albums", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.bigint "child_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_albums_on_child_id"
    t.index ["family_group_id"], name: "index_albums_on_family_group_id"
  end

  create_table "children", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.string "name"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_group_id"], name: "index_children_on_family_group_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "family_group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 4, null: false
    t.boolean "is_admin", default: false, null: false
    t.index ["family_group_id"], name: "index_family_group_memberships_on_family_group_id"
    t.index ["user_id", "family_group_id"], name: "index_family_group_memberships_on_user_id_and_family_group_id", unique: true
    t.index ["user_id"], name: "index_family_group_memberships_on_user_id"
  end

  create_table "family_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invite_tokens", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_group_id"], name: "index_invite_tokens_on_family_group_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.text "message"
    t.string "notification_type"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "person_tags", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_group_id", "normalized_name"], name: "index_person_tags_on_family_group_id_and_normalized_name", unique: true
    t.index ["family_group_id"], name: "index_person_tags_on_family_group_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["post_id"], name: "index_photos_on_post_id"
  end

  create_table "post_person_tags", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "person_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_tag_id"], name: "index_post_person_tags_on_person_tag_id"
    t.index ["post_id", "person_tag_id"], name: "index_post_person_tags_on_post_id_and_person_tag_id", unique: true
    t.index ["post_id"], name: "index_post_person_tags_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "album_id", null: false
    t.bigint "user_id", null: false
    t.bigint "child_id"
    t.string "title"
    t.text "content"
    t.date "photo_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1, null: false
    t.index ["album_id"], name: "index_posts_on_album_id"
    t.index ["child_id"], name: "index_posts_on_child_id"
    t.index ["status"], name: "index_posts_on_status"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "line_uid"
    t.string "email"
    t.bigint "family_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 2, null: false
    t.index ["family_group_id"], name: "index_users_on_family_group_id"
    t.index ["line_uid"], name: "index_users_on_line_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "albums", "children"
  add_foreign_key "albums", "family_groups"
  add_foreign_key "children", "family_groups"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "family_group_memberships", "family_groups"
  add_foreign_key "family_group_memberships", "users"
  add_foreign_key "invite_tokens", "family_groups"
  add_foreign_key "notifications", "users"
  add_foreign_key "person_tags", "family_groups"
  add_foreign_key "photos", "posts"
  add_foreign_key "post_person_tags", "person_tags"
  add_foreign_key "post_person_tags", "posts"
  add_foreign_key "posts", "albums"
  add_foreign_key "posts", "children"
  add_foreign_key "posts", "users"
  add_foreign_key "users", "family_groups"
end
