require! {
    d3
    jsdom
    "./BaseSvg"
    "./Scale"
}

module.exports = class CircleMap extends BaseSvg
    (@featureData) ->
        super @featureData, \circle
        @fillScale = new Scale!
        @radiusScale = new Scale!
            ..setScaling \sqrt
            ..setOutput [0 10]

    getSVG: (zoomlevels) ->
        zoomlevels.map (zoomlevel) ~>
            diff = zoomlevel - zoomlevels.0
            zoomFactor = 1 / (2 ^ diff)
            @update zoomFactor
            super ...

    radius: (@radiusValues, radiusScale = null) ->
        if radiusScale
            @radiusScale = that
        else
            @radiusScale.setInput @radiusValues

    fill: (@fillValues, fillScale = null) ->
        if fillScale
            @fillScale = that
        else
            @fillScale.setInput @fillValues

    update: (radiusZoomFactor) ->
        fillScale = @fillScale.get!
        radiusScale = @radiusScale.get!
        @features
            ..attr \fill (d, i) ~> fillScale @fillValues[i]
            ..attr \r (d, i) ~> radiusZoomFactor * radiusScale @radiusValues[i]

    createElements: ->
        super ...
        centroids = @featureData.map ~>
            it |> d3.geo.centroid |> @projection

        @features
            ..attr \cx (d, i) ~> centroids[i].0
            ..attr \cy (d, i) ~> centroids[i].1
