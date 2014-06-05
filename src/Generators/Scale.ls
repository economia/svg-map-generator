require! d3

module.exports = class Scale
    ->
        @range = <[#000 #fff]>
        @scaling = "linear"

    setInput: (values) ->
        @values = values
            .filter -> it or it == 0
            .sort (a, b) -> a - b

    setOrdinalInput: (@values) ->
        @setScaling \ordinal

    setOutput: (@range) ->

    setScaling: (@scaling) ->

    setExtremesClipping: (@clippingPercent) ->

    get: ->
        scale = d3.scale[@scaling]!
            ..range @range
            ..domain @getDomain!

    getDomain: ->
        if @scaling == \ordinal
            @values
        else
            scaleValues = @getScaleValues!
            if not @clippingPercent
                getDomain scaleValues, @range.length
            else
                getDomain scaleValues, @range.length - 2
                    ..unshift @values.0
                    ..push @values[* - 1]

    getScaleValues: ->
        if not @clippingPercent
            @values
        else
            clipped = getClippedValues @values, @clippingPercent

    getScaleOrdinal: (range, domain) ->

getDomain = (values, steps) ->
    min = values.0
    max = values[* - 1]
    domain = for i in [0 til steps]
        min + (max - min) * i / (steps - 1)

getClippedValues = (values, clippingPercent) ->
    clip = Math.round values.length * clippingPercent
    values.slice do
        clip
        -1 * clip
