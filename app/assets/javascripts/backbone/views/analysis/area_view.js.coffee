BlueCarbon.Views.Analysis ||= {}

class BlueCarbon.Views.Analysis.AreaView extends Backbone.View
  template: JST["backbone/templates/analysis/area"]

  events:
    'click .btn-add-polygon': 'toggleDrawing'
    'click #delete-area': 'deleteArea'

  initialize: (options) ->
    @area = options.area

  deleteArea: ->

  toggleDrawing: (event) ->
    $el = $(event.target)

    if @polygonView?
      @removeNewPolygonView()
    else
      @polygonView = window.pica.currentWorkspace.currentArea.drawNewPolygonView(() =>
        @removeNewPolygonView()
        @render()
      )

  removeNewPolygonView: ->
    if @polygonView?
      @polygonView.close()
      delete @polygonView

  close: () ->
    @removeNewPolygonView()

  render: =>
    $(@el).html(@template(area: @area))

    return @
