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

ActiveRecord::Schema[7.2].define(version: 2025_11_14_081135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.bigint "child_id", null: false
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

  create_table "family_groups", force: :cascade do |t|
    t.string "name"
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

  create_table "photos", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_photos_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "album_id", null: false
    t.bigint "user_id", null: false
    t.bigint "child_id", null: false
    t.string "title"
    t.text "content"
    t.date "photo_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_posts_on_album_id"
    t.index ["child_id"], name: "index_posts_on_child_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "line_uid"
    t.string "email"
    t.bigint "family_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_group_id"], name: "index_users_on_family_group_id"
    t.index ["line_uid"], name: "index_users_on_line_uid", unique: true
  end

  add_foreign_key "albums", "children"
  add_foreign_key "albums", "family_groups"
  add_foreign_key "children", "family_groups"
  add_foreign_key "invite_tokens", "family_groups"
  add_foreign_key "notifications", "users"
  add_foreign_key "photos", "posts"
  add_foreign_key "posts", "albums"
  add_foreign_key "posts", "children"
  add_foreign_key "posts", "users"
  add_foreign_key "users", "family_groups"
end
