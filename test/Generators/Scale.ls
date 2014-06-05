require! {
    fs
    expect : "expect.js"
    "../../lib/Generators/Scale"
}

test = it
describe "Scale" ->
    test "should construct linear scale" ->
        scaleGenerator = new Scale!
            ..setInput [0 1]
            ..setOutput <[#000 #fff]>
            ..setScaling \linear
        scale = scaleGenerator.get!
        expect scale 0 .to.equal \#000000
        expect scale 1 .to.equal \#ffffff
        expect scale 0.5 .to.equal \#808080

    test "should construct a scale with clipped extremes" ->
        scaleGenerator = new Scale!
            ..setInput [1 to 8] ++ [-9999 9999]
            ..setOutput <[#000 #111 #eee #fff]>
            ..setScaling \linear
            ..setExtremesClipping 0.1
        scale = scaleGenerator.get!
        expect scale.domain! .to.eql [-9999 1 8 9999]

    test "should construct a sqrt scale" ->
        scaleGenerator = new Scale!
            ..setInput [0 1]
            ..setOutput [0 10]
            ..setScaling \sqrt
        scale = scaleGenerator.get!
        baseArea   = Math.round scale 4
        doubleArea = Math.round scale 4 * 2^2
        expect doubleArea .to.equal baseArea * 2

    test "should construct an ordinal scale" ->
        scaleGenerator = new Scale!
            ..setOrdinalInput [\a \b \c]
            ..setOutput [\x \y \z]
        scale = scaleGenerator.get!
        expect scale \a .to.equal \x
        expect scale \b .to.equal \y
        expect scale \c .to.equal \z





