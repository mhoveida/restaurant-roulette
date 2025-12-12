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

ActiveRecord::Schema[8.1].define(version: 2025_12_12_152455) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "restaurants", force: :cascade do |t|
    t.text "address"
    t.text "categories"
    t.string "closing_time"
    t.datetime "created_at", null: false
    t.text "dietary_restrictions"
    t.string "image_url"
    t.boolean "is_open_now", default: true
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "neighborhood"
    t.string "phone"
    t.string "price"
    t.decimal "rating", precision: 2, scale: 1
    t.integer "review_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_restaurants_on_id", unique: true
    t.index ["name"], name: "index_restaurants_on_name"
    t.index ["price"], name: "index_restaurants_on_price"
    t.index ["rating"], name: "index_restaurants_on_rating"
  end

  create_table "rooms", force: :cascade do |t|
    t.jsonb "categories", default: []
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "current_round", default: 0
    t.integer "current_turn_index", default: 0
    t.jsonb "dietary_restrictions", default: []
    t.string "location"
    t.jsonb "members", default: []
    t.string "owner_name"
    t.string "price"
    t.jsonb "reveal_order", default: []
    t.json "spin_result"
    t.jsonb "spins", default: []
    t.integer "state", default: 0, null: false
    t.jsonb "turn_order", default: []
    t.datetime "updated_at", null: false
    t.jsonb "votes", default: {}
    t.jsonb "winner"
    t.index ["state"], name: "index_rooms_on_state"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "user_restaurant_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "visited_at"
    t.index ["restaurant_id"], name: "index_user_restaurant_histories_on_restaurant_id"
    t.index ["user_id", "restaurant_id"], name: "index_user_restaurant_histories_on_user_id_and_restaurant_id", unique: true
    t.index ["user_id"], name: "index_user_restaurant_histories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "user_restaurant_histories", "restaurants"
  add_foreign_key "user_restaurant_histories", "users"
end
