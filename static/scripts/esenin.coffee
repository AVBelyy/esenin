songs = []
animee = {}
$lines = null

resize = ->
    w_width = ($ window).width()

    for $line in $lines
        p_width = $line.first().width()

        $line.each ->
            @style.left = (w_width - p_width)/2 + "px"


unroll = ($line, timing, cur, cb) ->
    if cur == timing.length then return cb()

    [delay, width] = timing[cur]
    $elem = $line.children(":eq(#{cur})")

    animee =
        time: Date.now()/1000
        args: arguments
        $elem: $elem

    $elem.animate
        width: width
      ,
        duration: 1000*delay
        queue: false
        step: () -> $elem.css "overflow", "visible"
        complete: () -> unroll $line, timing, cur+1, cb

display = (lines, flag, cb) ->
    lines = lines.filter (x) -> x
    [timing, flag] = [[], Math.min lines.length-1, flag]
    if flag then lines = lines.reverse()

    # remove previous text
    ($ "#karaoke .line .text").remove()

    # draw two subtitle lines
    for line, i in lines
        for cmd in line
            if typeof cmd == "number"
                cmd = ["", cmd]
            [text, delay] = cmd
            $p = ($ "<p>").addClass("text").html (if text then "&nbsp;#{text}" else "")
            if !text
                $p.css "display", "none"
            $p.appendTo $lines[i][0]
            if i == flag
                timing.push [delay, $p.width()]
                $p.clone().addClass("shadow").appendTo $lines[i][1]

    # make it smooth
    resize()
    unroll $($lines[flag][1]), timing, 0, cb


$$ = (song) ->
    audio = null
    lyrics = []
    handlers = []

    API =
        header: (info) ->
            audio = new buzz.sound "/static/audio/#{info.file}",
                formats: [ "aac", "ogg" ]

            audio.bind "play", ->
                position = audio.getDuration() - audio.getTime()

                change_position = ->
                    setTimeout ->
                        if not audio.isPaused()
                            ($ ".playing .length").html "-#{buzz.toTimer --position}"
                            change_position()
                    , 1000
                change_position()

        wait: (delay) ->
            do (hid = handlers.length + 1) ->
                handlers.push ->
                    setTimeout ->
                        handlers[hid]()
                    , 1000*delay

        line: (commands) ->
            do (hid = handlers.length + 1, lid = lyrics.length) ->
                handlers.push ->
                    display [lyrics[lid], lyrics[lid + 1]], lid%2, ->
                        handlers[hid]()
            lyrics.push commands

    song.call API

    # set the last handler
    handlers.push ->
        for $line in $lines
            $line.fadeOut 2000

    songs.push
        audio: audio
        handlers: handlers


$ ->
    $karaoke = $ "#karaoke"
    $lines = [$karaoke.find(".first.line"), $karaoke.find(".second.line")]
    playing = false

    ($ "#songs tr").click ->
        $song = $(this)
        {audio, handlers} = songs[($ "#songs tr").index $song]

        if not playing
            audio.play()
            ($ "body").animate
                top: -$(this).offset().top+($ document).scrollTop()
            , 500, ->
                ($ "body").css "overflow", "hidden"
                $song.addClass("playing")
                setTimeout ->
                    handlers[0]()
                , 0
                playing = true
                $karaoke.toggle()
                ($song.find ".play")
                    .removeClass("play")
                    .addClass("pause")
        else
                if audio.isPaused()
                    if animee.args
                        # resume the animation
                        animee.args[1][animee.args[2]][0] -= animee.time
                        unroll.apply this, animee.args
                    audio.play()
                else
                    if animee.$elem
                        # pause the animation
                        animee.time = Date.now()/1000 - animee.time
                        animee.$elem.stop()
                    audio.pause()
                if ($song.find ".play").length
                   ($song.find ".play")
                        .removeClass("play")
                        .addClass("pause")
                else
                   ($song.find ".pause")
                        .removeClass("pause")
                        .addClass("play")

    ($ window).on "resize", ->
        resize()
