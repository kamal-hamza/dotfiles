# Plain ls like macOS Terminal: replaces fish's built-in wrapper, which adds
# --color=auto / -G and -F indicators.
function ls --wraps ls --description 'ls without colors'
    command ls $argv
end
