require! {
    fs
    child_process.exec
}

option 'testFile' 'File in (/lib or /test) to run test on' 'FILE'
option 'currentfile' 'Latest file that triggered the save' 'FILE'

build-all-server-scripts = (cb) ->
    require! child_process.exec
    (err, stdout, stderr) <~ exec "lsc -o #__dirname/lib -c #__dirname/src"
    throw stderr if stderr
    cb? err

test-script = (file) ->
    require! child_process.exec
    [srcOrTest, ...fileAddress] = file.split /[\\\/]/
    fileAddress .= join '/'
    <~ build-all-server-scripts
    cmd = "mocha --compilers ls:livescript -R tap --bail #__dirname/test/#fileAddress"
    (err, stdout, stderr) <~ exec cmd
    utils.niceTestOutput stdout, stderr, cmd

task \build-script ({currentfile}) ->
    file = utils.relativizeFilename currentfile
    isServer = \src/ == file.substr 0, 4
    isTest = \test/ == file.substr 0, 5
    if isServer or isTest
        test-script file
    else
        <~ build-script file
        combine-scripts compression: no

utils =
    relativizeFilename : (file) ->
        file .= replace __dirname, ''
        file .= replace do
            new RegExp \\\\, \g
            '/'
        file .= substr 1

    niceTestOutput : (test, stderr, cmd) ->
        lines         = test.split "\n"
        oks           = 0
        fails         = 0
        out           = []
        shortOut      = []
        disabledTests = []
        for line in lines
            if 'ok' == line.substr 0, 2
                ++oks
            else if 'not' == line.substr 0,3
                ++fails
                out.push line
                shortOut.push line.match(/not ok [0-9]+ (.*)$/)[1]
            else if 'Disabled' == line.substr 0 8
                disabledTests.push line
            else if line and ('#' != line.substr 0, 1) and ('1..' != line.substr 0, 3)
                console.log line# if ('   ' != line.substr 0, 3)
        if oks && !fails
            console.log "Tests OK (#{oks})"
            disabledTests.forEach -> console.log it
        else
            #console.log "!!!!!!!!!!!!!!!!!!!!!!!    #{fails}    !!!!!!!!!!!!!!!!!!!!!!!"
            if out.length
                console.log shortOut.join ", "#line for line in shortOut
            else
                console.log "Tests did not run (error in testfile?)"
                console.log test
                console.log stderr
                console.log cmd

