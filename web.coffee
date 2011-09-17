parseUri = require 'parseUri'
robotsTxt = require '../robotstxt/index.js'

require('zappa') {robotsTxt} ->
  enable 'serve jquery'
  
  get '/': ->
    render 'index', layout: no
  
  at 'fetch robots': ->
    rt = robotsTxt
    
  at 'set robots': ->
    client.nickname = @nickname
  
  at 'test': ->
    io.sockets.emit 'said', nickname: client.nickname, text: @text
  
  client '/index.js': ->
    connect()

    at crawled: ->
      
    
    $().ready ->
      $('button').click ->
        emit 'said', text: $('#box').val()
        $('#box').val('').focus()
    
  view index: ->
    doctype 5
    html ->
      head ->
        title 'Robots.txt Parser'
        script src: '/socket.io/socket.io.js'
        script src: '/zappa/jquery.js'
        script src: '/zappa/zappa.js'
        script src: '/index.js'
      body ->
        div id: 'panel'
        input id: 'box'
        button 'Send'