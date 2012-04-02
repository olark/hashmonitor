HttpAccessLogParser = require('../lib/inputs/httpaccess').HttpAccessLogParser

exports["Can parse simple HTTP access log example"] = (assert, done) ->

  parser = new HttpAccessLogParser()
  line1 = parser.parse("1333391497193 '/?hashmonitor=hello%20world%20%23foo'")
  line2 = parser.parse("1333394599154 '/?hashmonitor=hello%20%23bar%3D5%20%23zip'")

  assert.equals(line1, "hello world #foo")
  assert.equals(line2, "hello #bar=5 #zip")

  done()

exports["Can parse other HTTP access logs with different query argument endings"] = (assert, done) ->

  parser = new HttpAccessLogParser()
  line1 = parser.parse("1333391497193 \"/?hashmonitor=hello%20world%20%23foo\"")
  line2 = parser.parse("1333394599154 /?hashmonitor=hello%20%23bar%3D5%20%23zip")
  line3 = parser.parse("1333391497193 \"/?hashmonitor=hello%20world%20%23foo2&zip=123\"")
  line4 = parser.parse("1333391497193 \"/?blah=999&hashmonitor=hello%20world%20%23foo3&zip=123\"")

  assert.equals(line1, "hello world #foo")
  assert.equals(line2, "hello #bar=5 #zip")
  assert.equals(line3, "hello world #foo2")
  assert.equals(line4, "hello world #foo3")

  done()

exports["Can parse HTTP access logs with non-'hashmonitor' querystring arguments"] = (assert, done) ->

  parser = new HttpAccessLogParser('myfunkykey')
  line1 = parser.parse("1333391497193 '/?myfunkykey=hello%20world%20%23foo'")
  line2 = parser.parse("1333394599154 '/?myfunkykey=hello%20%23bar%3D5%20%23zip'")

  assert.equals(line1, "hello world #foo")
  assert.equals(line2, "hello #bar=5 #zip")

  done()

# Map CommonJS async test functions to the signature required by nodeunit.
maptest = (description) ->
  cjstest = exports[description]
  exports[description] = (test) ->
    cjstest(test, -> test.done())
for own description of exports
  maptest(description)