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

ActiveRecord::Schema[8.1].define(version: 2026_02_04_011900) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "profiles", force: :cascade do |t|
    t.string "avatar_url"
    t.integer "contributions_last_year", default: 0
    t.datetime "created_at", null: false
    t.integer "followers", default: 0
    t.integer "following", default: 0
    t.string "github_username"
    t.text "last_error"
    t.datetime "last_scanned_at"
    t.string "location"
    t.string "name", null: false
    t.jsonb "organizations", default: []
    t.string "scraping_status", default: "pending"
    t.string "short_github_url"
    t.integer "stars", default: 0
    t.datetime "updated_at", null: false
    t.index ["github_username"], name: "index_profiles_on_github_username"
    t.index ["short_github_url"], name: "index_profiles_on_short_github_url", unique: true
  end
end
