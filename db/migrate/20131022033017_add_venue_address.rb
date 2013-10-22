class AddVenueAddress < ActiveRecord::Migration
  def change
    change_table :venues, bulk: true do |t|
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state, length: 2
      t.string :zip, length: 10
      t.string :phone, length: 12
    end
  end
end
