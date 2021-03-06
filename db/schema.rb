# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140504193357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", force: true do |t|
    t.string   "name"
    t.integer  "zip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists_events", force: true do |t|
    t.integer  "artist_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artists_events", ["artist_id"], name: "index_artists_events_on_artist_id", using: :btree
  add_index "artists_events", ["event_id"], name: "index_artists_events_on_event_id", using: :btree

  create_table "cities", force: true do |t|
    t.string "name"
    t.string "slug"
    t.string "state"
    t.string "country"
  end

  add_index "cities", ["slug", "state", "country"], name: "index_cities_on_slug_and_state_and_country", unique: true, using: :btree

  create_table "data_sources", force: true do |t|
    t.string   "name",       limit: 30, null: false
    t.string   "url",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "title"
    t.integer  "venue_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_info"
    t.string   "price_info"
  end

  add_index "events", ["venue_id"], name: "index_events_on_venue_id", using: :btree

  create_table "genre_points", force: true do |t|
    t.string   "target_type", limit: 30,               null: false
    t.integer  "target_id",                            null: false
    t.integer  "genre_id",                             null: false
    t.float    "value",                  default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "point_type",  limit: 20,               null: false
    t.string   "source_type", limit: 20,               null: false
    t.integer  "source_id",                            null: false
  end

  create_table "genres", force: true do |t|
    t.string   "name",        limit: 40, null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genres", ["name"], name: "index_genres_on_name", unique: true, using: :btree

  create_table "job_runs", force: true do |t|
    t.string   "job_type",    limit: 30, null: false
    t.string   "sub_type",    limit: 30
    t.string   "target_type", limit: 30, null: false
    t.integer  "target_id",              null: false
    t.string   "status",      limit: 20
    t.string   "error_id",    limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_runs", ["error_id"], name: "index_job_runs_on_error_id", using: :btree
  add_index "job_runs", ["job_type"], name: "index_job_runs_on_job_type", using: :btree
  add_index "job_runs", ["target_type", "target_id"], name: "index_job_runs_on_target_type_and_target_id", using: :btree

  create_table "page_downloads", force: true do |t|
    t.datetime "downloaded_at",  null: false
    t.integer  "data_source_id", null: false
    t.string   "storage_uri"
    t.datetime "imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "venues", force: true do |t|
    t.integer  "zip_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "zip"
    t.string   "phone"
    t.integer  "city_id"
  end

  add_index "venues", ["city_id"], name: "index_venues_on_city_id", using: :btree

end
