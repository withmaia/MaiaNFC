exports.capitalize = (s) ->
    s.slice(0, 1).toUpperCase() + s.slice(1)

exports.randomString = (len=8) ->
    s = ''
    while s.length < len
        s += Math.random().toString(36).slice(2, len-s.length+2)
    return s

exports.randomChoice = (l) -> l[Math.floor Math.random() * l.length]

exports.unslugify = (s) -> s.replace(/[^a-zA-Z ]/g, ' ')

