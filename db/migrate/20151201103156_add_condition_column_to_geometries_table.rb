class AddConditionColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production?
      add_column :geometries, :condition, :string
    end
  end
end
