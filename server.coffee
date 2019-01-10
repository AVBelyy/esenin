coffee          = require "coffee-script"
body_parser     = require "body-parser"
method_override = require "method-override"
logger          = require "morgan"
connect_coffee  = require "connect-coffee-script"
uglify          = require "uglify-js"

fs      = require "fs"
express = require "express"
stylus  = require "stylus"


# parse all songs

songs = []

# define a parser
global.$$ = (song) ->
    API =
        header: (info) ->
            # parse seconds count to user-friendly "m:ss" string
            seconds = info.length
            info.length = "#{Math.floor(seconds/60)}:#{if seconds%60 < 10 then '0' else ''}#{seconds%60}"
            # store song info in songs list
            songs.push info
        # need to be implemented on the client-side
        line: () -> 0
        wait: () -> 0

    song.call API

# read song files
# and compile them all to a single JS file

files = fs.readdirSync "songs/"
js = ""
for file in files
    js += coffee.compile (fs.readFileSync "./songs/#{file}", "utf8"), bare: true
    require("./songs/#{file}")

fs.writeFileSync "#{__dirname}/static/scripts/songs.js",
                 (uglify.minify js).code

# configure express

app = express()

app.set "views", "#{__dirname}/views"
app.set "view engine", "pug"

app.use body_parser.urlencoded extended: true
app.use body_parser.json()
app.use method_override()
app.use logger "dev"
app.use connect_coffee
            src: __dirname
            bare: true
            compile: (str, options) ->
                js = coffee.compile(str, options)
                (uglify.minify js).code
app.use stylus.middleware
            src:  __dirname
            dest: __dirname
            compile: (str, path) ->
                stylus(str)
                    .define("url", stylus.url( paths: [__dirname] ))
                    .set("filename", path)
                    .set("compress", true)
app.use "/static", express.static "#{__dirname}/static"


app.get "/", (req, res) ->
    res.render "index",
        songs: songs

port = 2109
console.log "Listening on port #{port}"
app.listen port
