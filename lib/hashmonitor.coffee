#!/usr/bin/env coffee

Distribution = require('./stats').Distribution

HASHTAG_REGEX = /\#([a-zA-Z][\w\d_]+)(?:(?:[\s'"]+|$)|\=(\-?\d+(?:\.\d+)?))/g

class HashMonitor

  constructor: ->
    @pendingData = {}

  parse: (line) ->
    process.nextTick =>
      line.replace HASHTAG_REGEX, (match, metric, value) =>
        if value?
          @pendingData[metric] ||= []
          @pendingData[metric].push({'value': parseFloat(value)})
        else
          @pendingData[metric] ||= []
          @pendingData[metric].push({})

  reset: ->
    @pendingData = {}

  calculate: ->

    # Calculate the stats for each metric.
    stats = {}
    for own metric, metricEntries of @pendingData

      # For metrics that have values, we want to have a list of all the
      # valid values for those metrics.
      valueDist = new Distribution(m.value for m in metricEntries when m?.value?)

      # Build the final output stats for this metric.
      metricStats = stats[metric] = {}
      metricStats.count = metricEntries.length
      if valueDist.count()
        metricStats.mean = valueDist.mean()
        metricStats.stddev = valueDist.stddev()
        metricStats.x01 = valueDist.percentile(1)
        metricStats.x10 = valueDist.percentile(10)
        metricStats.median = valueDist.percentile(50)
        metricStats.x90 = valueDist.percentile(90)
        metricStats.x99 = valueDist.percentile(99)
        metricStats.min = valueDist.min()
        metricStats.max = valueDist.max()

    return stats

exports.HashMonitor = HashMonitor
