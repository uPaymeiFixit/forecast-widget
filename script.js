module.exports = {

    // ################################# BEGIN SETTINGS #################################
    // To get your own API key, go to https://developer.forecast.io/                    #
    api_key: '<API_KEY>', // Put your Forcast.io api key inside the quotes here          #
    refresh_rate: 120000, // Time in milliseconds between refreshes                     #
    lat: 'auto', // Options are auto, or a valid latitude (auto doesn't always work)    #
    lon: 'auto', // Options are auto, or a valid longitude (auto doesn't always work)   #
    units: 'auto', // Options are us, si, ca, uk, auto                                  #
    onclick_link: 'http://www.wunderground.com', // Link to open when widget is clocked #
    // ################################## END SETTINGS ##################################

    command: '',
    refreshFrequency: false,

    // Runs once at the load of the script
    afterRender: function () {

        // A workaround to use scss instead of stylus
        var widget = $('#forecast-widget-index-js');
        for (var i = 0; i < document.styleSheets.length; i++) {
            if (document.styleSheets[i].ownerNode.nextElementSibling.id === 'forecast-widget-index-js') {
                for (var j in document.styleSheets[i].rules[0].style) {
                    if (typeof document.styleSheets[i].rules[0].style[j] === 'string' && document.styleSheets[i].rules[0].style[j] !== '') {
                        widget.css(j, document.styleSheets[i].rules[0].style[j]);
                    }
                }
                break;
            }
        }

        // Keeping a constant context through varying scopes
        var uber = this;

        // Show an error if no API key is set
        if (uber.api_key === 'API_KEY') {
            widget.html(uber.api_instructions);
            widget.css('text-shadow', '1px 1px 15px rgb(0, 0, 0)');
            widget.css('font-weight', 900);
            widget.css('font-size', '20px');
            return;
        }

        // Executes shell command (curl)
        var ready = function () {
            uber.run(uber.command, function () {});
            uber.refresh();
            setInterval(function () {
                uber.run(uber.command, function () {});
                uber.refresh();
            }, uber.refresh_rate);
        };

        // Gets the location and makes the shell command to send to forecast.io
        if (uber.lat == 'auto' && uber.lon == 'auto') {
            geolocation.getCurrentPosition(function (e) {
                uber.lat = e.position.coords.latitude;
                uber.lon = e.position.coords.longitude;
                uber.command = uber.makeCommand(uber.api_key, uber.lat + ',' + uber.lon, uber.units);
                ready();
            });
        } else {
            uber.command = uber.makeCommand(uber.api_key, uber.lat + ',' + uber.lon, uber.units);
            ready();
        }

        // Opens a specified link when the widget is clicked
        $('#forecast-widget-index-js').click(function () {
            uber.run('open ' + uber.onclick_link, function () {});
        });
    },

    // Makes the shell command to execute (curl)
    makeCommand: function (api_key, location, units) {
        var exclude = 'minutely,alerts,flags';
        return 'curl -sS "https://api.forecast.io/forecast/' + api_key + '/' + location + '?units=' + units + '&exclude=' + exclude + '"';
    },

    // Runs every <refresh_rate> milliseconds
    update: function (output) {
        // Make sure that we have valid JSON (first run is empty, no api key is Forbidden)
        if (output && output !== '' && output !== 'Forbidden\n') {
            output = JSON.parse(output);

            // Temperature direction (rising or falling)
            var next_hour_temp = output.hourly.data[1].temperature; // Next hour's temp
            var current_temp = output.currently.temperature; // Current temp
            if (next_hour_temp > current_temp) {
                $('#temp-direction').text('and rising');
            } else {
                $('#temp-direction').text('and falling');
            }

            // Temperature and summary
            $('.fe-temp').text(Math.round(current_temp));
            $('.fe-summary').text(output.currently.summary);

            // Wind speed and bearing
            var wind_speed = Math.round(output.currently.windSpeed);
            var wind_speed_units = this.unit_labels[this.units || 'us'].speed;
            var wind_bearing = this.bearing(output.currently.windBearing);
            $('.fe-wind').text('Wind: ' + wind_speed + ' ' + wind_speed_units + ' (' + wind_bearing + ')');

            // Icon
            this.changeIcon($('#fe-current-icon'), output.currently.icon);

            // TODO: Check if there is a output.weekly.high / low
            // Find the max and min temperatures for the week
            var temp_min_week = 1000;
            var temp_max_week = -1000;
            for (var day in output.daily.data) {
                if (output.daily.data[day].temperatureMax > temp_max_week) {
                    temp_max_week = output.daily.data[day].temperatureMax;
                }
                if (output.daily.data[day].temperatureMin < temp_min_week) {
                    temp_min_week = output.daily.data[day].temperatureMin;
                }
            }

            for (day in output.daily.data) {

                // Change current day's name
                if (day === '0') {
                    $('#day' + day).find('.day-text').text('Tod');
                } else {
                    $('#day' + day).find('.day-text').text(this.dayMapping[new Date(output.daily.data[day].time * 1000).getDay()]);
                }

                // Set day's weather icon
                this.changeIcon($('#day' + day).find('.weather-icon'), output.daily.data[day].icon);

                // Temperature bars
                var day_high = Math.round(output.daily.data[day].temperatureMax) + '°';
                var day_low = Math.round(output.daily.data[day].temperatureMin) + '°';
                var day_high_rel = this.map(output.daily.data[day].temperatureMax, temp_min_week, temp_max_week, 0, 1);
                var day_low_rel = this.map(output.daily.data[day].temperatureMin, temp_min_week, temp_max_week, 0, 1);
                var height = 100;
                $('#day' + day).find('.bar').attr('data-content-high', day_high);
                $('#day' + day).find('.bar').attr('data-content-low', day_low);
                $('#day' + day).find('.bar').css('top', height - (day_high_rel * height));
                $('#day' + day).find('.bar').css('bottom', day_low_rel * height);
            }
            // Makes the widget visible after it's loaded
            $('.fe-forecast').removeClass('loading');

        } else {
            // Show an error message if API key is invalid
            if (output === 'Forbidden\n') {
                var widget = $('#forecast-widget-index-js');
                widget.html(this.api_instructions);
                widget.css('text-shadow', '1px 1px 15px rgb(0, 0, 0)');
                widget.css('font-weight', 900);
                widget.css('font-size', '20px');
            }
        }
    },

    // Fades icons out and in (and handles loading them)
    changeIcon: function (element, icon) {
        if (element.css('-webkit-mask-image') !== 'url(' + window.location.origin + '/forecast.widget/icons/' + icon + '.png)') {
            if (element.css('-webkit-mask-image') === 'url(' + window.location.origin + '/)') {
                element.addClass('loading');
                element.addClass('prepare-loading');
                element.css('-webkit-mask-image', 'url(forecast.widget/icons/' + icon + '.png)');
                element.removeClass('loading');
                setTimeout(function () {
                    element.removeClass('prepare-loading');
                }, 500);
            } else {
                element.addClass('prepare-loading');
                element.addClass('loading');
                setTimeout(function () {
                    element.css('-webkit-mask-image', 'url(forecast.widget/icons/' + icon + '.png)');
                    element.removeClass('loading');
                    setTimeout(function () {
                        element.removeClass('prepare-loading');
                    }, 500);
                }, 500);
            }
        }
    },

    // Maps a value in range A to a value in range B
    map: function (x, in_min, in_max, out_min, out_max) {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    },

    // Returns a readable (N, S, E, W, etc) bearing based on degrees
    bearing: function (bearing) {
        var direction_index = Math.round(bearing / 45);
        return ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'][direction_index];
    },

    unit_labels: {
        auto: {
            speed: 'mph'
        },
        us: {
            speed: 'mph'
        },
        si: {
            speed: 'm/s'
        },
        ca: {
            speed: 'km/h'
        },
        uk: {
            speed: 'mph'
        }
    },

    dayMapping: {
        0: 'Sun',
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat'
    },

    api_instructions: '<b>Installation Instructions</b><br>Replace "API_KEY" with an API key obtained from https://developer.forecast.io/'
};
