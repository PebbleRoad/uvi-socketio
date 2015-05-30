$ ->
  console.log 'ready..'

  # Foundation JavaScript - documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation()

  socket = io()

  socket.emit 'msg', 'hello'

  socket.on 'data:update', (data) ->
    console.log 'in:', data
    $('.uvi-number').html data.uvi

  socket.on 'onconnect', () ->
    console.log 'connected..'