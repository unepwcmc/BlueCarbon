initializeMap = () ->
  new Map().map

initializePica = (map) ->
  window.pica = new Pica.Application(
    magpieUrl: "http://magpie.unep-wcmc.org"
    projectId: 4
    map: map
  )

  window.pica.newWorkspace()

  window.router = new Backbone.Routers.AnalysisRouter()
  Backbone.history.start()

invertLocaleOnPermalink = (permalink) ->
  currentLocale = polyglot.locale()
  if currentLocale == "ar"
    locale = "en"
  else
    locale = "ar"
  permalink.replace "/#{currentLocale}/", "/#{locale}/"

setupTranslationLink = ->
  $("#language > a").on "click", (e) ->
    if window.pica.currentWorkspace.currentArea.get("id")
      e.stopPropagation()
      e.preventDefault()
      permalink = invertLocaleOnPermalink $(".permalink :text").val()
      window.location.href = permalink

$(document).ready ->
  map = initializeMap() if $('#map_analysis').length > 0
  initializePica(map) if map?
  setupTranslationLink()
