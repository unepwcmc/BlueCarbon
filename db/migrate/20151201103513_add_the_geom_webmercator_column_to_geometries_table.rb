class AddTheGeomWebmercatorColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production? || Rails.env.staging?
      add_column :geometries, :the_geom_webmercator, :string
    end
  end
end
