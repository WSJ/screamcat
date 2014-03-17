# Description:
#   Check whether team members are available
#
# Commands:
#   hubot is {username} available to help me?
#

module.exports = (robot) ->
  robot.respond /is Aendrew available (to help)?/i, (msg) ->
    msg.send "No."

  robot.respond /is (.*?) available (to help)?/i, (msg) ->
    msg.send "Check with Nick or Pat."
    

