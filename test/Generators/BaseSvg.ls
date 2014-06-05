require! {
    fs
    expect : "expect.js"
    topojson
    "../../lib/Generators/BaseSvg"
}

test = it
describe "BaseSvg" ->
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

    test "should generate SVG with appropriate number of elements" ->
        generator := new BaseSvg features, \circle
        svg = generator.getSVG!
        circles = svg.match /<circle/g
        expect circles .to.have.length features.length

    test "should modify elements' attributes" ->
        generator.features.attr \r 10
        svg = generator.getSVG!
        circles = svg.match /<circle r="10"/g
        expect circles .to.have.length features.length

