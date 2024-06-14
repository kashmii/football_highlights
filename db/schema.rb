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

ActiveRecord::Schema[7.0].define(version: 2024_06_01_035435) do
  create_table "games", charset: "utf8mb4", force: :cascade do |t|
    t.integer "league", default: 0, null: false
    t.integer "game_week", null: false
    t.datetime "kickoff_time", null: false
    t.string "home_team", null: false
    t.string "away_team", null: false
    t.string "highlight_url"
    t.boolean "is_tweeted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league", "game_week", "home_team"], name: "index_games_on_league_and_game_week_and_home_team", unique: true
  end

end
