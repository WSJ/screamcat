# Description:
#   Check whether team members are available
#
# Commands:
#   hubot is {username} available to help me?
#

module.exports = (robot) ->
  robot.respond /Is (.*)? available(?: to help)?\??/i, (msg) ->
    if (msg.match[1].toLowerCase() == "aendrew")
      msg.send "No."
    else
      msg.send "Check with Pat or Nick."
