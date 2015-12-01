class AddTheGeomWebmercatorColumnToGeometriesTable < ActiveRecord::Migration
  def change
    unless Rails.env.production?
      add_column :geometries, :the_geom_webmercator, :string
    end
  end
end
