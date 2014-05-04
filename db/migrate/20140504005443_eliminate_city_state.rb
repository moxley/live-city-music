class EliminateCityState < ActiveRecord::Migration
  def change
    change_table :venues, bulk: true do |t|
      t.remove :city
      t.remove :state
    end
  end
end
