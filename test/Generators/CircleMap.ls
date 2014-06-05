require! {
    fs
    expect : "expect.js"
    topojson
    "../../lib/Generators/CircleMap"
}

test = it
describe "CircleMap" ->
    features = null
    generator = null
    annotateToStandaloneSvg = (svg) ->
        '''<?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                ''' + svg
    before (done) ->
        (err, data) <~ fs.readFile "#__dirname/../data/2009.topo.json"
        topo = JSON.parse data
        features := topojson.feature topo, topo.objects."results" .features
        done!

    test "should output list of SVGs for various zoomlevels" ->
        parties = <[SD EPP EAF G ALDE NI GUE ECR UEN]>
        colors = <[#ff7f00 #fdbf6f #a6cee3 #33a02c #1f78b4 #999999 #e31a1c #a65628 #ffff33]>
        winnerValues = features.map (feature) ->
            data = feature.properties
            {votes, abbr} = parties.reduce do
                ({votes}:prev, abbr, index) ->
                    if votes < data[abbr]
                        prev.votes = data[abbr]
                        prev.abbr = abbr
                    prev
                {votes: 0, abbr: null}
            abbr

        radii = features.map (.properties.voters)
        generator := new CircleMap features
            ..fill winnerValues
            ..fillScale
                ..setOrdinalInput parties
                ..setOutput colors
            ..radius radii
            ..radiusScale
                ..setOutput [4 20]

        svgs = generator.getSVG [4 to 6]
        for svg, index in svgs
            svg = annotateToStandaloneSvg svg
            svg .= replace /[\n\r]/g ''
            controlSvg = fs.readFileSync "#__dirname/../data/circles#{index}.svg" .toString!
            controlSvg .= replace /[\n\r]/g ''
            expect svg .to.equal controlSvg
