$ ->
  console.log 'ready..'

  # Foundation JavaScript - documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation()

  $('#uv-index').fitText(0.3)

  data =
    labels: ['Current Index']
    datasets: [
      {
        label: 'first set'
        fillColor: 'rgba(120,220,220,0.5)'
        strokeColor: 'rgba(220,220,220,0.8)'
        highlightFill: 'rgba(220,220,220,0.75)'
        highlightStroke: 'rgba(220,220,220,1)'
        data: [0]
      }
    ]

  ctx = document.getElementById('indexChart').getContext('2d')

  opts = 
    scaleBeginAtZero: true
    barShowStroke: false
    barDatasetSpacing: 5
    scaleOverride: true
    scaleSteps: 12
    scaleStepWidth: 1
    scaleStartValue: 0
    responsive: true

  chart = new Chart(ctx).Bar(data, opts)

  # val = 2.5
  # setTimeout( ->
  #   chart.datasets[0].bars[0].value = val
  #   chart.datasets[0].bars[0].fillColor = getColour(val)
  #   chart.update();
  # , 1500)

  # time = moment('2015-06-01T01:01:43.075Z', moment.ISO_8601).format('MMM Do YYYY | HH:mm:ss')
  # console.log time

  socket = io()

  socket.emit 'msg', 'hello'

  socket.on 'data:update', (data) ->
    console.log 'in:', data
    if data.mac? then $('.panel span').html(data.mac)
    $('.uv-index').html data.uvi
    chart.datasets[0].bars[0].value = parseFloat(data.uvi)
    chart.datasets[0].bars[0].fillColor = getColour(data.uvi)
    chart.update();

  socket.on 'onconnect', () ->
    console.log 'connected..'

  getColour = (uvi) ->
    uvi = parseFloat(uvi)
    if (uvi >= 11)
      # purple
      return 'rgba(112,47,160,0.8)'
    else if (uvi >= 8)
      # red
      return 'rgba(255,15,0,0.8)'
    else if (uvi >= 6)
      # orange
      return 'rgba(230,110,26,0.8)'
    else if (uvi >= 3)
      # yellow
      return 'rgba(255,255,0,0.8)'
    else
      # green
      return 'rgba(56,255,0,0.8)'
