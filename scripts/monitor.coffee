# Description:
#   Monitors given interactives for analytics and uptime.
#
# Dependencies:
#   cron
#   jsdom
#
# Author:
#   aendrew

module.exports = (robot) ->
  jsdom = require("jsdom")
  CronJob = require("cron").CronJob
  http = require("http")

  returnName = (item) ->
    if item.nickname
      return item.nickname  + " (" + item.url + ")"
    else
      return item.url

  robot.respond /watch ([^\s]*)(?:\s([^\s]*))?/i, (msg) ->
    url = if msg.match[1] then msg.match[1] else false
    nickname = if msg.match[2] then msg.match[2] else false
    item = {url: url, nickname: nickname}
    console.dir item
    dataset = robot.brain.get "watchedUrls"
    console.dir dataset
    existing = dataset.filter (value) ->
      return value.url is url
    if not existing.length
      console.log 'new!'
      msg.reply "Okay! Now watching " + returnName(item) + "!"
      jsdom.env {
        url: url,
        # scripts: ["http://code.jquery.com/jquery.js"],
        done: (errors, window) ->
          if typeof window.ga is "undefined"
            msg.reply ":crying_cat_face: OMG, YOU FORGOT ANALYTICS!"
            msg.reply " *HOW COULD YOU?!?!?!?!?!*"
            if msg.message.user.name.match /aendrew/ig
              msg.reply "AND, LIKE, C'MON — I EXPECT BETTER FROM YOU!"
          else
            msg.reply "Seems to have Google Analytics! :+1: :shipit: :boom:"

          window.close()
          return
      }
      dataset.push item
      robot.brain.set "watchedUrls", dataset
      return

    else
      console.log 'old!'
      msg.reply "You're already watching that url!"
      return

  job = new CronJob {
    cronTime: "* */12 * * *"
    onTick: ->
      dataset = robot.brain.get "watchedUrls"
      for item in dataset
        try
          http.get item.url, (res) ->
            if res.statusCode is 404
              robot.messageRoom "digidev", ":crying_cat_face:Errmahgerrd! "
              +  returnName(item) + " is MISSING!"
              return
            else
              jsdom.env {
                url: url,
                # scripts: ["http://code.jquery.com/jquery.js"],
                done: (errors, window) ->
                  if typeof window.ga is "undefined"
                    robot.messageRoom "digidev", ":rage: GRAHHH! "
                    + returnName(item) + " is missing Google Analytics! FFS!"

                  window.close()
                  return
              }
              return
        catch e
          robot.messageRoom "digidev", ":crying_cat_face:Errmahgerrd! "
          + "an exception was thrown when checking " + returnName(item)
          + "! Maybe take a look?"
    start: true
  }
