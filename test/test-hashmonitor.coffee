HashMonitor = require('../lib/hashmonitor').HashMonitor

exports["Basic distributions parse + calculate properly"] = (assert, done) ->

  # Parse a bunch of lines.
  monitor = new HashMonitor()
  monitor.parse("zippy #foo=0 #bar=1")
  monitor.parse("zippy #foo=2 #bar=2")
  monitor.parse("zippy #foo=-1 #bar=3")
  monitor.parse("zippy #foo=3 #bar=4")

  # Since the monitor runs asynchronously, we wait for the next event tick
  # to see the results.
  process.nextTick ->

    stats = monitor.calculate()

    assert.equals(stats.foo?, true, "expected to have metrics for #foo")
    assert.equals(stats.foo.count, 4)
    assert.equals(stats.foo.mean, 1)
    assert.equals(stats.foo.min, -1)
    assert.equals(stats.foo.max, 3)
    assert.equals(stats.foo.x99, 3)
    assert.equals(stats.foo.x90, 3)
    assert.equals(stats.foo.median, 2)
    assert.equals(stats.foo.x10, -1)
    assert.equals(stats.foo.x01, -1)
    assert.equals(stats.foo.stddev, 1.5811388300841898)

    assert.equals(stats.bar?, true, "expected to have metrics for #bar")
    assert.equals(stats.bar.count, 4)
    assert.equals(stats.bar.mean, 2.5)
    assert.equals(stats.bar.min, 1)
    assert.equals(stats.bar.max, 4)
    assert.equals(stats.bar.x99, 4)
    assert.equals(stats.bar.x90, 4)
    assert.equals(stats.bar.median, 3)
    assert.equals(stats.bar.x10, 1)
    assert.equals(stats.bar.x01, 1)
    assert.equals(stats.bar.stddev, 1.1180339887498949)

    done()

exports["Invalid hashtags are skipped"] = (assert, done) ->

  # Parse a bunch of lines.
  monitor = new HashMonitor()
  monitor.parse("zippy #foo=0 #bar=1 #1foo=999")
  monitor.parse("zippy #foo=2 #bar=2 #foo-1 #bar.zip=2")
  monitor.parse("zippy #foo=-1 #bar=3")
  monitor.parse("zippy #foo=3 #bar=4")

  # Since the monitor runs asynchronously, we wait for the next event tick
  # to see the results.
  process.nextTick ->

    stats = monitor.calculate()

    # Make sure none of the bogus hashtags made it into the calculations.
    for own key in stats
      assert.ok(key is 'foo' or key is 'bar')

    assert.equals(stats.foo?, true, "expected to have metrics for #foo")
    assert.equals(stats.foo.count, 4)
    assert.equals(stats.foo.mean, 1)
    assert.equals(stats.foo.min, -1)
    assert.equals(stats.foo.max, 3)
    assert.equals(stats.foo.x99, 3)
    assert.equals(stats.foo.x90, 3)
    assert.equals(stats.foo.median, 2)
    assert.equals(stats.foo.x10, -1)
    assert.equals(stats.foo.x01, -1)
    assert.equals(stats.foo.stddev, 1.5811388300841898)

    assert.equals(stats.bar?, true, "expected to have metrics for #bar")
    assert.equals(stats.bar.count, 4)
    assert.equals(stats.bar.mean, 2.5)
    assert.equals(stats.bar.min, 1)
    assert.equals(stats.bar.max, 4)
    assert.equals(stats.bar.x99, 4)
    assert.equals(stats.bar.x90, 4)
    assert.equals(stats.bar.median, 3)
    assert.equals(stats.bar.x10, 1)
    assert.equals(stats.bar.x01, 1)
    assert.equals(stats.bar.stddev, 1.1180339887498949)

    done()

exports["Can detect hashtags at the end of the line"] = (assert, done) ->

  # Parse a bunch of lines.
  monitor = new HashMonitor()
  monitor.parse("zippy #foo")
  monitor.parse("fuzzy #foo")

  # Since the monitor runs asynchronously, we wait for the next event tick
  # to see the results.
  process.nextTick ->

    stats = monitor.calculate()

    assert.equals(stats.foo?, true, "expected to have metrics for #foo")
    assert.equals(stats.foo.count, 2)

    done()

# Map CommonJS async test functions to the signature required by nodeunit.
maptest = (description) ->
  cjstest = exports[description]
  exports[description] = (test) ->
    cjstest(test, -> test.done())
for own description of exports
  maptest(description)