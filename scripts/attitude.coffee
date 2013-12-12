# Description:
#   Adds some pre-programmed behaviours to Hubot. Randomly acts random.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot poor showing -- Responds with "Sorry. :("
#   <post over 400 characters> -- Responds with "Cool story, bro." (Doesn't seem to work at present)

enterReplies = ["Words do not express my excitement.", "Welcome to the party!"]
leaveReplies = [":'(", ":scream_cat: Nooooooooo! Anything but that!"]
sadtrombones = ["Sorry. I'm only as good as my input. :(", "Oh, come on. I've only made #{fails} mistakes!", "Well, win some, lose some..."]

module.exports = (robot) ->

  robot.respond /(poor showing|fail|godammit|ffs)/ig, (msg) ->
    fails = robot.brain.get('hubotFails') * 1 or 0 
    robot.brain.set 'hubotFails', fails+1
    msg.send msg.random sadtrombones

  robot.hear /.+/i, (msg) ->
    if (msg.match[0].length > 400)
      msg.send "Cool story, bro!"

  robot.enter (msg) ->
    msg.send msg.random enterReplies

  robot.leave (msg) ->
    msg.send msg.random leaveReplies