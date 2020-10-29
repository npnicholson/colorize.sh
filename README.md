# colorize.sh
Shell Script for replacing editor safe color tags with ANSI Escape Sequences using sed

Replaces ASCII friendly tags (as defined below) from piped input with their ANSI Escape Code equivalent. To use colorize.sh, place these tags (listed below under ANSI Functions) in a text file and pipe it to this program using cat (see examples). The tags within the pipe will be converted to their ANSI Escape Code equivalents and output to stdout.

### Usage
`pipe | colorize.sh [-hqvse] [| pipe out]`
* `-h` : Show this help message, then exit
* `-q` : Supress warning and error messages
* `-v` : Show the version number, then exit
* `-s` : Set the tag start charactor (default is '{'. Can also be set using `export CLR_START="{"`
* `-e` : Set the tag end charactor (default is '}'. Can also be set using `export CLR_END="}"`

### Tags
Tags should be placed in the piped data. Each valid tag will be replaced with an ANSI Escape Code, depending on the operation and argument provided, as shown below. The specific starting and ending strings for the tags ('{' and '}' by default) can be changed using the `-s` and `-e` arguments.

`{op[:arg]}`
* `op` : ANSI operation to execute
* `arg` : Argument for the selected ANSI operation, if required

## ANSI Functions
Each of the following ANSI functions can be invoked using the provided tags

### Basic Operations
* `{c}` __Clear__ : Clears all ANSI Formatting (`ESC[0m`)
* `{e}` __Escape__ : Substitutes the ANSI Escape [dec 27 / hex 0x1B / oct 033]

### Color Operations:
* `{f:_}` __Foreground Color__
  * `{f:k}` __Black__ (`ESC[30m`)
  * `{f:r}` __Red__ (`ESC[31m`)
  * `{f:g}` __Green__ (`ESC[32m`)
  * `{f:y}` __Yellow__ (`ESC[33m`)
  * `{f:b}` __Blue__ (`ESC[34m`)
  * `{f:m}` __Magenta__ (`ESC[35m`)
  * `{f:c}` __Cyan__ (`ESC[36m`)
  * `{f:w}` __White__ (`ESC[37m`)
  * `{f:bk}` __Bright Black__ (`ESC[90m`)
  * `{f:br}` __Bright Red__ (`ESC[91m`)
  * `{f:bg}` __Bright Green__ (`ESC[92m`)
  * `{f:by}` __Bright Yellow__ (`ESC[93m`)
  * `{f:bb}` __Bright Blue__ (`ESC[94m`)
  * `{f:bm}` __Bright Magenta__ (`ESC[95m`)
  * `{f:bc}` __Bright Cyan__ (`ESC[96m`)
  * `{f:bw}` __Bright White__ (`ESC[97m`)
  * `{f:#}` __Select__ (`ESC[38;5;#m`)
  * `{f:R:G:B}` __RGB__ (`ESC[38;2;R;G;Bm`)
  * `{f}` __Clear__ (`ESC[39m`)

* `{b:_}` __Background Color__
  * `{b:k}` __Black__ (`ESC[40m`)
  * `{b:r}` __Red__ (`ESC[41m`)
  * `{b:g}` __Green__ (`ESC[42m`)
  * `{b:y}` __Yellow__ (`ESC[43m`)
  * `{b:b}` __Blue__ (`ESC[44m`)
  * `{b:m}` __Magenta__ (`ESC[45m`)
  * `{b:c}` __Cyan__ (`ESC[46m`)
  * `{b:w}` __White__ (`ESC[47m`)
  * `{b:bk}` __Bright Black__ (`ESC[100m`)
  * `{b:br}` __Bright Red__ (`ESC[101m`)
  * `{b:bg}` __Bright Green__ (`ESC[102m`)
  * `{b:by}` __Bright Yellow__ (`ESC[103m`)
  * `{b:bb}` __Bright Blue__ (`ESC[104m`)
  * `{b:bm}` __Bright Magenta__ (`ESC[105m`)
  * `{b:bc}` __Bright Cyan__ (`ESC[106m`)
  * `{b:bw}` __Bright White__ (`ESC[107m`)
  * `{b:#}` __Select__ (`ESC[48;5;#m`)
  * `{b:R:G:B}` __RGB__ (`ESC[48;2;R;G;Bm`)
  * `{b}` __Clear__ (`ESC[49m`)

### Text Modifiers
* `{r:1/0}` __Reverse__ (`ESC[7m` / `ESC[27m`)
* `{i:1/0}` __Italic__ (`ESC[3m` / `ESC[23m`)
* `{u:1/0}` __Underline__ (`ESC[4m` / `ESC[24m`)
* `{x:1/0}` __Strike__ (`ESC[9m` / `ESC[29m`)
* `{s:1/0}` __Strong__ (`ESC[1m` / `ESC[22m`)
* `{w:1/0}` __Weak__ (`ESC[2m` / `ESC[22m`)

_Note that text can only be Strong (bold) or Weak (light) or neither (normal).
Clearing Strong or Weak will clear the other as well._

_Text Modifiers are enabled or diabled with a 1 or a 0 as their argument. For example:
`{i:1}` would activate italics and `{x:0}` would disable strike_

## Example

Pipe text with tags into colorize.sh to produce a colored output:

`printf "Something {f:b}blue{f} and something {u:1}underlined{u:0}\n" | colorize.sh`

`cat color_tagged_file | colorize.sh`

Output from colorize.sh can also be piped elsewhere:

`printf "{f:r}Something red and {u:1}underlined{c}\n" | colorize.sh | less -r`

## Issues

* `colorize.sh: command not found` : Make sure you are using the `/full/path/to/colorize.sh` or place colorize.sh within your path. For most systems, try placing colorize.sh under `/usr/bin` or `/usr/local/bin`. If you prefer, you can also link colorize.sh to one of these folders using something like `ln -s /full/path/to/colorize.sh /usr/bin/colorize.sh`

## References
For more information on ANSI Codes, see [ANSI Escape Codes Wiki](https://en.wikipedia.org/wiki/ANSI_escape_code)
