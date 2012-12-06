class BlueCarbon.Views.Validations.MapView extends Backbone.View
  initialize: (options) ->
    @map = L.map('map',
      center: [24.5,54]
      zoom: 9
    )

    tileLayerUrl = 'http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png';
    tileLayer = new L.TileLayer(tileLayerUrl, {maxZoom: 18}).addTo(@map)

    BlueCarbon.Map = @map

  events:
    "click #back-button": "close"

  close: ->
    console.log 'Iwas called'
