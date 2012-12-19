class Mbtile < ActiveRecord::Base
  attr_accessible :area_id, :habitat, :last_generation_started_at, :last_generated_at, :status

  belongs_to :area

  after_create do
    Mbtile.delay.generate(area_id, habitat)
  end

  def self.generate(area_id, habitat)
    find_or_create_by_area_id_and_habitat(area_id, habitat).generate
  end

  def completed?
    status == 'complete'
  end

  def last_validation_updated_at
    area.validations.select(:updated_at).order('updated_at DESC').try(:first).try(:updated_at)
  end

  def generate
    # Don't do anything if last generation was after the last validation edit
    return if last_generation_started_at && last_validation_updated_at && last_generation_started_at > last_validation_updated_at

    update_attributes(status: 'generating', last_generation_started_at: Time.now)

    # Makes sure the export path exists
    export_path

    generate_style
    generate_geojson
    generate_mml(10, 11)

    config_file = generate_config(10, 11)

    system "#{APP_CONFIG['projectmill_path']}/index.js --mill --render -p #{tilemill_path}/ -c #{config_file} -t #{APP_CONFIG['tilemill_path']}"

    update_attributes(status: 'complete', last_generated_at: Time.now)
  end

  def final_path
    "#{export_path}/#{habitat}_final.mbtiles"
  end

  private

  def generate_style
    colors = {mangrove: '008b00', seagrass: '9b1dea', sabkha: 'f38417', salt_marsh: '007dff'}

    "#{habitat_path}/style.mss".tap do |path|
      File.open(path, "w") do |f|
        f.write <<-MSS
##{habitat} {
  line-color: #fff;
  line-width: 0.5;
  polygon-opacity: 0.5;
  polygon-fill: ##{colors[habitat.intern]};
}
        MSS
      end
    end
  end

  def generate_geojson
    require 'open-uri'

    "#{layers_path}/polygons.kml".tap do |path|
      File.open(path, "w") do |f|
        f.write(open(cartodb_query).read)
      end
    end
  end

  def generate_mml(minzoom, maxzoom=22)
    min_y, min_x, max_y, max_x = JSON.parse(area.coordinates).flatten

    mml = {
      bounds: [min_x, min_y, max_x, max_y],
      center: [min_x + ((max_x - min_x) / 2), min_y + ((max_y - min_y) / 2), minzoom],
      format: "png8", interactivity: false, minzoom: minzoom, maxzoom: maxzoom,
      srs: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over",
      Stylesheet: ["style.mss"],
      Layer: [{
        geometry: "polygon", extent: [min_x, min_y, max_x, max_y],
        id: habitat, :'class' => "",
        Datasource: { file: cartodb_query },
        :'srs-name' => "WGS84",
        srs: "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs",
        advanced: {}, name: habitat
      }],
      scale: 1, metatile: 4, name: '', description: ''
    }

    "#{habitat_path}/project.mml".tap do |path|
      File.open(path, "w") do |f|
        f.write(mml.to_json)
      end
    end
  end

  def generate_config(minzoom, maxzoom)
    config = [{
      source: habitat,
      destination: "#{habitat}_final",
      format: "mbtiles", minzoom: minzoom, maxzoom: maxzoom, mml: {}
    }]

    "#{habitat_path}/config.json".tap do |path|
      File.open(path, "w") do |f|
        f.write(config.to_json)
      end
    end
  end

  def layers_path
    habitat_path.join('layers').tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def habitat_path
    tilemill_path.join('project', habitat).tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def export_path
    tilemill_path.join('export').tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def tilemill_path
    Rails.root.join('lib', 'tilemill', area.id.to_s).tap do |dir|
      FileUtils.mkdir_p dir unless File.directory? dir
    end
  end

  def cartodb_query
    require 'uri'

    habitat_model = Habitat.find(habitat)
    geom = "ST_GeomFromText(ST_AsText(ST_GeomFromGeoJson('#{area.geo_json}')),4326)"

    URI.escape("http://carbon-tool.cartodb.com/api/v2/sql?format=kml&q=SELECT * FROM #{habitat_model.table_name} WHERE ST_Intersects(#{geom},the_geom)")
  end
end
