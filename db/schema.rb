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

ActiveRecord::Schema.define(version: 20131022144425) do

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

  create_table "events", force: true do |t|
    t.string   "title"
    t.integer  "venue_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["venue_id"], name: "index_events_on_venue_id", using: :btree

  create_table "venues", force: true do |t|
    t.integer  "zip_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
  end

end