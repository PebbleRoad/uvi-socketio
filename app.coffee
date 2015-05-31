express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'

router = express.Router()

app = express()

server = require('http').createServer app
io = require('socket.io').listen server

# index = require('./routes/index')

server.listen(process.env.PORT || 3000)

# view engine setup
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
app.set 'view options', { pretty: true }

app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: true }
app.use express.static path.join(__dirname, 'public')

# GET home page..
router.get '/', (req, res) ->
  console.log 'in GET /'
  # io.emit 'data:update', 'ryan'
  res.render 'index'

router.post '/submit_data', (req, res) ->

  data = { uvi: req.body.uvi }

  io.emit 'data:update', data
  
  res.send { success: true }

app.use router

# catch 404 and forward to error handler
app.use (req, res, next)->
  err = new Error 'Not Found'
  err.status = 404
  next err

# error handlers
# development error handler will print stacktrace
if app.get('env') is 'development'
  app.use (err, req, res, next)->
    res.status err.status || 500
    res.render 'error', { message: err.message, error: err }
  app.set 'title', 'Real-time Ultraviolet Index Monitor'
  app.locals.pretty = true

# production error handler no stacktraces leaked to user
app.use (err, req, res, next)->
  res.status(err.status || 500)
  res.render 'error', {
    message: err.message,
    error: {}
  }

io.sockets.on 'connection', (socket)->

  # on connect..
  console.log 'socket connection made..'
  # socket.emit 'onconnect'
  socket.on 'msg', (msg) ->
    console.log 'message:', msg

  socket.emit 'onconnect'
