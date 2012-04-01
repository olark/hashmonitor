class Distribution

  constructor: (values) ->
    @values = values
    @sortedValues = @values.slice(0)
    @sortedValues.sort()

  count: ->
    return @values.length

  sum: ->
    unless @sumValue?
      @sumValue = 0
      for own value in @values
        @sumValue += value
    return @sumValue

  mean: ->
    return @meanValue or= @sum() / @count()

  variance: ->
    unless @varianceValue?
      mean = @mean()
      sumOfsquaredDiffsFromMean = 0
      for value in @values
        sumOfsquaredDiffsFromMean += Math.pow(value - mean, 2)
      @varianceValue = sumOfsquaredDiffsFromMean / @count()
    return @varianceValue

  stddev: ->
    return @stddevValue or= Math.sqrt(@variance())

  percentile: (percentile) ->
    indexOfPercentile = Math.floor((percentile / 100) * @sortedValues.length)
    return @sortedValues[indexOfPercentile]

  min: ->
    return @sortedValues[0]

  max: ->
    return @sortedValues.slice(-1)[0]

exports.Distribution = Distribution