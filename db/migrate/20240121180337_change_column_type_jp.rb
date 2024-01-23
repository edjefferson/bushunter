class ChangeColumnTypeJp < ActiveRecord::Migration[7.1]
  def change
    remove_column(:journey_pattern_timing_links, :run_time, :text)

    add_column(:journey_pattern_timing_links, :wait_time, :interval)
    add_column(:journey_pattern_timing_links, :run_time, :interval)
    rename_column :journey_pattern_timing_links, :from, :from_stop
    rename_column :journey_pattern_timing_links, :to, :to_stop

  end
end
