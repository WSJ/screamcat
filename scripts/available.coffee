# Description:
#   Check whether team members are available
#
# Commands:
#   hubot is {username} available to help me?
#

module.exports = (robot) ->
  robot.respond /Is Aendrew available (?:to help)?\?$/i, (msg) ->
    msg.send "No."

  robot.respond /^Is (?!aendrew)(.*) available (?:to help)?\?$/i, (msg) ->
    msg.send "Check with Nick or Pat."
    

