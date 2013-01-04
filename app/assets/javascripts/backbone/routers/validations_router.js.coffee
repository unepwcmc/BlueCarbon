class BlueCarbon.Routers.ValidationsRouter extends Backbone.Router
  initialize: (options) ->
    @validations = new BlueCarbon.Collections.ValidationsCollection()
    @validations.reset options.validations

    @areas = new BlueCarbon.Collections.AreasCollection()
    @areas.reset options.areas

  routes:
    "new"           : "newValidation"
    "new/:z/:y/:x"  : "newValidation"
    "index"         : "index"
    ":id/edit"      : "edit"
    ":id"           : "show"
    ".*"            : "index"

  newValidation: (z, y, x) ->
    @view = new BlueCarbon.Views.Validations.NewView(collection: @validations, areas: @areas)
    $("#validations").html(@view.render().el)

    # Map
    if z && y && x
      @initializeMap('map', @findCoordinates(), [y, x], z)
    else
      @initializeMap('map', @findCoordinates())

    # Upload photo
    new AjaxUpload 'upload-photo'
      action: '/photos'
      name: 'photo[attachment]'
      data:
        #property_id: property.id
        authenticity_token: $("meta[name='csrf-token']").attr("content")
      responseType: 'json'
      onSubmit: (file, extension) ->
        $('#upload-photo').hide()
        $('#upload-photo-progress').show()
        $('.alert-error').remove()
      onComplete: (file, response) =>
        if response.errors?
          $('#upload-photo').show()
          $('#upload-photo-progress').hide()
          errors = for key, message of response.errors
            message
          $('#upload-photo-progress').after("<div class=\"alert alert-error\">Image #{errors[0]}</div>")
        else
          $("input[name=#{property.id}].image_id").val(response['_id']).change()
          $("input[name=#{property.id}].image").val(response['banner_url']).change()

          $('#upload-photo-progress').hide()
          $('#remove-photo').show()
          $('#upload-photo-thumbnail').html("<img src='#{response.thumbnail_url}' />").show()

  index: ->
    @view = new BlueCarbon.Views.Validations.IndexView(validations: @validations)
    $("#validations").html(@view.render().el)

  show: (id) ->
    validation = @validations.get(id)

    @view = new BlueCarbon.Views.Validations.ShowView(model: validation, areas: @areas)
    $("#validations").html(@view.render().el)

    # Map
    @initializeMap('map', JSON.parse(validation.get('coordinates')))

  edit: (id) ->
    validation = @validations.get(id)

    @view = new BlueCarbon.Views.Validations.EditView(model: validation, areas: @areas)
    $("#validations").html(@view.render().el)

    # Map
    @initializeMap('map', @findCoordinates())

  initializeMap: (map_id, coordinates, center = [24.5, 54], zoom = 9) ->
    baseMap = L.tileLayer('http://tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/997/256/{z}/{x}/{y}.png', {maxZoom: 18})
    baseSatellite = L.tileLayer('http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png', {maxZoom: 18})

    map = L.map map_id,
      center: center
      zoom: zoom
      layers: [baseSatellite]

    # Action draw a polygon
    $('#draw-a-polygon .btn').click (e) =>
      $(e.target).toggleClass('btn-inverse btn-primary')

      @polygonDraw = new L.Polygon.Draw(map, {shapeOptions: {color: '#bdd455'}}) unless @polygonDraw?

      if $(e.target).hasClass('active')
        @polygonDraw.disable()
      else
        @polygonDraw.enable()

    # Layers
    baseMaps =
      'Map': baseMap
      'Satellite': baseSatellite

    overlayMaps =
      'Mangroves': L.tileLayer('https://carbon-tool.cartodb.com/tiles/bc_mangrove/{z}/{x}/{y}.png?sql=SELECT * FROM bc_mangrove WHERE toggle = true AND (action <> \'delete\' OR action IS NULL)').addTo(map)
      'Seagrass': L.tileLayer('https://carbon-tool.cartodb.com/tiles/bc_seagrass/{z}/{x}/{y}.png?sql=SELECT * FROM bc_seagrass WHERE toggle = true AND (action <> \'delete\' OR action IS NULL)').addTo(map)
      'Sabkha': L.tileLayer('https://carbon-tool.cartodb.com/tiles/bc_sabkha/{z}/{x}/{y}.png?sql=SELECT * FROM bc_sabkha WHERE toggle = true AND (action <> \'delete\' OR action IS NULL)').addTo(map)
      'Salt marshes': L.tileLayer('https://carbon-tool.cartodb.com/tiles/bc_salt_marsh/{z}/{x}/{y}.png?sql=SELECT * FROM bc_salt_marsh WHERE toggle = true AND (action <> \'delete\' OR action IS NULL)').addTo(map)

    L.control.layers(baseMaps, overlayMaps).addTo(map)

    drawnItems = new L.LayerGroup()

    if coordinates
      latLngCoordinates = _.map(coordinates, (arr) -> [arr[1], arr[0]])
      initialPolygon = new L.polygon(latLngCoordinates)
      bounds = initialPolygon.getBounds()
      drawnItems.addLayer(initialPolygon)
      map.fitBounds(bounds)

      # Show view: new nearby validation
      $('#new-nearby-validation').attr('href', "#/new/#{map.getBoundsZoom(bounds)}/#{bounds.getCenter().lat}/#{bounds.getCenter().lng}")

    @editableMap(map, drawnItems) if $('#coordinates').length > 0

    map.addLayer(drawnItems)

  editableMap: (map, drawnItems) ->
    map.on 'draw:poly-created', (e) =>
      latLngs = e.poly.getLatLngs()

      $('#coordinates').val(@latLngsToString(e.poly.getLatLngs())).trigger('change')
      drawnItems.clearLayers()
      drawnItems.addLayer(e.poly)

      $('#draw-a-polygon .btn').toggleClass('btn-inverse active btn-primary')

      $('#draw-a-polygon').addClass('hidden')
      $('#habitat-and-action').removeClass('hidden')

  findCoordinates: ->
    try
      return JSON.parse($('#coordinates').val()) if $('#coordinates').length > 0
    false

  latLngsToString: (latLngs) ->
    "[#{_.map(latLngs, (ll) -> "[#{ll.lng},#{ll.lat}]")}]"
