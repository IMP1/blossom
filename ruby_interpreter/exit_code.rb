module ExitCode
    OK          = 0  # successful termination
    BASE        = 64 # base value for error messages
    USAGE       = 64 # command line usage error
    DATAERR     = 65 # data format error
    NOINPUT     = 66 # cannot open input
    NOUSER      = 67 # addressee unknown
    NOHOST      = 68 # host name unknown
    UNAVAILABLE = 69 # service unavailable
    SOFTWARE    = 70 # internal software error
    OSERR       = 71 # system error (e.g., can't fork)
    OSFILE      = 72 # critical OS file missing
    CANTCREAT   = 73 # can't create (user) output file
    IOERR       = 74 # input/output error
    TEMPFAIL    = 75 # temp failure; user is invited to retry
    PROTOCOL    = 76 # remote error in protocol
    NOPERM      = 77 # permission denied
    CONFIG      = 78 # configuration error
end