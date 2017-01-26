//var php_url = "http://localhost/hw8/hw8.php";
//var php_url = "http://andylsn.fm3fckg7k4.us-west-2.elasticbeanstalk.com/";
var php_url = "http://csci571-1278.appspot.com";

/** 
 * Version 2.0
 */
var Markit = {};
/**
 * Define the InteractiveChartApi.
 * First argument is symbol (string) for the quote. Examples: AAPL, MSFT, JNJ, GOOG.
 * Second argument is duration (int) for how many days of history to retrieve.
 */
Markit.InteractiveChartApi = function(symbol,duration){
    this.symbol = symbol.toUpperCase();
    this.duration = duration;
    this.PlotChart();
};

Markit.InteractiveChartApi.prototype.PlotChart = function(){
    var params = {
        parameters: JSON.stringify( this.getInputParams() )
    };
    
    $.ajax({
        url: php_url,
        data: params,
        type: "GET",
        context: this,
        success: function(response, status, xhr) {
            var json = $.parseJSON(response);
            this.render(json);
        },
        error: function(xhr, status, error) {
            console.log("error");
        }
    });
};

Markit.InteractiveChartApi.prototype.getInputParams = function(){
    return {  
        Normalized: false,
        NumberOfDays: this.duration,
        DataPeriod: "Day",
        Elements: [
            {
                Symbol: this.symbol,
                Type: "price",
                Params: ["ohlc"] //ohlc, c = close only
            }
        ]
    }
};

Markit.InteractiveChartApi.prototype._fixDate = function(dateIn) {
    var dat = new Date(dateIn);
    return Date.UTC(dat.getFullYear(), dat.getMonth(), dat.getDate());
};

Markit.InteractiveChartApi.prototype._getOHLC = function(json) {
    var dates = json.Dates || [];
    var elements = json.Elements || [];
    var chartSeries = [];

    if (elements[0]){

        for (var i = 0, datLen = dates.length; i < datLen; i++) {
            var dat = this._fixDate( dates[i] );
            var pointData = [
                dat,
                elements[0].DataSeries['open'].values[i],
                elements[0].DataSeries['high'].values[i],
                elements[0].DataSeries['low'].values[i],
                elements[0].DataSeries['close'].values[i]
            ];
            chartSeries.push( pointData );
        };
    }
    return chartSeries;
};

Markit.InteractiveChartApi.prototype.render = function(data) {
    // split the data set into ohlc
    var ohlc = this._getOHLC(data);

    // create the chart
    $('#hichart').highcharts('StockChart', {
        
        rangeSelector: {
            selected: 1,
            inputEnabled: false,
            buttons: [{
                type: 'week',
                count: 1,
                text: '1w'
            }, {
                type: 'month',
                count: 1,
                text: '1m'
            }, {
                type: 'month',
                count: 3,
                text: '3m'
            }, {
                type: 'month',
                count: 6,
                text: '6m'
            }, {
                type: 'ytd',
                text: 'YTD'
            }, {
                type: 'year',
                count: 1,
                text: '1y'
            }, {
                type: 'all',
                text: 'All'
            }],
            selected: 0
        },

        title: {
            text: this.symbol + ' Stock Value'
        },

        yAxis: [{
            title: {
                text: 'Stock Value'
            },
        }, {
            title: {
                text: ''
            },
        }],
        
        navigation: {
            buttonOptions: {
                enabled: false
            }
        },
        
        series : [{
                name : this.symbol,
                data : ohlc,
                type : 'area',
                threshold : null,
                tooltip : {
                    valueDecimals : 2
                },
                fillColor : {
                    linearGradient : {
                        x1: 0,
                        y1: 0,
                        x2: 0,
                        y2: 1
                    },
                    stops : [
                        [0, Highcharts.getOptions().colors[0]],
                        [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                    ]
                }
        }]
    });
};

/********************************************/
$(document).ready(load_chart());

function load_chart() {
    var query = window.location.search.substring(1);
    var quote = (query.split("="))[1]
    var mar = new Markit.InteractiveChartApi(quote, 1095);
}