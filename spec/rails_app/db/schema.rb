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

ActiveRecord::Schema.define(version: 20151217081610) do

  create_table "authors", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "year"
    t.integer "prize_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_with_custom_primary_keys", id: false, force: :cascade do |t|
    t.integer "uid"
    t.string "title"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "exemplars"
    t.boolean "digitized", default: false
    t.text "notes"
    t.date "published_on"
    t.datetime "last_read_at"
    t.string "tags"
    t.integer "rating"
    t.decimal "price", precision: 7, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_records", force: :cascade do |t|
    t.string "file_name", null: false
    t.integer "size", default: 0
    t.boolean "leaf", default: true
    t.boolean "expanded", default: false
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lft"], name: "index_file_records_on_lft"
    t.index ["parent_id"], name: "index_file_records_on_parent_id"
    t.index ["rgt"], name: "index_file_records_on_rgt"
  end

  create_table "illustrations", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
