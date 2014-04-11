# Description:
#   Queries Google Calendar to see whether a user is free or busy.
#
#   Based on:
#   [lazerwalker/lazerwalker-hubot-scripts/scripts/gcal.coffee](https://github.com/lazerwalker/lazerwalker-hubot-scripts/blob/master/scripts/gcal.coffee)
#
# Dependencies:
#   googleapis
#   moment
#
# Configuration:
#   GOOGLE_CLIENT_ID: Client ID for your Google API app
#   GOOGLE_CLIENT_SECRET: Client secret for your Google API app
#   GOOGLE_REDIRECT_URI: Redirect URL for your Google API app
#   GOOGLE_ACCESS_TOKEN: Access token for your Google user account
#   GOOGLE_REFRESH_TOKEN: Refresh token for your Google user account
#   SLACK_API_TOKEN: Access token for querying Slack usernames. (Future use.)
#
#   To get these:
#     1. Register for an app at https://code.google.com/apis/console/
#     2. Generate a client ID for web applications.
#     3. That will give your client ID, secret, and redirect URL.
#     4. In your web browser, go to
#        https://accounts.google.com/o/oauth2/auth?access_type=offline&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar&response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}
#        and follow the login flow
#     5. When complete, it will hit your redirect URL with a ?code={CODE} query param.
#     6. Send a POST request with the following settings:
#        POST https://accounts.google.com/o/oauth2/token HTTP/1.1
#        Content-Type: application/x-www-form-urlencoded
#        Body:
#            code={CODE}& 4/BI5p9xhDg4fdvhKmtxcNYv8uZ_85.8qSXlnxWowMeYKs_1NgQtmVlOph3igI
#            client_id={CLIENT_ID}&
#            client_secret={CLIENT_SECRET}&
#            redirect_uri={REDIRECT_URI}&
#            grant_type=authorization_code
#     7. The JSON response returned will include your access and refresh tokens
#
# Commands:
#   hubot is {Slack username or Email} busy at 12:00 pm?
#
# ToDo:
#   + Add more ability to use either "busy" or its inverse "available".
#   + Add ranges for time slots.
#
# Author:
#   aendrew, based on gcal.coffee by lazerwalker

module.exports = (robot) ->
  robot.respond /Is (.*?) (free|busy)(?: at ([\d:\sapm.]*)?)?[?]?/i, (msg) ->
    handleResponse = (err, client) ->
      if (err)
        msg.send "Google Calendar error! #{err}"
        return
      else if (client.calendars) # Parse through busy events...
        user = Object.keys(client.calendars)[0];
        if (client.calendars[user].busy.length > 0)
          if (not is_inverted)
            strings = ["#{user} is busy from:"]
            client.calendars[user].busy
              .forEach (value) ->
                strings.push(moment(value.start).format("h:mm a") + " until " + moment(value.end).format("h:mm a"))
          else # Inverted format.
            strings = "#{user} is busy from: "
            client.calendars[user].busy
              .forEach (value) ->
                strings.push(moment(value.start).format("h:mm a") + " until " + moment(value.end).format("h:mm a"))

          # Finally, send the response...
          msg.send strings.join("\n")

        else # No events found.
          if (not is_inverted)
            msg.send "Nope, #{user} is available."
          else # Inverted format.
            msg.send "Yes, #{user} is free."

    # End helper functions, start main procedure

    username = msg.match[1]
    is_inverted = if msg.match[2] == "free" then true else false

    # Parse timestamps...
    moment = require('moment')
    if msg.match[3] # Timestamp supplied, parse it...
      if msg.match[3].match(/[ap]\.?m\.?/i) # Handle 12/24h...
        startTime = moment(msg.match[3], "hh:mm a")
      else
        startTime = moment(msg.match[3], "HH:mm")
      if not startTime.isValid()
        msg.send "Not a valid time!"
        return

      endTime = startTime.clone().add('hours', 1)

    else # No timestamp supplied, use now.
      startTime = moment() # i.e., "now".
      endTime = startTime.clone().add('hours', 1)

    # Parse username...
    if username.charAt(0) == "@"
      httpsync = require('httpsync')
      req = httpsync.get("https://slack.com/api/users.list?token=" + process.env.SLACK_API_TOKEN)
      res = req.end()
      console.log(req)
      user = res.members.map() ->
        return this.name == username.slice(1)
      email = user.profile.email
      console.dir(user)

    else
      email = username

    details =
      items: [
        id: email
      ],
      timeMax: endTime.format(), # DateTime in RFC3339 format (I.e., "yyyy-mm-ddThh:mm:ssZ")
      timeMin: startTime.format() # Ditto.
    console.dir(details)
    googleapis = require('googleapis')

    clientID = process.env.GOOGLE_CLIENT_ID
    secret = process.env.GOOGLE_CLIENT_SECRET
    redirectURI = process.env.GOOGLE_REDIRECT_URI
    oauth2Client = new googleapis.OAuth2Client(clientID, secret, redirectURI)
    oauth2Client.credentials =
      access_token: process.env.GOOGLE_ACCESS_TOKEN
      refresh_token: process.env.GOOGLE_REFRESH_TOKEN

    googleapis.discover('calendar', 'v3')
      .execute (err, client) ->
        handleResponse(err, client)
        client.calendar.freebusy.query(details)
          .withAuthClient(oauth2Client)
          .execute (err, client) ->
            handleResponse(err, client)
