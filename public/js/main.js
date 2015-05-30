$(function() {
  var socket;
  console.log('ready..');
  $(document).foundation();
  socket = io();
  socket.emit('msg', 'hello');
  socket.on('data:update', function(data) {
    console.log('in:', data);
    return $('.uvi-number').html(data.uvi);
  });
  return socket.on('onconnect', function() {
    return console.log('connected..');
  });
});
