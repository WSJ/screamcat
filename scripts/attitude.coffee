# Description:
#   Adds some pre-programmed behaviours to Hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot poor showing -- Responds with "Sorry. :("
#   <post over 300 characters> -- Responds with "Cool story, bro."

module.exports = (robot) ->

  robot.respond /poor showing/i, (msg) ->
    msg.send "Sorry. I'm only as good as my input. :("

  robot.hear /.*/, (msg) ->
    if msg.length > 400
      msg.send "Cool story, bro!"
