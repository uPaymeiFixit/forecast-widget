apiKey: 'f24accee826e147ee895c96f69db3ab2' # put your forcast.io api key inside the quotes here

refreshFrequency: false

refreshFrequencyWithBlackjackAndHookers: 1200000
lat: 33.8706763 #other options are auto
lon: -117.865775 #other options are auto
units: "us" #us, si, ca, uk, auto

style: """
    bottom: 15%
    left: 20px
    font-family: Helvetica Neue
    color: #fff

    @font-face
        font-family Weather
        src url(pretty-weather.widget/icons.svg) format('svg')

    .icon
        font-family: Weather
        font-size: 40px
        text-anchor: middle
        alignment-baseline: middle

    .temp
        font-size: 20px
        text-anchor: middle
        alignment-baseline: baseline

    .outline
        fill: none
        stroke: #fff
        stroke-width: 0.5

    .icon-bg
        fill: rgba(#fff, 0.95)

    .summary
        text-align: center
        border-top: 1px solid #fff
        padding: 12px 0 0 0
        margin-top: -20px
        font-size: 14px
        max-width: 200px
        line-height: 1.4

    .date, .location
        fill: #fff
        stroke: #fff
        stroke-width: 1px
        font-size: 12px
        text-anchor: middle

    .date
        fill: #ccc
        stroke: #ccc

    .date.mask
        stroke: #999
        stroke-width: 5px

    .weather-icon
        width: 50px
        height: 50px
        background-size:cover;

    .weather-icon.big
        width: 100px
        height: 100px

    #temp
        width: 100px
        height: 100px
        font-size: 50px

    .day-text
        text-transform: uppercase

    .temp-range
        position: relative
        margin-top: 15px
        height: 100px

    .temp-range .bar
        position: absolute
        width: 20px
        background-color: white
        border-radius: 20px

    .temp-range .bar::before
        content: attr(data-content-high)
        position: absolute
        top: -19px

    .temp-range .bar::after
        content: attr(data-content-low)
        position: absolute
        bottom: -19px;
"""

command: ""

render: (o) -> """
 <div style="display:flex; flex-direction:row;">
    <div id="current-weather" style="display:flex; flex-direction:column;">
        <div style="display:flex; flex-direction:row;">
            <div id="icon" class="weather-icon big"></div>
            <div style="display:flex; flex-direction:column;">
                <div id="temp"></div>
                <div id="temp-direction"></div>
            </div>
        </div>
        <div style="display:flex; flex-direction:column;">
            <div id="summary"></div>
            <div id="wind"></div>
        </div>
    </div>
    <div style="display:flex; flex-direction:row;">
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

        $('#temp').text(Math.round(current_temp) + "º")
        $('#summary').text(output.currently.summary)

        wind_speed = Math.round output.currently.windSpeed
        wind_speed_units = @unit_labels[@units || "us"].speed
        wind_bearing = @bearing output.currently.windBearing
        $('#wind').text("Wind: #{wind_speed} #{wind_speed_units} (#{wind_bearing})")

        $('#icon').css("background-image", "url(forecast.widget/icons/#{output.currently.icon}.png)")


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
            $('#day' + day).find('.weather-icon').css("background-image", "url(forecast.widget/icons/#{output.daily.data[day].icon}.png)")
            day_high = Math.round output.daily.data[day].temperatureMax
            day_low = Math.round output.daily.data[day].temperatureMin
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




map: (x, in_min, in_max, out_min, out_max) ->
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;



bearing: (bearing) ->
    direction_index = Math.round(bearing / 45)
    return ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"][direction_index]

    # data  = JSON.parse(output)
    # today = data.daily?.data[0]
    #
    # return unless today?
    # date  = @getDate today.time
    #
    # $(domEl).find('.temp').prop 'textContent', Math.round(today.temperatureMax)+'°'
    # $(domEl).find('.summary').text today.summary
    # $(domEl).find('.icon')[0]?.textContent = @getIcon(today)
    # $(domEl).find('.date').prop('textContent',@dayMapping[date.getDay()])


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
