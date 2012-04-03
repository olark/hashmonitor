HashMonitor = require('./hashmonitor').HashMonitor
HttpAccessLogParser = require('./inputs/httpaccess').HttpAccessLogParser

DEFAULT_MILLISECONDS_FOR_SINGLE_STATS_WINDOW = 30 * 1000

run = ->

  # Initialize the HashMonitor collector that will contain all the
  # parsed log lines and calculated statistics.
  monitor = new HashMonitor()

  # Keep a list of pre-parsers
  preParsers = []

  # Parse most HTTP log formats into plaintext strings.  This should
  # be safe for non-HTTP log lines, but probably should make this configurable
  # instead configurat
  if '--parse-http-access' in process.argv
    preParsers.push(new HttpAccessLogParser())

  # Listen for data on standard input (default input for log lines).
  # TODO: add other input options
  process.stdin.resume()
  process.stdin.setEncoding('utf8')
  process.stdin.on 'data', (line) ->
    for parser in preParsers
      line = parser.parse(line)
    monitor.parse(line)

  # Periodically output the statistics for this monitor as JSON dictionaries
  # so that other scripts can send these stats into other systems.
  setInterval(
    ->
      # TODO: add other output options
      console.log(monitor.calculate())
      monitor.reset()
    , DEFAULT_MILLISECONDS_FOR_SINGLE_STATS_WINDOW
    )

exports.run = run