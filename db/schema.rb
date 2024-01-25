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

ActiveRecord::Schema[7.1].define(version: 2024_01_25_134735) do
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
    t.text "direction"
    t.index ["stop_id"], name: "index_arrival_updates_on_stop_id"
    t.index ["vehicle_id", "stop_id", "stop_name", "line_name", "direction", "platform_name", "destination_name"], name: "idx_on_vehicle_id_stop_id_stop_name_line_name_direc_d856848404", unique: true
    t.unique_constraint ["stop_id", "stop_name", "vehicle_id", "line_name", "platform_name", "destination_name"], name: "constraintarr"
  end

  create_table "arrivalt", id: false, force: :cascade do |t|
    t.text "stop_id"
    t.text "vehicle_id"
    t.datetime "expected_arrival", precision: nil
    t.datetime "timestamp", precision: nil
  end

  create_table "customer_import", id: false, force: :cascade do |t|
    t.json "doc"
  end

  create_table "journey_pattern_section_maps", force: :cascade do |t|
    t.text "journey_pattern_ref"
    t.bigint "journey_pattern_id"
    t.text "journey_pattern_section_ref"
    t.bigint "journey_pattern_section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journey_pattern_id"], name: "index_journey_pattern_section_maps_on_journey_pattern_id"
    t.index ["journey_pattern_ref", "journey_pattern_section_ref"], name: "idx_on_journey_pattern_ref_journey_pattern_section__f02c42769a", unique: true
    t.index ["journey_pattern_section_id"], name: "idx_on_journey_pattern_section_id_4cd47a0e6a"
  end

  create_table "journey_pattern_sections", force: :cascade do |t|
    t.text "journey_pattern_section_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journey_pattern_timing_links", force: :cascade do |t|
    t.text "line_id"
    t.text "from_stop"
    t.text "to_stop"
    t.integer "run_time_to_stop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.interval "wait_time"
    t.interval "run_time"
    t.bigint "journey_pattern_section_id"
    t.text "journey_pattern_timing_link_ref"
    t.interval "total_time_since_start"
    t.index ["journey_pattern_section_id"], name: "idx_on_journey_pattern_section_id_42f28e5879"
    t.index ["journey_pattern_timing_link_ref"], name: "idx_on_journey_pattern_timing_link_ref_603a24e2bb", unique: true
  end

  create_table "journey_patterns", force: :cascade do |t|
    t.text "journey_pattern_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journeys", force: :cascade do |t|
    t.text "line_id"
    t.text "journey_pattern_id"
    t.time "departure_time"
    t.text "days_of_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jsontemp", id: false, force: :cascade do |t|
    t.json "doc"
  end

  create_table "jsontemps", force: :cascade do |t|
    t.json "doc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.text "line_name"
    t.text "direction"
    t.text "linestrings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "t", id: false, force: :cascade do |t|
    t.json "j"
  end

  create_table "vehicle_journey_days", force: :cascade do |t|
    t.bigint "vehicle_journey_id"
    t.text "vehicle_journey_code"
    t.text "day_of_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_journey_id"], name: "index_vehicle_journey_days_on_vehicle_journey_id"
  end

  create_table "vehicle_journeys", force: :cascade do |t|
    t.text "line_name"
    t.text "journey_pattern_ref"
    t.time "departure_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "vehicle_journey_code"
    t.bigint "journey_pattern_id"
    t.text "bh_days_operating", array: true
    t.text "bh_days_not_operating", array: true
    t.text "special_days_starts", array: true
    t.text "special_days_ends", array: true
    t.text "days_of_week", array: true
    t.index ["journey_pattern_id"], name: "index_vehicle_journeys_on_journey_pattern_id"
    t.index ["vehicle_journey_code"], name: "index_vehicle_journeys_on_vehicle_journey_code", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.text "line_name"
    t.text "vehicle_ref"
    t.float "latitude"
    t.float "longitude"
    t.float "bearing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "recorded_at", precision: nil
    t.index ["vehicle_ref", "recorded_at"], name: "index_vehicles_on_vehicle_ref_and_recorded_at", unique: true
  end

  create_table "xmltemp", id: false, force: :cascade do |t|
    t.xml "doc"
  end

  add_foreign_key "journey_pattern_section_maps", "journey_pattern_sections"
  add_foreign_key "journey_pattern_section_maps", "journey_patterns"
  add_foreign_key "vehicle_journey_days", "vehicle_journeys"
  add_foreign_key "vehicle_journeys", "journey_patterns"
end
