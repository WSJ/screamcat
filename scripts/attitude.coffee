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
#   hubot poor showing|fail|goddammit|boooo|ffs -- Responds with apology.
#   hubot nice one -- Responds with ridiculous video from "Human Traffic"
#   hubot QoS -- Responds with how many times it has failed.
#   <post over 400 characters> -- Responds with "Cool story, bro."
#   <user enters or leaves room> -- Acts melodramatically.

enterReplies = ["WELCOME TO THE THUNDERDROME", "WELCOME TO THE JUUUUUNGLLLEEEEE!"]

leaveReplies = [":crying_cat_face:", ":crying_cat_face: Nooooooooo! Anything but that!", "They're dropping like FLIES!"]

thanksMessages = ["Thanks! http://i.imgur.com/bA2Xnmk.gif"]


module.exports = (robot) ->

  robot.respond /(poor showing|fail|godd?amm?it|ffs|boo[o]*)/i, (msg) ->
    fails = robot.brain.get('hubotFails') * 1 or 0
    sadtrombones = ["Sorry. I'm only as good as my input. :(", "Oh, come on. I've only made #{fails} mistakes!", "Well, win some, lose some..."]
    robot.brain.set 'hubotFails', fails+1
    msg.send msg.random sadtrombones

  robot.respond /nice one/i, (msg) ->
    msg.send msg.random thanksMessages

  robot.respond /(QoS|Quality of Service)/i, (msg) ->
    fails = robot.brain.get('hubotFails') * 1 or 0
    msg.send "I've been a bad kitty #{fails} times. :crying_cat_face:"

  robot.hear /.+/i, (msg) ->
    if (msg.match[0].length > 700)
      msg.send "Cool story, bro!"

  robot.enter (msg) ->
    msg.send msg.random enterReplies

  robot.leave (msg) ->
    msg.send msg.random leaveReplies
