class RenameGenrePointsTypeToPointType < ActiveRecord::Migration
  def change
    rename_column :genre_points, :type, :point_type
  end
end
