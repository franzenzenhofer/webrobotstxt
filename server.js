(function() {
  var app, express, indexRender, parseUri, robotsTxt, robotstxturi, totestA, util;
  express = require('express');
  util = require('util');
  parseUri = require('parseUri');
  robotsTxt = require('robotstxt');
  robotstxturi = 'http://www.example.com/robots.txt';
  totestA = [];
  app = express.createServer();
  app.use(express.static(__dirname + '/public'));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  indexRender = function(res, title, des, msg, robotstxturi, totestA) {
    if (title == null) {
      title = 'Robots.Txt Checker';
    }
    if (des == null) {
      des = 'Crawl, parse and test Robots.txt Files';
    }
    return res.render('index.jade', {
      title: title,
      description: des,
      msg: msg,
      robotstxturi: robotstxturi,
      totestA: totestA
    });
  };
  app.get('/', function(req, res) {
    var msg, preParseTestUrls, rt, rtl, _ref;
    msg = {
      error: [],
      notes: [],
      results: []
    };
    if (((_ref = req.query) != null ? _ref.robotstxturl : void 0) != null) {
      rt = parseUri(req.query.robotstxturl);
    }
    if (((rt != null ? rt.path : void 0) != null) && rt.path !== '') {
      rtl = rt.path.toLowerCase().trim();
      if (rtl !== '/robots.txt') {
        return msg.error.push('given robots.txt url is not a valid robots.txt url (must end in /robots.txt)');
      } else {
        robotstxturi = req.query.robotstxturl.trim();
        if (req.query.testurls != null) {
          totestA = req.query.testurls.split("\n");
          preParseTestUrls = function(xA) {
            var preParseTestUrl, tempA, x, _i, _len;
            preParseTestUrl = function(x) {
              var xu;
              x = x.trim();
              if ((x[0] != null) && x[0].toLowerCase() !== 'h' && x[0] !== '/') {
                x = ['/', x].join('');
              }
              xu = parseUri(x);
              if ((xu.path != null) && xu.path !== '') {
                return xu.path;
              } else {
                return null;
              }
            };
            xA = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = xA.length; _i < _len; _i++) {
                x = xA[_i];
                _results.push(preParseTestUrl(x));
              }
              return _results;
            })();
            tempA = [];
            for (_i = 0, _len = xA.length; _i < _len; _i++) {
              x = xA[_i];
              if (x != null) {
                tempA.push(x);
              }
            }
            return tempA;
          };
          totestA = preParseTestUrls(totestA);
        } else {
          msg.error.push('no test uris given');
        }
        rt = robotsTxt(robotstxturi);
        return rt.on('ready', function(gate_keeper) {
          var y;
          msg.results = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = totestA.length; _i < _len; _i++) {
              y = totestA[_i];
              _results.push(gate_keeper.why(y));
            }
            return _results;
          })();
          msg.notes.push("" + msg.results.length + " URLs successfully tested");
          console.log('RENDER WITH DATA');
          console.log(msg);
          return indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA);
        });
      }
    } else {
      msg.notes.push('please ente a valid robots.txt url and some test urls');
      console.log('##########RENDER WITHOUT DATA');
      return indexRender(res, 'Robots.Txt Checker', 'a description', msg, robotstxturi, totestA);
    }
  });
  app.listen(3003);
}).call(this);
