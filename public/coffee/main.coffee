$ ->
  console.log 'ready..'

  # Foundation JavaScript - documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation()

  $('#uv-index').fitText(0.3)

  data =
    labels: ['Now']
    datasets: [
      {
        label: 'first set'
        fillColor: 'rgba(120,220,220,0.5)'
        strokeColor: 'rgba(220,220,220,0.8)'
        highlightFill: 'rgba(220,220,220,0.75)'
        highlightStroke: 'rgba(220,220,220,1)'
        data: [5]
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

  # setTimeout( ->
  #   chart.datasets[0].bars[0].value = 9
  #   chart.datasets[0].bars[0].fillColor = 'green'
  #   chart.update();
  # , 2500)

  socket = io()

  socket.emit 'msg', 'hello'

  socket.on 'data:update', (data) ->
    console.log 'in:', data
    $('.uv-index').html data.uvi
    chart.datasets[0].bars[0].value = parseFloat(data.uvi)
    # chart.datasets[0].bars[0].fillColor = 'green'
    chart.update();

  socket.on 'onconnect', () ->
    console.log 'connected..'