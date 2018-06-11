module ConsoleStyle

    # From here:
    # http://pueblo.sourceforge.net/doc/manual/ansi_color_codes.html

    RESET             = "\33[0m"  # reset; clears all colors and styles (to white on black)

    BOLD_ON           = "\33[1m"  # bold on (see below)
    ITALICS_ON        = "\33[3m"  # italics on
    UNDERLINE_ON      = "\33[4m"  # underline on
    INVERSE_ON        = "\33[7m"  # switch foreground and background colour
    STRIKETHROUGH_ON  = "\33[9m"  # strikethrough on
    BOLD_OFF          = "\33[22m" # bold off (see below)
    ITALICS_OFF       = "\33[23m" # italics off
    UNDERLINE_OFF     = "\33[24m" # underline off
    INVERSE_OFF       = "\33[27m" # inverse off
    STRIKETHROUGH_OFF = "\33[29m" # strikethrough off
    
    FG_BLACK   = "\33[30m" # set foreground color to black
    FG_RED     = "\33[31m" # set foreground color to red
    FG_GREEN   = "\33[32m" # set foreground color to green
    FG_YELLOW  = "\33[33m" # set foreground color to yellow
    FG_BLUE    = "\33[34m" # set foreground color to blue
    FG_MAGENTA = "\33[35m" # set foreground color to magenta (purple)
    FG_CYAN    = "\33[36m" # set foreground color to cyan
    FG_WHITE   = "\33[37m" # set foreground color to white
    FG_DEFAULT = "\33[39m" # set foreground color to default (white)

    BG_BLACK   = "\33[40m" # set background color to black
    BG_RED     = "\33[41m" # set background color to red
    BG_GREEN   = "\33[42m" # set background color to green
    BG_YELLOW  = "\33[43m" # set background color to yellow
    BG_BLUE    = "\33[44m" # set background color to blue
    BG_MAGENTA = "\33[45m" # set background color to magenta (purple)
    BG_CYAN    = "\33[46m" # set background color to cyan
    BG_WHITE   = "\33[47m" # set background color to white
    BG_DEFAULT = "\33[49m" # set background color to default (black)

end
