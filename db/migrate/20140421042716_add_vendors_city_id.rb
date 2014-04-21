class AddVendorsCityId < ActiveRecord::Migration
  def up
    add_column :venues, :city_id, :integer
    add_index :venues, :city_id

    unless Rails.env.test?
      execute "UPDATE venues SET city_id=1 WHERE city='Portland'"
      execute "UPDATE venues SET city_id=2 WHERE city='Seattle'"
    end
  end

  def down
    drop_column :venues, :city_id
  end
end
