class AddHabitatColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production? || Rails.env.staging?
      add_column :geometries, :habitat, :string
    end
  end
end
