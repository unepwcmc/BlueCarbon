class AddHabitatColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production?
      add_column :geometries, :habitat, :string
    end
  end
end
