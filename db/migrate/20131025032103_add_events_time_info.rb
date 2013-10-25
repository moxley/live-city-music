class AddEventsTimeInfo < ActiveRecord::Migration
  def change
    add_column :events, :time_info, :string
  end
end
