# We match HTTP access log lines with querystring `hashmonitor=<encoded_data>`
# by default, but this can be overridden in the HttpAccessLogParser constructor.
DEFAULT_QUERYSTRING_KEY = 'hashmonitor'

class HttpAccessLogParser

  constructor: (key) ->
    # We match all log lines against this pattern.
    key or= DEFAULT_QUERYSTRING_KEY
    @lineRegex = new RegExp("#{key}\\=([^\\s\\&\\?\\#\\'\\\"$]+)")

  parse: (line) ->
    # Make a best attempt to parse, but return the original line if
    # anything fails.
    matches = line.match(@lineRegex)
    if matches
      try
        return decodeURIComponent(matches[1])
      catch error
        console.warn(error)
        return line
    else
      return line

exports.HttpAccessLogParser = HttpAccessLogParser
