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

enterReplies = ['Words do not express my excitement.', 'Welcome to the party!']
leaveReplies = [':\'(', ':scream_cat: Nooooooooo!']


module.exports = (robot) ->

  robot.respond /poor showing/i, (msg) ->
    msg.send "Sorry. I'm only as good as my input. :("

  robot.hear /(.*)/, (msg) ->
    postlength = msg.match[1].length
    if (postlength > 400)
      msg.send "Cool story, bro!"

  robot.enter (msg) ->
    msg.send msg.random enterReplies
  robot.leave (msg) ->
    msg.send msg.random leaveReplies