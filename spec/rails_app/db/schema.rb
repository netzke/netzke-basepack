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

ActiveRecord::Schema.define(version: 20130105145239) do

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "street"
    t.string   "city"
    t.string   "postcode"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "book_with_custom_primary_keys", id: false, force: :cascade do |t|
    t.integer  "uid"
    t.string   "title"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", force: :cascade do |t|
    t.integer  "author_id"
    t.string   "title"
    t.integer  "exemplars"
    t.boolean  "digitized",                             default: false
    t.text     "notes"
    t.string   "tags"
    t.integer  "rating"
    t.decimal  "price",         precision: 7, scale: 2
    t.float    "special_index"
    t.string   "cover"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_read_at"
    t.date     "published_on"
  end

  create_table "developers", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "title"
    t.integer  "developer_id"
    t.integer  "project_id"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
