# Description:
#   Monitors given interactives for analytics and uptime. Needs refactoring.
#
# Dependencies:
#   cron
#   jsdom
#
# Commands:
#   hubot watch {url} ({nickname})
#   hubot check {url or nickname}
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
    dataset = robot.brain.get "watchedUrls"
    dataset = if dataset then dataset else []
    existing = dataset.filter (value) ->
      return value.url is url
    if existing.length is 0
      msg.reply "Okay! Now watching " + returnName(item) + "!"
      jsdom.env(
        url
        ["http://code.jquery.com/jquery.js"]
        (errors, window) ->
          strings = []
          if typeof window.ga is "undefined"
            strings.push ":crying_cat_face: OMG, YOU FORGOT ANALYTICS!"
            strings.push " *HOW COULD YOU?!?!?!?!?!*"
            if msg.message.user.name.match /aendrew/ig
              strings.push "AND, LIKE — C'MON, MAN! I EXPECT BETTER FROM YOU!"
          else
            strings.push "Seems to have Google Analytics! :+1: :shipit: :boom:"

          msg.reply strings.join("\n")
          window.close()
          return
      )
      dataset.push item
      robot.brain.set "watchedUrls", dataset
      return

    else
      msg.reply "I'm already watching that url!"
      return

  robot.respond /check ([^\s]*)/i, (msg) ->
    handle = if msg.match[1] then msg.match[1] else false
    if handle and handle.match(/http(?:s)?\:\/\//ig)
      url = msg.match[1]
    else
      dataset = robot.brain.get "watchedUrls"
      dataset = if dataset then dataset else []
      existing = dataset.filter (value) ->
        return value.url is url

      if existing.length > 0 and typeof existing[0].url not "undefined"
        url = existing[0].url
      else
        msg.reply "That URL doesn't seem to be tracked by me..."
        return

    try
      http.get url, (res) ->
        if res.statusCode is 404
          msg.reply ":crying_cat_face:Errmahgerrd! "
          +  returnName(item) + " is MISSING!"
          return

        else
          jsdom.env(
            url
            ["http://code.jquery.com/jquery.js"]
            (errors, window) ->
              console.log 'in done'
              if typeof window.ga is "undefined"
                msg.reply ":rage: GRAHHH! "
                + returnName(item) + " is missing Google Analytics! FFS!"
              else
                msg.reply "Looks good to me! :+1:"
              window.close()
              return
          )
          return
    catch e
      msg.reply ":crying_cat_face:Errmahgerrd! "
      + "an exception was thrown when checking " + returnName(item)
      + "! Maybe take a look?"
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
                url: item.url,
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
