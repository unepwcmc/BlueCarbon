BlueCarbon.Views.Validations ||= {}

class BlueCarbon.Views.Validations.NewView extends Backbone.View
  template: JST["backbone/templates/validations/new"]

  events:
    "submit #new-validation": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()
    @areas = options.areas

    @model.bind "change:errors", (model, errors) =>
      if errors?
        $("form").prepend("<div class='alert alert-error'>Oh snap! Change a few things up and try submitting again.</div>")

        _.each @model.get('errors'), (errors, name) ->
          if name == 'action'
            $("form #control-group-action").after("<div id='action-error' class='control-group error'><span class='help-block error'>Action #{errors[0]}</span></div>")
          else if name == 'coordinates'
            $("#map").after("<div id='map-error' class='control-group error'><span class='help-block error'>Coordinates #{errors[0]}</span></div>")
          else
            $("form [name=#{name}]").parents('.control-group').addClass('error').find('label').append("<span class=\"error\"> #{errors[0]}</span>")

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")
    $("form .alert, #map-error, #action-error").remove()
    $('form .control-group').removeClass('error').find('label span.error').remove()

    @collection.create(@model.toJSON(),
      success: (validation) =>
        @model = validation
        window.location.hash = "/#{@model.id}"

      error: (validation, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template({validation: @model.toJSON(), areas: @areas }))

    this.$("form").backboneLink(@model)

    # Action btn-group
    this.$(".btn-group button").click (e) ->
      $("#action").val($(e.target).data('action')).trigger('change')

    return this
