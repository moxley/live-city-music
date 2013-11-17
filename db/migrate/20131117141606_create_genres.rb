class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :name, limit: 30, null: false
      t.string :description
    end
  end
end
