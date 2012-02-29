$ ->
  $("#info .btn-info").click ->
    $("#signup").fadeIn()

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