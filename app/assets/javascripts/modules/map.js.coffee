window.Map = class Map
  HABITATS =
    mangrove: '#008b00'
    seagrass: '#9b1dea'
    saltmarsh: '#007dff'
    algal_mat: '#ffe048'
    other: '#1dcbea'
  DEFAULT_MAP_OPTS =
    center: [24.5, 54]
    zoom: 9
    minZoom: 8
    maxZoom: 19

  constructor: (elementId, mapOpts={}) ->
    @baseMap = L.tileLayer('http://tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/997/256/{z}/{x}/{y}.png', {maxZoom: 17})
    @baseSatellite =  new L.BingLayer("ApZALeudlU-OTm7Me2qekFHrstBXNdv3hft6qy3ZeTQWD6a460-QqCQyYnDigINc", {type: "Aerial", maxZoom: 19})

    @initializeMap(elementId, mapOpts)
    @addAttribution()
    @addOverlays( (err, overlays) =>
      L.control.layers(@baseMaps, overlays).addTo(@map)
    )

  initializeMap: (elementId, mapOpts) ->
    mapOpts = _.extend(DEFAULT_MAP_OPTS, mapOpts)
    mapOpts.layers = [@baseSatellite]
    @map = L.map(elementId, mapOpts)

  addAttribution: ->
    attribution = L.control.attribution(position: 'bottomright', prefix: '')
    attribution.addAttribution('Developed for the UAE Blue Carbon Demonstration Project')
    attribution.addTo(@map)

  baseMaps: ->
    baseMaps = {}
    baseMaps[polyglot.t('analysis.map')] = @baseMap
    baseMaps[polyglot.t('analysis.satellite')] = @baseSatellite

  addOverlays: (done) ->
    async.reduce(@getSublayers(), {}, (sublayers, sublayer, cb) =>
      cartodb.Tiles.getTiles({
        sublayers: [sublayer.cartodb]
        type: 'cartodb'
        user_name: "carbon-tool"
      }, (tiles, error) =>
        prettyName = polyglot.t("analysis.#{sublayer.habitat}")
        sublayers[prettyName] = L.tileLayer(tiles.tiles[0]).addTo(@map)
        cb(null, sublayers)
      )
    )

  getSublayers: ->
    _.map(HABITATS, (polygon_fill, habitat) ->
      query = "SELECT * FROM bc_#{habitat} WHERE toggle = true AND (action <> 'delete' OR action IS NULL)"
      style = """
        #bc_#{habitat} {
          line-color: #FFF;
          line-width: 0.5;
          polygon-fill: #{polygon_fill};
          polygon-opacity: 0.4
        }
      """

      {habitat: habitat, cartodb: {sql: query, cartocss: style}}
    )
