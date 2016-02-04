module.exports = {
    command: '',

    apiKey: 'f24accee826e147ee895c96f69db3ab2', // put your forcast.io api key inside the quotes here

    refreshFrequency: false,

    refreshFrequencyWithBlackjackAndHookers: 120000,
    lat: 33.8706763, // other options are auto
    lon: -117.865775, // other options are auto
    units: 'us', // us, si, ca, uk, auto

    afterRender: function () {
        var widget = $('#forecast-widget-index-js');
        for (var i in document.styleSheets[1].rules[0].style) {
            if (typeof document.styleSheets[1].rules[0].style[i] === 'string' && document.styleSheets[1].rules[0].style[i] !== '') {
                widget.css(i, document.styleSheets[1].rules[0].style[i]);
            }
        }

        var uber = this;

        var ready = function () {
            uber.run(uber.command, function () {});
            uber.refresh();
            setInterval(function () {
                uber.run(uber.command, function () {});
                uber.refresh();
            }, uber.refreshFrequencyWithBlackjackAndHookers);
        };

        if (uber.lat == 'auto' && uber.lon == 'auto') {
            geolocation.getCurrentPosition(function (e) {
                uber.lat = e.position.coords.latitude;
                uber.lon = e.position.coords.longitude;
                uber.command = uber.makeCommand(uber.apiKey, uber.lat + ',' + uber.lon, uber.units);
                ready();
            });
        } else {
            uber.command = uber.makeCommand(uber.apiKey, uber.lat + ',' + uber.lon, uber.units);
            ready();
        }

        $('#forecast-widget-index-js').click(function () {
            uber.run('open http://www.wunderground.com', function () {});
        });
    },

    makeCommand: function (apiKey, location, units) {
        var exclude = 'minutely,alerts,flags';
        return 'curl -sS "https://api.forecast.io/forecast/' + apiKey + '/' + location + '?units=' + units + '&exclude=' + exclude + '"';
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

    update: function (output) {
        if (output && output !== '') {
            output = JSON.parse(output);

            var next_hour_temp = output.hourly.data[1].temperature; // Next hour's temp
            var current_temp = output.currently.temperature; // Current temp

            if (next_hour_temp > current_temp) {
                $('#temp-direction').text('and rising');
            } else {
                $('#temp-direction').text('and falling');
            }

            $('.fe-temp').text(Math.round(current_temp));
            $('.fe-summary').text(output.currently.summary);

            var wind_speed = Math.round(output.currently.windSpeed);
            var wind_speed_units = this.unit_labels[this.units || 'us'].speed;
            var wind_bearing = this.bearing(output.currently.windBearing);
            $('.fe-wind').text('Wind: ' + wind_speed + ' ' + wind_speed_units + ' (' + wind_bearing + ')');

            this.changeIcon($('#fe-current-icon'), output.currently.icon);

            var tempMin = 1000;
            var tempMax = -1000;

            for (var day in output.daily.data) {
                if (output.daily.data[day].temperatureMax > tempMax) {
                    tempMax = output.daily.data[day].temperatureMax;
                }
                if (output.daily.data[day].temperatureMin < tempMin) {
                    tempMin = output.daily.data[day].temperatureMin;
                }
            }

            for (day in output.daily.data) {
                if (day === '0') {
                    $('#day' + day).find('.day-text').text('Tod');
                } else {
                    $('#day' + day).find('.day-text').text(this.dayMapping[new Date(output.daily.data[day].time * 1000).getDay()]);
                }
                this.changeIcon($('#day' + day).find('.weather-icon'), output.daily.data[day].icon);
                var day_high = Math.round(output.daily.data[day].temperatureMax) + '°';
                var day_low = Math.round(output.daily.data[day].temperatureMin) + '°';
                var day_high_rel = this.map(output.daily.data[day].temperatureMax, tempMin, tempMax, 0, 1);
                var day_low_rel = this.map(output.daily.data[day].temperatureMin, tempMin, tempMax, 0, 1);
                var height = 100;
                $('#day' + day).find('.bar').attr('data-content-high', day_high);
                $('#day' + day).find('.bar').attr('data-content-low', day_low);
                // window.getComputedStyle($("#day#{day}").find('.bar')[0], '::before').setProperty('content', day_high, 0);
                // window.getComputedStyle($("#day#{day}").find('.bar')[0], '::after').setProperty('content', day_low, 0);
                $('#day' + day).find('.bar').css('top', height - (day_high_rel * height));
                $('#day' + day).find('.bar').css('bottom', day_low_rel * height);
                // $("#day#{day}").find('.bar').text("#{day_high_rel} #{day_low_rel}")
            }

            $('.fe-forecast').removeClass('loading');
        }
    },

    map: function (x, in_min, in_max, out_min, out_max) {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    },

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

    bearing: function (bearing) {
        var direction_index = Math.round(bearing / 45);
        return ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'][direction_index];
    },

    dayMapping: {
        0: 'Sun',
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat'
    }
};
