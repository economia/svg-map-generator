require! {
    fs
    expect : "expect.js"
    topojson
    "../../lib/Generators/Choropleth"
}

test = it
describe "Choropleth" ->
    features = null
    generator = null
    svg = null
    annotateToStandaloneSvg = (svg) ->
        '''<?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
                ''' + svg
    before (done) ->
        (err, data) <~ fs.readFile "#__dirname/../data/2009.topo.json"
        topo = JSON.parse data
        features := topojson.feature topo, topo.objects."results" .features
        done!

    test "should output SVG from a list of features" ->
        values = features.map -> it.properties.GUE / it.properties.voters
        generator := new Choropleth features
            ..fill values
        svg := generator.getSVG!
        svg := annotateToStandaloneSvg svg
        controlSvg = fs.readFileSync "#__dirname/../data/choropleth_basic.svg"
        expect svg .to.equal controlSvg.toString!

    test "should be able to change fill on-the-fly" ->
        values = features.map -> it.properties.EPP / it.properties.voters
        generator
            ..fillScale
                ..setOutput <[#000 #002 #004 #006 #008 #00a #00c #00e]>
                ..setScaling \quantize
            ..fill values

        svg = annotateToStandaloneSvg generator.getSVG!
        controlSvg = fs.readFileSync "#__dirname/../data/choropleth_basic2.svg"
        expect svg .to.equal controlSvg.toString!

    test "should be able to output ordinal SVGs" ->
        parties = <[SD EPP EAF G ALDE NI GUE ECR UEN]>
        colors = <[#ff7f00 #fdbf6f #a6cee3 #33a02c #1f78b4 #999999 #e31a1c #a65628 #ffff33]>
        values = features.map (feature) ->
            data = feature.properties
            {votes, abbr} = parties.reduce do
                ({votes}:prev, abbr, index) ->
                    if votes < data[abbr]
                        prev.votes = data[abbr]
                        prev.abbr = abbr
                    prev
                {votes: 0, abbr: null}
            abbr

        generator
            ..fill values
            ..fillScale
                ..setOrdinalInput parties
                ..setOutput colors

        svg = generator.getSVG!
        controlSvg = fs.readFileSync "#__dirname/../data/choropleth_ordinal.svg"
        expect svg .to.equal controlSvg.toString!
