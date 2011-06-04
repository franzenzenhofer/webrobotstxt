(function() {
  var app, express, parseUri, robotsTxt, util;
  express = require('express');
  util = require('util');
  parseUri = require('parseUri');
  robotsTxt = require('robotstxt');
  app = express.createServer();
  app.use(express.static(__dirname + '/public'));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.get('/', function(req, res) {
    var msg, rt, rtl, totestA, _ref;
    msg = {
      error: [],
      note: [],
      results: []
    };
    console.log(req.query);
    if (((_ref = req.query) != null ? _ref.robotstxturl : void 0) != null) {
      rt = parseUri(req.query.robotstxturl);
    }
    if (((rt != null ? rt.path : void 0) != null) && rt.path !== '') {
      console.log(rt);
      rtl = rt.path.toLowerCase().trim();
      if (rtl !== '/robots.txt') {
        console.log('not a valid robots.txt url');
        msg.error.push('given robots.txt url is not a valid robots.txt url (must end in /robots.txt)');
      } else {
        req.query.robotstxturl = req.query.robotstxturl.trim();
        if (req.query.testurls != null) {
          totestA = req.query.testurls.split("\n");
          totestA = (function(x) {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = totestA.length; _i < _len; _i++) {
              x = totestA[_i];
              _results.push(x.trim());
            }
            return _results;
          });
          console.log('totestA');
          console.log(totestA);
        } else {
          msg.error.push('no test uris given');
        }
        rt = robotsTxt(req.query.robotstxturl);
        rt.on('ready', function(gate_keeper) {
          return console.log(gate_keeper);
        });
      }
    } else {
      msg.note.push('please ente a valid robots.txt url and some test urls');
    }
    console.log(msg);
    return res.render('index.jade', {
      title: 'Robots.Txt Checker',
      description: null,
      msg: msg
    });
  });
  app.listen(3003);
}).call(this);
