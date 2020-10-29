#!/bin/sh
# ==================================================================================
# | colorize.sh :: Entalon LLC                                                     |
# |                                                                                |
# | ░█████╗░░█████╗░██╗░░░░░░█████╗░██████╗░██╗███████╗███████╗░░░░██████╗██╗░░██╗ |
# | ██╔══██╗██╔══██╗██║░░░░░██╔══██╗██╔══██╗██║╚════██║██╔════╝░░░██╔════╝██║░░██║ |
# | ██║░░╚═╝██║░░██║██║░░░░░██║░░██║██████╔╝██║░░███╔═╝█████╗░░░░░╚█████╗░███████║ |
# | ██║░░██╗██║░░██║██║░░░░░██║░░██║██╔══██╗██║██╔══╝░░██╔══╝░░░░░░╚═══██╗██╔══██║ |
# | ╚█████╔╝╚█████╔╝███████╗╚█████╔╝██║░░██║██║███████╗███████╗██╗██████╔╝██║░░██║ |
# | ░╚════╝░░╚════╝░╚══════╝░╚════╝░╚═╝░░╚═╝╚═╝╚══════╝╚══════╝╚═╝╚═════╝░╚═╝░░╚═╝ |
# |                                                                                |
# | GNU General Public License                                                     |
# | Written by Norris Nicholson, October 2020                                      |
# ==================================================================================
# Purpose:
#  colorize.sh takes a piped input and converts ASCII friendly tags to ANSI
#  escape codes. This can then be piped elsewhere, for example, to less -r in 
#  order to view color in text documentation
#
# License:
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
# Revision History:
# Version 1.5
#  - Added support for changing the tag start and end strings
#
# Version 1.4
#  - Added support for foreground and background color reverse (Reverse Video)
#
# Version 1.3
#  - Added the -v (version) argument for getting the program version
#
# Version 1.2
#  - Added documentation
#
# Version 1.1
#  - Added support for bright colors
#
# Version 1.0
#  - Initial Release

# Current Version
VERSION="1.5"

# Get the tag start string if it has been defined from the environment. Otherwise,
# use the default "{"
[ -z "$CLR_START" ] && CLR_START="{";

# Get the tag end string if it has been defined from the environment. Otherwise,
# use the default "}"
[ -z "$CLR_END" ] && CLR_END="}";

# Usage Output
usage() {
    echo -e ""
    echo -e "\x1B[34mColorize.sh\x1B[0m - Parses piped input for ASCII friendly tags (as defined below) to be"
    echo -e " replaced with their ANSI Escape Code equivalent. To use colorize.sh, place these tags (listed"
    echo -e " below under ANSI Functions, Color Operations, and Modifiers) in a text file and pipe it"
    echo -e " to this program using cat. The tags will be converted to their ANSI Escape Code equivalents."
    echo -e ""
    echo -e "\x1B[3mWhereis:\x1B[0m \x1B[4m$(whereis colorize.sh)\x1B[24m"
    echo -e ""
    echo -e "\x1B[3mUsage:\x1B[23m \x1B[33mpipe\x1B[0m | \x1B[34mcolorize.sh\x1B[0m [\x1B[36m-h\x1B[0m] [| \x1B[33mpipe out\x1B[0m]"
    echo -e "  \x1B[36m-h\x1B[0m             :         Show this help message, then exit"
    echo -e "  \x1B[36m-q\x1B[0m             :         Supress warning and error messages"
    echo -e "  \x1B[36m-v\x1B[0m             :         Show the version number, then exit"
    echo -e "  \x1B[36m-s\x1B[0m             :         Set the tag start charactor (default is '{'. Can also be set using export CLR_START"
    echo -e "  \x1B[36m-e\x1B[0m             :         Set the tag end charactor (default is '}'. Can also be set using export CLR_END"
    echo -e ""
    echo -e "\x1B[3mTags:\x1B[23m ${CLR_START}\x1B[31mop\x1B[0m[:\x1B[32marg\x1B[0m]${CLR_END}"
    echo -e "  \x1B[31mop\x1B[0m           :         ANSI operation to execute"
    echo -e "  \x1B[32marg\x1B[0m          :         Argument for the selected ANSI operation, if required"
    echo -e ""
    echo -e "\x1B[3mANSI Functions:\x1B[23m"
    echo -e "  \x1B[36m(C) Clear\x1B[0m      : ${CLR_START}\x1B[31mc\x1B[0m${CLR_END}     \x1B[0mExample Text\x1B[0m"
    echo -e "  \x1B[36m(E) Escape\x1B[0m     : ${CLR_START}\x1B[31me\x1B[0m${CLR_END}     Substitutes the ANSI Escape [dec 27 / hex 0x1B / oct 033]"
    echo -e ""
    echo -e "\x1B[3mANSI Color Operations:\x1B[23m"
    echo -e "  \x1B[36m(F) Foreground\x1B[0m : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32m_\x1B[0m${CLR_END}"
    echo -e "  \x1B[32m━►\x1B[0m Black       : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mk\x1B[0m${CLR_END}   \x1B[30mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Black   : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mbk\x1B[0m${CLR_END}    \x1B[90mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Red         : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mr\x1B[0m${CLR_END}   \x1B[31mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Red     : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mrk\x1B[0m${CLR_END}    \x1B[91mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Green       : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mg\x1B[0m${CLR_END}   \x1B[32mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Green   : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mgk\x1B[0m${CLR_END}    \x1B[92mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Yellow      : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32my\x1B[0m${CLR_END}   \x1B[33mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Yellow  : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32myk\x1B[0m${CLR_END}    \x1B[93mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Blue        : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mb\x1B[0m${CLR_END}   \x1B[34mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Blue    : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mbk\x1B[0m${CLR_END}    \x1B[94mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Magenta     : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mm\x1B[0m${CLR_END}   \x1B[35mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Magenta : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mmk\x1B[0m${CLR_END}    \x1B[95mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Cyan        : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mc\x1B[0m${CLR_END}   \x1B[36mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Cyan    : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mck\x1B[0m${CLR_END}    \x1B[96mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m White       : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mw\x1B[0m${CLR_END}   \x1B[37mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright White   : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mwk\x1B[0m${CLR_END}    \x1B[97mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Select      : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32m#\x1B[0m${CLR_END}   \x1B[38;5;71mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m RGB            : ${CLR_START}\x1B[31mf\x1B[0m:\x1B[32mr\x1B[0m:\x1B[32mg\x1B[0m:\x1B[32mb\x1B[0m${CLR_END} \x1B[38;2;72;113;225mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Clear       : ${CLR_START}\x1B[31mf\x1B[0m${CLR_END}     \x1B[39mExample Text\x1B[0m"
    echo -e ""
    echo -e "  \x1B[36m(B) Background\x1B[0m : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32m_\x1B[0m${CLR_END}"
    echo -e "  \x1B[32m━►\x1B[0m Black       : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mk\x1B[0m${CLR_END}   \x1B[40mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Black   : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbk\x1B[0m${CLR_END}    \x1B[100mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Red         : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mr\x1B[0m${CLR_END}   \x1B[41mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Red     : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbr\x1B[0m${CLR_END}    \x1B[101mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Green       : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mg\x1B[0m${CLR_END}   \x1B[42mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Green   : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbg\x1B[0m${CLR_END}    \x1B[102mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Yellow      : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32my\x1B[0m${CLR_END}   \x1B[43mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Yellow  : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mby\x1B[0m${CLR_END}    \x1B[103mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Blue        : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mb\x1B[0m${CLR_END}   \x1B[44mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Blue    : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbb\x1B[0m${CLR_END}    \x1B[104mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Magenta     : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mm\x1B[0m${CLR_END}   \x1B[45mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Magenta : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbm\x1B[0m${CLR_END}    \x1B[105mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Cyan        : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mc\x1B[0m${CLR_END}   \x1B[46mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright Cyan    : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbc\x1B[0m${CLR_END}    \x1B[106mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m White       : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mw\x1B[0m${CLR_END}   \x1B[47mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m Bright White   : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mbw\x1B[0m${CLR_END}    \x1B[107mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Select      : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32m#\x1B[0m${CLR_END}   \x1B[48;5;71mExample Text\x1B[0m  │  \x1B[32m━►\x1B[0m RGB            : ${CLR_START}\x1B[31mb\x1B[0m:\x1B[32mr\x1B[0m:\x1B[32mg\x1B[0m:\x1B[32mb\x1B[0m${CLR_END} \x1B[48;2;72;113;225mExample Text\x1B[0m"
    echo -e "  \x1B[32m━►\x1B[0m Clear       : ${CLR_START}\x1B[31mb\x1B[0m${CLR_END}     \x1B[49mExample Text\x1B[0m"
    echo -e ""
    echo -e "\x1B[3mANSI Modifiers:\x1B[23m"
    echo -e "  \x1B[36m(R) Reverse\x1B[0m    : ${CLR_START}\x1B[31mr\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[7mExample Text\x1B[27m"
    echo -e "  \x1B[36m(I) Italics\x1B[0m    : ${CLR_START}\x1B[31mi\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[3mExample Text\x1B[23m"
    echo -e "  \x1B[36m(U) Underline\x1B[0m  : ${CLR_START}\x1B[31mu\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[4mExample Text\x1B[24m"
    echo -e "  \x1B[36m(X) Strike\x1B[0m     : ${CLR_START}\x1B[31mx\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[9mExample Text\x1B[29m"
    echo -e "  \x1B[36m(S) Strong\x1B[0m     : ${CLR_START}\x1B[31ms\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[1mExample Text\x1B[22m"
    echo -e "  \x1B[36m(W) Weak\x1B[0m       : ${CLR_START}\x1B[31mw\x1B[0m:\x1B[32m1/0\x1B[0m${CLR_END} \x1B[2mExample Text\x1B[22m"
    echo -e "    \x1B[3mNote that text can only be String (bold) or Weak (light) or neither (normal).\x1B[23m"
    echo -e "    \x1B[3mClearing Strong or Weak will clear the other as well.\x1B[23m"
    echo -e ""
    echo -e "  Modifiers are enabled or diabled with a \x1B[32m1\x1B[0m or a \x1B[32m0\x1B[0m as their argument. For example:"
    echo -e "     ${CLR_START}\x1B[31mi\x1B[0m:\x1B[32m1\x1B[0m${CLR_END} would activate italics and ${CLR_START}\x1B[31mx\x1B[0m:\x1B[32m0\x1B[0m${CLR_END} would disable strike"
    echo -e ""
    echo -e "\x1B[3mFor more information on ANSI Codes, see \x1B[23m\x1B[34m\x1B[4mhttps://en.wikipedia.org/wiki/ANSI_escape_code\x1B[0m"
    echo -e ""
    echo -e "\x1B[3mColorize.sh Version: $VERSION\x1B[0m"
    echo -e "\x1B[3mCopyright 2020, Norris Nicholson\x1B[0m"
    echo -e "\x1B[3mGNU General Public License\x1B[0m"
    echo -e ""
    echo -e "This program is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\nGNU General Public License for more details."
    echo -e ""
}

# Parse any arguments
while getopts "h?vqs:e:" arg; do
  case $arg in
    h|\?) usage; exit 0;;
    v) echo "$VERSION"; exit 0;;
    q) QUIET=1;;
    s) CLR_START=$OPTARG;;
    e) CLR_END=$OPTARG;;
    *) BAD_ARG=1;;
  esac
done

# Check if they gave a bad argument
if [ -n "${BAD_ARG+x}" ]; then
    [ -z ${QUIET+x} ] && echo -e "\x1B[31mUnknown Argument!\x1B[0m Please refer to the help below:"
    [ -z ${QUIET+x} ] && usage
    exit 1
fi

# Check that data was piped into this script
if [ ! -p /dev/stdin ]; then
    [ -z ${QUIET+x} ] && echo -e "\x1B[31mNo Pipe!\x1B[0m Colorize.sh only accepts input through pipes. Please refer to the help below:";
    [ -z ${QUIET+x} ] && usage
    exit 1
fi

# Execute the sed command to replace the tags with their ANSI escape equivalent
sed -e "s,${CLR_START}c${CLR_END},\x1B[0m,g"                                              `# Clear All Functions`       \
    -e "s,${CLR_START}e${CLR_END},\x1B,g"                                                 `# Escape Substitution`       \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (F)oreground Functions`                        \
    -e "s,${CLR_START}f:k${CLR_END},\x1B[30m,g"                                           `# Foreground Black`          \
    -e "s,${CLR_START}f:r${CLR_END},\x1B[31m,g"                                           `# Foreground Red`            \
    -e "s,${CLR_START}f:g${CLR_END},\x1B[32m,g"                                           `# Foreground Green`          \
    -e "s,${CLR_START}f:y${CLR_END},\x1B[33m,g"                                           `# Foreground Yellow`         \
    -e "s,${CLR_START}f:b${CLR_END},\x1B[34m,g"                                           `# Foreground Blue`           \
    -e "s,${CLR_START}f:m${CLR_END},\x1B[35m,g"                                           `# Foreground Magenta`        \
    -e "s,${CLR_START}f:c${CLR_END},\x1B[36m,g"                                           `# Foreground Cyan`           \
    -e "s,${CLR_START}f:w${CLR_END},\x1B[37m,g"                                           `# Foreground White`          \
    -e "s,${CLR_START}f:bk${CLR_END},\x1B[90m,g"                                          `# Foreground Bright Black`   \
    -e "s,${CLR_START}f:br${CLR_END},\x1B[91m,g"                                          `# Foreground Bright Red`     \
    -e "s,${CLR_START}f:bg${CLR_END},\x1B[92m,g"                                          `# Foreground Bright Green`   \
    -e "s,${CLR_START}f:by${CLR_END},\x1B[93m,g"                                          `# Foreground Bright Yellow`  \
    -e "s,${CLR_START}f:bb${CLR_END},\x1B[94m,g"                                          `# Foreground Bright Blue`    \
    -e "s,${CLR_START}f:bm${CLR_END},\x1B[95m,g"                                          `# Foreground Bright Magenta` \
    -e "s,${CLR_START}f:bc${CLR_END},\x1B[96m,g"                                          `# Foreground Bright Cyan`    \
    -e "s,${CLR_START}f:bw${CLR_END},\x1B[97m,g"                                          `# Foreground Bright White`   \
    -e "s,${CLR_START}f${CLR_END},\x1B[39m,g"                                             `# Foreground Clear`          \
    -e "s,${CLR_START}f:\([0-9]*\):\([0-9]*\):\([0-9]*\)${CLR_END},\x1B[38;2;\1;\2;\3m,g" `# Foreground RGB`            \
    -e "s,${CLR_START}f:\([0-9]*\)${CLR_END},\x1B[38;5;\1m,g"                             `# Foreground Color Select`   \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (B)ackground Functions`                        \
    -e "s,${CLR_START}b:k${CLR_END},\x1B[40m,g"                                           `# Background Black`          \
    -e "s,${CLR_START}b:r${CLR_END},\x1B[41m,g"                                           `# Background Red`            \
    -e "s,${CLR_START}b:g${CLR_END},\x1B[42m,g"                                           `# Background Green`          \
    -e "s,${CLR_START}b:y${CLR_END},\x1B[43m,g"                                           `# Background Yellow`         \
    -e "s,${CLR_START}b:b${CLR_END},\x1B[44m,g"                                           `# Background Blue`           \
    -e "s,${CLR_START}b:m${CLR_END},\x1B[45m,g"                                           `# Background Magenta`        \
    -e "s,${CLR_START}b:c${CLR_END},\x1B[46m,g"                                           `# Background Cyan`           \
    -e "s,${CLR_START}b:w${CLR_END},\x1B[47m,g"                                           `# Background White`          \
    -e "s,${CLR_START}b:bk${CLR_END},\x1B[100m,g"                                         `# Background Bright Black`   \
    -e "s,${CLR_START}b:br${CLR_END},\x1B[101m,g"                                         `# Background Bright Red`     \
    -e "s,${CLR_START}b:bg${CLR_END},\x1B[102m,g"                                         `# Background Bright Green`   \
    -e "s,${CLR_START}b:by${CLR_END},\x1B[103m,g"                                         `# Background Bright Yellow`  \
    -e "s,${CLR_START}b:bb${CLR_END},\x1B[104m,g"                                         `# Background Bright Blue`    \
    -e "s,${CLR_START}b:bm${CLR_END},\x1B[105m,g"                                         `# Background Bright Magenta` \
    -e "s,${CLR_START}b:bc${CLR_END},\x1B[106m,g"                                         `# Background Bright Cyan`    \
    -e "s,${CLR_START}b:bw${CLR_END},\x1B[410m,g"                                         `# Background Bright White`   \
    -e "s,${CLR_START}b${CLR_END},\x1B[49m,g"                                             `# Background Clear`          \
    -e "s,${CLR_START}b:\([0-9]*\):\([0-9]*\):\([0-9]*\)${CLR_END},\x1B[48;2;\1;\2;\3m,g" `# Background RGB`            \
    -e "s,${CLR_START}b:\([0-9]*\)${CLR_END},\x1B[48;5;\1m,g"                             `# Background Color Select`   \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (I)talics`                                     \
    -e "s,${CLR_START}i:1${CLR_END},\x1B[3m,g"                                            `# Italics On`                \
    -e "s,${CLR_START}i:0${CLR_END},\x1B[23m,g"                                           `# Italics Off`               \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (U)nderline`                                   \
    -e "s,${CLR_START}u:1${CLR_END},\x1B[4m,g"                                            `# Underline On`              \
    -e "s,${CLR_START}u:0${CLR_END},\x1B[24m,g"                                           `# Underline Off`             \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (x) Strike`                                    \
    -e "s,${CLR_START}x:1${CLR_END},\x1B[9m,g"                                            `# Strike On`                 \
    -e "s,${CLR_START}x:0${CLR_END},\x1B[29m,g"                                           `# Strike Off`                \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (S) Bold (Strong)`                             \
    -e "s,${CLR_START}s:1${CLR_END},\x1B[1m,g"                                            `# Bold On`                   \
    -e "s,${CLR_START}s:0${CLR_END},\x1B[22m,g"                                           `# Bold Off`                  \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (W) Light (Weak)`                              \
    -e "s,${CLR_START}w:1${CLR_END},\x1B[2m,g"                                            `# Light On`                  \
    -e "s,${CLR_START}w:0${CLR_END},\x1B[22m,g"                                           `# Light Off`                 \
    -e ""                                                             `#`                                               \
    -e ""                                                             `# (R)everse`                                     \
    -e "s,${CLR_START}r:1${CLR_END},\x1B[7m,g"                                            `# Reverse On`                \
    -e "s,${CLR_START}r:0${CLR_END},\x1B[27m,g"                                           `# Reverse Off`               \
    -e ""                                                             `#`