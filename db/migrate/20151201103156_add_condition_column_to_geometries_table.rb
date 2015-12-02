class AddConditionColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production? || Rails.env.staging?
      add_column :geometries, :condition, :string
    end
  end
end
