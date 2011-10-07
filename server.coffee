fs = require 'fs'
express = require 'express'
app = express.createServer()
io = require('socket.io').listen app
exec = require('child_process').exec
jade = require 'jade'
stylus = require 'stylus'

posts = {}
topics = {}

compile = (str,path) ->
  return stylus(str).set('filename',path).set('compress',true)

setTopics = () ->
  for url of posts
    post = posts[url]
    if not topics[post.topic]
      topics[post.topic] = true

loadPosts = (callback) ->
  posts = require './posts.js'
  setTopics()
  callback()

app.configure ->
  app.set 'views', __dirname+'/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use stylus.middleware {src:__dirname+'/views', dest:__dirname+'/public', compile:compile}
  app.use express.logger {format:':date :remote-addr :method :status :url'}
  app.use express.static __dirname+'/public'
  app.use app.router

loadPosts () ->
  require('./controllers/blog')(app,jade,posts,topics)
  require('./controllers/admin')(app,jade,fs,exec,posts,topics,setTopics)
  app.listen 80
  require('./controllers/realtime')(io,jade,fs,posts,topics)
