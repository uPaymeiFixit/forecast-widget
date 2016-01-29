apiKey: 'f24accee826e147ee895c96f69db3ab2' # put your forcast.io api key inside the quotes here

refreshFrequency: false

refreshFrequencyWithBlackjackAndHookers: 120000
lat: 33.8706763 #other options are auto
lon: -117.865775 #other options are auto
units: "us" #us, si, ca, uk, auto

style: """
    top: 550px
    left: 10px
    width: 500px
    font-family: Roboto
    color: white
    text-align: center

    @font-face
        font-family Weather
        src: url(forecast.widget/icons.svg) format('svg')

    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Thin.ttf) format('truetype')
        font-weight: 100
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-ThinItalic.ttf) format('truetype')
        font-weight: 100
        font-style: italic
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Light.ttf) format('truetype')
        font-weight: 300
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-LightItalic.ttf) format('truetype')
        font-weight: 300
        font-style: italic
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Regular.ttf) format('truetype')
        font-weight: 400
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-RegularItalic.ttf) format('truetype')
        font-weight: 400
        font-style: italic
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Medium.ttf) format('truetype')
        font-weight: 500
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-MediumItalic.ttf) format('truetype')
        font-weight: 500
        font-style: italic
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Bold.ttf) format('truetype')
        font-weight: 700
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-BoldItalic.ttf) format('truetype')
        font-weight: 700
        font-style: italic
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-Black.ttf) format('truetype')
        font-weight: 900
        font-style: normal
    @font-face
        font-family: Roboto
        src: url(forecast.widget/fonts/Roboto-BlackItalic.ttf) format('truetype')
        font-weight: 900
        font-style: italic

    .fe_forecast
        opacity: 1
        -webkit-transition: opacity 0.5s

    .weather-icon
        width: 25px
        height: 25px
        background-size: cover

    .weather-icon.big
        width: 80px
        height: 80px

    .fe_temp
        width: 90px
        font-size: 50px
        font-weight: 700
        letter-spacing: -1px

    .fe_temp::after
        content: '°'

    .fe-temp-direction
        margin-top: -6px
        margin-right: 5px
        font-size: 13px
        text-align: center

    .days > div
        width: 38px
        -webkit-align-content: center
        align-content: center

    .days .weather-icon
        margin-left: auto;
        margin-right: auto;
        background: @color
        -webkit-mask-position: 0 0
        -webkit-mask-image: url()
        -webkit-mask-size: 25px 25px

    .day-text
        font-size: 12px
        font-weight: 500
        text-transform: uppercase

    .temp-range
        position: relative
        margin-top: 15px
        width: 100%
        height: 100px

    .temp-range .bar
        position: absolute
        /*margin-left: auto
        margin-right: auto*/
        left: 9px
        width: 20px
        background-color: @color
        border-radius: 20px
        -webkit-transition: top 0.5s, bottom 0.5s

    .temp-range .bar::before
        content: attr(data-content-high)
        position: absolute
        top: -14px
        left: 4px
        font-size: 11px
        font-weight: 300

    .temp-range .bar::after
        content: attr(data-content-low)
        position: absolute
        bottom: -15px
        left: 4px
        font-size: 11px
        font-weight: 300

    #fe_current_icon
        background: @color
        -webkit-mask-position: 0 0
        -webkit-mask-image: url()
        -webkit-mask-size: 80px 80px

    .fe_more_info
        margin-top: 5px

    .fe_currently .fe_summary
        font-size: 18px
        font-weight: bold

    .fe_currently .fe_wind
        font-size: 14px
        font-weight: 300

    .fe_currently:first-child
        margin-top: auto

    .fe_currently:last-child
        margin-bottom: auto

    .prepare-loading
        transition: opacity 0.5s

    .loading
        opacity: 0
"""

command: ""

render: (o) -> """
<link href="forecast.widget/style/dist/main.css" rel="stylesheet">

<div class="fe_forecast loading" style="display:flex; flex-direction:row;">

    <div class="fe_currently" id="current-weather" style="display:flex; flex-direction:column;">
        <!-- Top of Current Weather -->
        <div style="display:flex; flex-direction:row;">
            <div id="fe_current_icon" class="weather-icon big"></div>
            <div style="display:flex; flex-direction:column;">
                <div class="fe_temp"></div>
                <div class="fe-temp-direction" id="temp-direction"></div>
            </div>
        </div>
        <!-- Bottom of Current Weather -->
        <div class="fe_more_info" style="display:flex; flex-direction:column;">
            <div class="fe_summary"></div>
            <div class="fe_wind"></div>
        </div>
    </div>

    <div class="days" style="display:flex; flex-direction:row;">
        <div id="day0" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day1" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day2" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day3" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day4" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day5" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day6" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
        <div id="day7" style="display:flex; flex-direction:column;">
            <div class="day-text"></div>
            <div class="weather-icon"></div>
            <div class="temp-range">
                <div class="bar"></div>
            </div>
        </div>
    </div>
</div>
"""

svgNs: 'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'

calls: 0

afterRender: (domEl) ->

    ready = () =>
        @run(@command, ->)
        @refresh()
        setInterval =>
            @run(@command, ->)
            @refresh()
        , @refreshFrequencyWithBlackjackAndHookers

    if @lat == "auto" and @lon == "auto"
        geolocation.getCurrentPosition (e) =>
            coords     = e.position.coords
            [@lat, @lon] = [coords.latitude, coords.longitude]
            @command = @makeCommand(@apiKey, "#{@lat},#{@lon}", @units)
            ready()
    else
        @command = @makeCommand(@apiKey, "#{@lat},#{@lon}", @units)
        ready()


makeCommand: (apiKey, location, units) ->
    exclude = "minutely,alerts,flags"
    return "curl -sS 'https://api.forecast.io/forecast/#{apiKey}/#{location}?units=#{units}&exclude=#{exclude}'"

unit_labels:
    auto: speed: 'mph'
    us: speed: 'mph'
    si: speed: 'm/s'
    ca: speed: 'km/h'
    uk: speed: 'mph'

update: (output, domEl) ->
    if output? and output isnt ''
        output = JSON.parse output

        next_hour_temp = output.hourly.data[1].temperature # Next hour's temp
        current_temp = output.currently.temperature # Current temp

        if next_hour_temp > current_temp
            $('#temp-direction').text("and rising")
        else
            $('#temp-direction').text("and falling")

        $('.fe_temp').text(Math.round(current_temp))
        $('.fe_summary').text(output.currently.summary)

        wind_speed = Math.round output.currently.windSpeed
        wind_speed_units = @unit_labels[@units || "us"].speed
        wind_bearing = @bearing output.currently.windBearing
        $('.fe_wind').text("Wind: #{wind_speed} #{wind_speed_units} (#{wind_bearing})")

        @changeIcon($('#fe_current_icon'), output.currently.icon)

        tempMin = 1000
        tempMax = -1000

        for day of output.daily.data
            if (output.daily.data[day].temperatureMax > tempMax)
                tempMax = output.daily.data[day].temperatureMax
            if (output.daily.data[day].temperatureMin < tempMin)
                tempMin = output.daily.data[day].temperatureMin

        tempRange = tempMax - tempMin

        for day of output.daily.data
            if day is '0'
                $('#day' + day).find('.day-text').text('Today')
            else
                $('#day' + day).find('.day-text').text(@dayMapping[new Date(output.daily.data[day].time * 1000).getDay()])
            @changeIcon($('#day' + day).find('.weather-icon'), output.daily.data[day].icon)
            day_high = Math.round(output.daily.data[day].temperatureMax) + '°'
            day_low = Math.round(output.daily.data[day].temperatureMin) + '°'
            day_high_rel = @map output.daily.data[day].temperatureMax, tempMin, tempMax, 0, 1
            day_low_rel = @map output.daily.data[day].temperatureMin, tempMin, tempMax, 0, 1
            height = 100
            $("#day#{day}").find('.bar').attr('data-content-high', day_high);
            $("#day#{day}").find('.bar').attr('data-content-low', day_low);
            # window.getComputedStyle($("#day#{day}").find('.bar')[0], '::before').setProperty('content', day_high, 0);
            # window.getComputedStyle($("#day#{day}").find('.bar')[0], '::after').setProperty('content', day_low, 0);
            $("#day#{day}").find('.bar').css('top', height - (day_high_rel * height))
            $("#day#{day}").find('.bar').css('bottom', day_low_rel * height)
            # $("#day#{day}").find('.bar').text("#{day_high_rel} #{day_low_rel}")

        $('.fe_forecast').removeClass('loading')

map: (x, in_min, in_max, out_min, out_max) ->
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

changeIcon: (element, icon) ->
    if element.css('-webkit-mask-image') isnt "url(#{window.location.origin}/forecast.widget/icons/#{icon}.png)"
        if element.css('-webkit-mask-image') is "url(#{window.location.origin}/)"
            element.addClass('loading')
            element.addClass('prepare-loading')
            element.css('-webkit-mask-image', "url(forecast.widget/icons/#{icon}.png)")
            element.removeClass('loading')
            setTimeout =>
                element.removeClass('prepare-loading')
            , 500
        else
            element.addClass('prepare-loading')
            element.addClass('loading')
            setTimeout =>
                element.css('-webkit-mask-image', "url(forecast.widget/icons/#{icon}.png)")
                element.removeClass('loading')
                setTimeout =>
                    element.removeClass('prepare-loading')
                , 500
            , 500

bearing: (bearing) ->
    direction_index = Math.round(bearing / 45)
    return ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"][direction_index]

dayMapping:
  0: 'Sun'
  1: 'Mon'
  2: 'Tue'
  3: 'Wed'
  4: 'Thu'
  5: 'Fri'
  6: 'Sat'


# getIcon: (data) ->
#   return @iconMapping['unknown'] unless data
#
#   if data.icon.indexOf('cloudy') > -1
#     if data.cloudCover < 0.25
#       @iconMapping["clear-day"]
#     else if data.cloudCover < 0.5
#       @iconMapping["mostly-clear-day"]
#     else if data.cloudCover < 0.75
#       @iconMapping["partly-cloudy-day"]
#     else
#       @iconMapping["cloudy"]
#   else
#     @iconMapping[data.icon]

getDate: (utcTime) ->
  date  = new Date(0)
  date.setUTCSeconds(utcTime)
  date
