class MbtileGenerator
  include Sidekiq::Worker

  def perform area_id, habitat
    Mbtile.find_or_create_by_area_id_and_habitat(area_id, habitat).generate
  end
end
