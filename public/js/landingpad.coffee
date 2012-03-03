$ ->

  ##
  ## MailChimp Tooltip
  if $('#mailchimp-export').length
    $('#mailchimp-export').tooltip
      placement: 'bottom'

  ##
  ## Display Signup
  $("#info .btn-info").click ->
    $("#signup").fadeIn()

  ##
  ## Validation + save contact details
  $("#signup button").click (e) ->
    that = $(this)
    e.preventDefault()
    if $("#inputIcon").val().length < 1
      $("#signup .control-group").addClass "error"
      $("#signup .help").addClass "error"
      return
    $.ajax
      type: "post"
      url: "/subscribe"
      data: $("#subscribe").serialize()
      datatype: "json"
      success: (data) ->
        $("#signup").prepend "<div class='alert alert-success'><a class='close' data-dismiss='alert'>×</a>Thank you! We'll keep you posted.</div>"  if $("#signup .alert-success").length is 0
        $("#signup input, #signup button").attr "disabled", true
        options =
          show: true
          keyboard: true

        setTimeout (->
          $("#social").modal options
        ), 2000

      error: (data) ->
        $("#signup").prepend "<div class='alert alert-error'><a class='close' data-dismiss='alert'>×</a>Ooops! Something messed up, try again.</div>"  if $("#signup .alert-error").length is 0

  ##
  ## Show/hide password in the config
  $('#show-pwd').hover ->
    $(this).prev().html($(this).prev().data('pwd'))
    $(this).text('Hide')
  , ->
    $(this).prev().html('*******')
    $(this).text('Show')

  ##
  ## Editable config
  $('.editable').prepend('<i></i>')
  $('.editable').hover ->
    $(this).find('i').addClass('icon-edit')
  , ->
    $(this).find('i').removeClass('icon-edit')

  $('.editable').on 'click', ->
    editable $(this)

  editable = (el) ->
    if !el.data('edit')
      oldValue = el.find('.editZone').html()#.replace /"/g, """
      newValue = "<form class='form-inline'>"
      newValue += "<input type='hidden' class='oldValue' value='#{oldValue}' />"
      newValue += "<input type='text' class='span7 newValue' name='#{el.data('name')}' value='#{oldValue}' />"
      newValue += "<input class='btn btn-primary save' type='button' value='Save' /><input class='btn discard' type='button' value='Discard' />"
      newValue += "</form>"
      el.html('').html newValue
      el.data('edit', true)

      $('.btn.save').on 'click', ->
        saveEdit $(this).closest('td')

      $('.btn.discard').on 'click', ->
        discardEdit $(this).closest('td')

  discardEdit = (el) ->
    oldValue = el.find('.oldValue').val()
    newValue = "<i></i>"
    newValue += "<div class='editZone'>#{oldValue}</div>"
    el.html('').html newValue

  saveEdit = (el) ->
    $.ajax
      accepts: "application/json"
      username: "#{$('body').data('hk_api_key')}"
      type: 'PUT'
      contentType: 'text/json'
      data: "{\"#{el.data('name')}\":\"#{el.find('.newValue').val()}\"}"
      dataType: 'json'
      url: "https://api.heroku.com/apps/#{$('body').data('hk_app_name')}/config_vars"
      success: ->
        console.log 'SUCCESS'
      error: (xhr, text, e) ->
        console.log xhr
        console.log text
        console.log e
