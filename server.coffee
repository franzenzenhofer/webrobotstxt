express = require 'express'
util = require 'util'
parseUri = require 'parseUri'
robotsTxt = require 'robotstxt'


robotstxturi = 'http://www.example.com/robots.txt'
totestA = []


app = express.createServer()
app.use express.static __dirname + '/public'
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

#listen on /
app.get '/', (req, res) ->
  msg = 
    error: []
    note: []
    results: []
  
  console.log req.query
  
  #parse robots.txt and find out if it is a valid robots.txt uri
  rt = parseUri req.query.robotstxturl if req.query?.robotstxturl? 
  if rt?.path? and rt.path isnt ''
    console.log rt
    rtl = rt.path.toLowerCase().trim()
    
    #its not a valid robots.txt uri
    if rtl isnt '/robots.txt'
      console.log 'not a valid robots.txt url'
      msg.error.push 'given robots.txt url is not a valid robots.txt url (must end in /robots.txt)'
    
    #its a valid robots.txt uri
    else 
      #trim the robots.txt uri string
      robotstxturi = req.query.robotstxturl.trim()
      
      #prepare the test uris
      if req.query.testurls?
        totestA = req.query.testurls.split "\n"
        preParseTestUrl = (x) -> 
          x = x.trim()
          if x[0]? and x[0].toLowerCase() isnt 'h' and x[0] isnt '/'
            x = ['/', x].join ''
          xu = parseUri(x)
          if xu.path? and xu.path isnt ''
            xu.path
          else
            null
        totestA = (preParseTestUrl x for x in totestA)
        tempA = []
        (x) -> if x then tempA.push x for x in totestA  
        totestA = tempA
        console.log 'totestA'
        console.log totestA
      else
        msg.error.push 'no test uris given'
      
      #create a new gate keeper
      rt = robotsTxt robotstxturi
      
      #when the gate keeper is ready
      rt.on 'ready', (gate_keeper) ->
        console.log gate_keeper
        testdata = (gate_keeper.why y for y in totestA)
        console.log testdata
        console.log testdata[0].rules
  else
    msg.note.push 'please ente a valid robots.txt url and some test urls'
  
  console.log msg
    
  
  
  res.render 'index.jade', {
  title: 'Robots.Txt Checker'
  description:null
  msg:msg
  robotstxturi: robotstxturi
  totestA: totestA
  }
app.listen(3003);
