require! {
    d3
    jsdom
    "./BaseSvg"
    "./Scale"
}

module.exports = class ChoroplethQuantitative extends BaseSvg
    (@features) ->
        super @features, \path
        @fillScale = new Scale!

    getSVG: ->
        @update!
        super ...

    fill: (@fillValues, fillScale = null) ->
        if fillScale
            @fillScale = that
        else
            @fillScale.setInput @fillValues

    update: ->
        scale = @fillScale.get!
        @features.attr \fill (d, i) ~> scale @fillValues[i]

    createElements: ->
        super ...
        path = d3.geo.path!projection @projection
        @features.attr \d path
