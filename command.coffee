colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'
moment   = require 'moment'

packageJSON = require './package.json'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['iso', 'i']
  type: 'bool'
  env: 'WTD_ISO'
  help: 'Format output in 8601 ISO format'
}, {
  names: ['utc', 'u']
  type: 'bool'
  env: 'WTD_UTC'
  help: 'Format output in utc'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {@dateStr, @iso, @utc} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(process.argv)
    dateStr = _.first options._args

    if options.help
      console.log @usage parser.help({includeEnv: true})
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    dateStr = moment().format() if _.isEmpty dateStr

    return {dateStr, iso: options.iso, utc: options.utc}

  run: =>
    @dateStr = parseInt @dateStr if new RegExp(/^[0-9]+$/).test @dateStr

    date = moment(@dateStr)
    date = date.utc() if @utc

    output = date.toString()
    output = date.format() if @iso

    console.log output
    process.exit 0

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  usage: (optionsStr) =>
    """
    USAGE: what-the-date [OPTIONS] [date-str]

    DESCRIPTION:
      converts any date into human readable format. Defaults to now if no date-string is provided

    OPTIONS:
    #{optionsStr}
    """

module.exports = Command
