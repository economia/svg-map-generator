require! {
    d3
    jsdom
}
document = jsdom.jsdom!
module.exports = class ABaseSvg
    width  : 1920
    height : 1080

    (@featureData, @featureElementType = 'path') ->
        @computeBounds!
        @setupProjection!
        @setupDocument!

    setAccessor: (accesorFn) ->
        @featureData.forEach ->
            it.fillValue = accesorFn it.properties

    getSVG: ->
        @container.innerHTML

    setupDocument: ->
        @createElements!
        @annotateSvg!

    setupProjection: ->
        [[west, south], [east, north]] = @bounds
        displayedPercent = (Math.abs west - east) / 360
        @projection = d3.geo.mercator!
            ..precision 0
            ..scale @width / (Math.PI * 2 * displayedPercent)
            ..center [west, north]
            ..translate [0 0]


    createElements: ->
        @container = document.createElement \div
        @svg = d3.select @container .append \svg
            ..attr \xmlns \http://www.w3.org/2000/svg
        @features = @svg.selectAll @featureElementType
            .data @featureData
            .enter!append @featureElementType

    annotateSvg: ->
        [[west, south], [east, north]] = @bounds
        [x0, y0] = @projection [west, north]
        [x1, y1] = @projection [east, south]
        width = (x1 - x0)
        height = (y1 - y0)
        @svg
            ..attr \width width
            ..attr \height height
            ..attr \data-bounds [north, west, south, east].join ','

    computeBounds: ->
        north = -Infinity
        west  = +Infinity
        south = +Infinity
        east  = -Infinity
        for feature in @featureData
            [[w,s],[e,n]] = d3.geo.bounds feature
            if n > north => north := n
            if w < west  => west  := w
            if s < south => south := s
            if e > east  => east  := e

        @bounds = [[west, south], [east, north]]


