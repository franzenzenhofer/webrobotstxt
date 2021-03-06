express = require 'express'
util = require 'util'
parseUri = require './parseuri.js'
#robotsTxt = require '../robotstxt/index.coffee'
robotsTxt = require 'robotstxt'


robotstxturi_default = 'http://www.google.com/robots.txt'
useragent_default = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html - fake - a harmless robotstxt checker)"
#totestA_default = ['/']


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
  robotstxturi = robotstxturi_default
  totestA = []
  useragent = useragent_default
  everythingok = false
  #console.log req.query

  #prepare the date

  #IS THE ROBOTS.TXT a VALID URL
  #parse robots.txt and find out if it is a valid robots.txt uri
  rt = parseUri req.query.robotstxturl if req.query?.robotstxturl?
  if rt?.path? and rt.path isnt ''
    #console.log rt
    rtl = rt.path.toLowerCase().trim()

    #its not a valid robots.txt uri
    if rtl isnt '/robots.txt'
      #console.log 'not a valid robots.txt url'
      msg.error.push 'given robots.txt url is not a valid robots.txt url (must end in /robots.txt)'
    else
      #trim the robots.txt uri string
      robotstxturi = req.query.robotstxturl.trim()
  else
    msg.notes.push 'please enter a valid robots.txt URL'
  #IS THE ROBOTS.TXT a VALID URL - END

  #PREPARE THE TEST URLs
  #prepare the test uris
  if req.query.testurls?
    #console.log "req.query.testurls"
    #console.log req.query
    #console.log req.query.testurls
    if Array.isArray req.query.testurls
      req.query.testurls = req.query.testurls[0]
    totestA = req.query.testurls.split /\s/

    #get rid of all unvalid values (i.e.:blanks)
    preParseTestUrls = (xA) ->
      preParseTestUrl = (x) ->
        x = x.trim()
        if x[0]? and (x[0] isnt '/')
          if x.substr(0,4) isnt 'http'
            x = ['/', x].join ''
        xu = parseUri(x)
        if xu.path? and xu.path isnt ''
          if xu.query? and xu.query isnt ''
            r = xu.path+'?'+xu.query
          else
            r = xu.path
            #workaround to get clean URLs and URLs that submitted with an ? at the end
            if x.substr(x.length-1) is '?'
              r = r+'?'
            else
              r
#        if r? isnt '/'
#          r = ['/', r].join ''
        else
          null

      xA = (preParseTestUrl x for x in xA)
      tempA = []
      (tempA.push(x) if x?) for x in xA
      return tempA

    totestA = preParseTestUrls totestA
    if totestA.length is 0
      msg.notes.push 'please enter some test URLs'
    #console.log 'totestA'
    #console.log totestA
  else
    msg.notes.push 'please enter some test URLs'
  #PREPARE THE TEST URLS - END

  #USER AGENT
  if req?.query?.useragent?
    useragent = req.query.useragent

  #console.log 'USERAGENT ' + useragent

  if useragent and Array.isArray useragent
    useragent = useragent[0]

  if useragent
    useragent = useragent.trim()

   #USER AGENT END
  #its a valid robots.txt uri
  if robotstxturi and totestA.length isnt 0
    #create a new gate keeper
    rt = robotsTxt robotstxturi, useragent

    rt.on 'crawled', (txt) ->
      txtA = txt.split("\n")


    #when the gate keeper is ready
    rt.on 'ready', (gate_keeper) ->
      #console.log gate_keeper
      #console.log "totestA just before it gets tested"
      #console.log totestA
      msg.results = (gate_keeper.why y for y in totestA)
      msg.notes.push "#{msg.results.length} URLs successfully tested"
      #console.log msg.results
      #console.log msg.results[0].rules
      #console.log msg
      #console.log 'RENDER WITH DATA'
      #console.log msg
      #console.log totestA
      #console.log msg
      indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA, useragent, txtA)

    rt.on 'error', (e) ->
      #console.log 'RENDER WITH DATA BUT NODE.JS ERROR'
      msg.error.push e.toString()
      indexRender(res, 'Error', 'a description', msg, robotstxturi, totestA, useragent, txtA)

  else

    #console.log '#RENDER WITHOUT VALID DATA'
    until totestA?[0]?
      totestA[0]='/'
    indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA,useragent)

  #console.log msg



app.listen(process.env.PORT || 3000);