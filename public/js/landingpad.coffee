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

        $("#social").modal options

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
    new Edit($(this)).editable()

  ##
  ## Edit Class
  class Edit
    constructor: (el) ->
      @that = el

    editable: =>
      if @that.data('editing') != true
        oldValue = @that.find('.editZone').html()
        newValue = "<form class='form-inline'>"
        newValue += "<input type='hidden' class='oldValue' value='#{oldValue}' />"
        newValue += "<input type='text' class='span7 newValue' name='#{@that.data('name')}' value='#{oldValue}' />"
        newValue += "<input class='btn btn-primary save' type='button' value='Save' /><input class='btn discard' type='button' value='Discard' />"
        newValue += "</form>"
        @that.html('').html newValue
        @that.data('editing', true)
        @that.removeClass('editable')
        $('.btn.save').on 'click', ->
          new Edit($(this).closest('td')).saveEdit()
        $('.btn.discard').on 'click', ->
          new Edit($(this).closest('td')).discardEdit()
      else
        @that.removeData('editing')

    discardEdit: =>
      oldValue = @that.find('.oldValue').val()
      newValue = "<i></i>"
      newValue += "<div class='editZone'>#{oldValue}</div>"
      @that.html('').html newValue
      @that.addClass 'editable'

    saveEdit: =>
      $.ajax
        url: "https://api.heroku.com/apps/landingpadrb/config_vars"
        type: "PUT"
        data: "working=yes"
        password: "0d12fa51371432c129b640122ed5585877ee801f"
        headers:
          Accept: "application/json"

        success: (data, textStatus, response) ->
          console.log "Success"
          console.log data
          console.log textStatus
          console.log response

        error: (data, textStatus, response) ->
          console.log "Error"
          console.log data
          console.log textStatus
          console.log response
      # $.ajax
      #   type: 'PUT'
      #   url: '/config/update'
      #   # data: "#{@that.data('name')}=#{@that.find('.newValue').val()}"
      #   data: "working=yes"
      #   headers:
      #       "Accept": "application/json"
      #   # beforeSend: (xhr) ->
      #   #   xhr.setRequestHeader("Accept", "application/json")
      #   success: ->
      #     console.log 'SUCCESS'
      #   error: ->
      #     console.log 'ERROR'
      @that.addClass 'editable'


