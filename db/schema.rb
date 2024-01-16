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

ActiveRecord::Schema[7.1].define(version: 2024_01_16_115211) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arrival_updates", force: :cascade do |t|
    t.text "stop_id"
    t.text "stop_name"
    t.text "vehicle_id"
    t.integer "time_to_station"
    t.text "line_name"
    t.datetime "timestamp", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expected_arrival", precision: nil
    t.text "platform_name"
    t.text "destination_name"
    t.index ["stop_id"], name: "index_arrival_updates_on_stop_id"
    t.index ["vehicle_id", "stop_id"], name: "index_arrival_updates_on_vehicle_id_and_stop_id", unique: true
  end

  create_table "stop_points", force: :cascade do |t|
    t.text "stop_id"
    t.text "name"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "stop_letter"
    t.index ["stop_id"], name: "index_stop_points_on_stop_id", unique: true
  end

end
