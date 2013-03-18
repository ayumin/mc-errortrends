async      = require("async")
coffee     = require("coffee-script")
express    = require("express")
log        = require("./lib/logger").init("mc.errortrends")
redis      = require("redis-url").connect(process.env.OPENREDIS_URL)
salesforce = require("node-salesforce")

delay = (ms, cb) -> setTimeout  cb, ms
every = (ms, cb) -> setInterval cb, ms

express.logger.format "method",     (req, res) -> req.method.toLowerCase()
express.logger.format "url",        (req, res) -> req.url.replace('"', "&quot")
express.logger.format "user-agent", (req, res) -> (req.headers["user-agent"] || "").replace('"', "")

app = express()

app.disable "x-powered-by"

app.use express.logger
  buffer: false
  format: "ns=\"mc.errortrends\" measure=\"http.:method\" source=\":url\" status=\":status\" elapsed=\":response-time\" from=\":remote-addr\" agent=\":user-agent\""
app.use express.cookieParser()
app.use express.bodyParser()
#app.use express.basicAuth (user, pass, cb) -> cb(null, pass)
app.use app.router
app.use (err, req, res, next) -> res.send 500, (if err.message? then err.message else err)

force = (username, password, cb) ->
  sf = new salesforce.Connection()
  sf.login username, password, (err, user) -> cb err, sf

crm = (query, cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.SALESFORCE_USERNAME, process.env.SALESFORCE_PASSWORD, (err, sub) ->
    sf.query query, cb

chatter = (message, cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.SALESFORCE_USERNAME, process.env.SALESFORCE_PASSWORD, (err, sub) ->
    body =
      messageSegments: [
        type: "Text"
        text: message
      ]
    sf._request
      method: "POST"
      url: sf.urls.rest.base + "/chatter/feeds/record/#{process.env.CHATTER_GROUP_ID}/feed-items"
      body: JSON.stringify(body:body)
      headers:
        "Content-Type": "application/json"
      (err, data) ->
        console.log "err", err
        console.log "data", data
        cb() if cb

alert_chatter = () ->
  redis.setnx "chatter.lock", "locked", (err, success) ->
    unless success is 1
      console.log "already locked"
      return
    redis.expire "chatter.lock", 600, (err, success) ->
      if success is 1
        chatter "posting"

cols = (name, cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.SALESFORCE_USERNAME, process.env.SALESFORCE_PASSWORD, (err, sub) ->
    sf.sobject(name).describe (err, meta) ->
      console.log field.name for field in meta.fields
      cb()

app.get "/check", (req, res) ->
  crm "SELECT Id,Type,CreatedDate FROM Case", (err, rows) ->
    console.log "err", err
    cases_by_type = rows.records.reduce (ax, c) ->
      created = Date.parse(c.CreatedDate)
      if created > ((new Date()).getTime() - parseInt(process.env.CASE_TIME_THRESHOLD || "300")*1000)
        ax[c.Type] ||= []
        ax[c.Type].push(c)
      ax
    ,{}
    if (cases_by_type["Electrical"] || []).length > parseInt(process.env.CASE_COUNT_THRESHOLD || "5")
      alert_chatter()
    res.render "cases.jade", cases_by_type:cases_by_type

app.listen (process.env.PORT || 5000)
