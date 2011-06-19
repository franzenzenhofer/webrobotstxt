express = require 'express'
util = require 'util'
parseUri = require 'parseUri'
robotsTxt = require '../robotstxt/index.js'
#robotsTxt = require 'robotstxt'


robotstxturi = 'http://www.example.com/robots.txt'
totestA = []
useragent = ''



app = express.createServer()
app.use express.static __dirname + '/public'
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'


indexRender = (res, title='Robots.Txt Checker', des='Crawl, parse and test Robots.txt Files', msg, robotstxturi, totestA, useragent, txtA) ->

  res.render 'index.jade', {
    title: title
    description: des
    msg:msg
    robotstxturi: robotstxturi
    totestA: totestA
    useragent:useragent
    txtA: txtA
  }



#listen on /
app.get '/', (req, res) ->
  msg = 
    error: []
    notes: []
    results: []
  
  txtA = []
  #console.log req.query
  
  #parse robots.txt and find out if it is a valid robots.txt uri
  rt = parseUri req.query.robotstxturl if req.query?.robotstxturl? 
  if rt?.path? and rt.path isnt ''
    #console.log rt
    rtl = rt.path.toLowerCase().trim()
    
    #its not a valid robots.txt uri
    if rtl isnt '/robots.txt'
      #console.log 'not a valid robots.txt url'
      msg.error.push 'given robots.txt url is not a valid robots.txt url (must end in /robots.txt)'
    
    #its a valid robots.txt uri
    else 
      #trim the robots.txt uri string
      robotstxturi = req.query.robotstxturl.trim()
      useragent = req.query.useragent.trim()
      
      #prepare the test uris
      if req.query.testurls?
        totestA = req.query.testurls.split "\n"
        
        #get rid of all unvalid values (i.e.:blanks)
        preParseTestUrls = (xA) ->
          preParseTestUrl = (x) -> 
            x = x.trim()
            if x[0]? and x[0].toLowerCase() isnt 'h' and x[0] isnt '/'
              x = ['/', x].join ''
            xu = parseUri(x)
            if xu.path? and xu.path isnt ''
              if xu.query? and xu.query isnt ''
                xu.path+'?'+xu.query
              else
                xu.path
            else
              null
          
          xA = (preParseTestUrl x for x in xA)
          tempA = []
          (tempA.push(x) if x?) for x in xA
          return tempA
        
        totestA = preParseTestUrls totestA 
        #console.log 'totestA'
        #console.log totestA
      else
        msg.error.push 'no test uris given'
      
      #create a new gate keeper
      rt = robotsTxt robotstxturi, useragent
      
      rt.on 'crawled', (txt) ->
        txtA = txt.split("\n")
        
      
      #when the gate keeper is ready
      rt.on 'ready', (gate_keeper) ->
        #console.log gate_keeper
        msg.results = (gate_keeper.why y for y in totestA)
        msg.notes.push "#{msg.results.length} URLs successfully tested"
        ##console.log msg.results
        #console.log msg.results[0].rules
        #console.log msg
        console.log 'RENDER WITH DATA'
        ##console.log msg
        console.log totestA
        indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA, useragent, txtA)
  else
    msg.notes.push 'please ente a valid robots.txt url and some test urls'
    console.log '##########RENDER WITHOUT DATA'
    indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA)
  
  ##console.log msg
    

  
app.listen(3003);