class AddEventsPriceInfo < ActiveRecord::Migration
  def change
    add_column :events, :price_info, :string
  end
end
