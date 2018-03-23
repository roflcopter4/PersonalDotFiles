#!/usr/bin/env python3

# Splint output colorizer
#
# This script runs SPLint with a given set of arguments and colorizes the output
# to improve readability.
#
# This script redirects the output of splint through a temporary hidden file,
# reads the file back in lines, and applies various colours to them based on
# some simple regex searches. This is probably not the most elegant solution,
# but it seems to work more or less.
#
# UPDATED: Frankly, the original script just did not work. It wouldn't accept
# input properly, and when changed to make it do so, it failed to properly
# colorize anything. I have made a few simple changes to fix this, expanded the
# extent of the colorization, changed some of the original hideous 8 color
# palette to nicer ones, made the script insert "splint" to it's command by
# default (meaning it can be called in place of splint, saving literally seconds
# of your time), and added a help message.
#
# Unfortunatley, it now of course requires a 256 color terminal. If one is not
# available for use, then I would recommend that you either:
# 1)  Check the nearest calendar; you and your computer seem to have been
#     teleported 20 years forward in time; or
# 2)  Stop messing about with splint and get back to work fixing the X Server
#     you broke.

import sys
import os
import re

# Colors for printing. Some of these require a 256 color terminal.
BOLD = '\x1b[1m'
colors = {'normal': '\x1b[0m',
          'red': '\033[38;5;1m',
          'green': '\x1b[38;5;40m',
          'yellow': '\033[33m',
          'blue': '\033[38;5;33m',
          'magenta': '\033[38;5;163m',
          'cyan': '\033[36m',
          'white': '\033[37m',
          'orange': '\033[38;5;208m'
          }

# This is where the compiled regexes will get stored soon
regexes = {}


# Hook to colorize the Splint title line. This is useful, because it helps you
# find the beginning of last run's output.
def title_hook(line):
    print(colors["green"])
    x = "#" * len(line)
    print(x)
    print(line)
    print(x + colors["normal"])


# Hook to colorize error messages
def error_hook(line):
    # print colors["red"] + line + colors["normal"]
    print(colors["normal"] + line + colors["normal"])


# Hook to colorize explainatory text
def explaination_hook(line):
    print(colors["blue"] + line + colors["normal"])


def info_hook(line):
    print(colors["cyan"] + line + colors["normal"])


def lineno_hook(line):
    fre = re.compile("(.*)(:)(\d*:\d*)(:.*)")
    obj = fre.match(line)
    if (obj is not None):
        if (obj.group(1)[0] == ' '):
            print(colors["yellow"] + obj.group(1) + colors["normal"] +
                  obj.group(2) + colors["orange"] + obj.group(3) +
                  colors["normal"] + obj.group(4))
        else:
            print(colors["red"] + obj.group(1) + colors["normal"] +
                  obj.group(2) + colors["orange"] + obj.group(3) +
                  colors["normal"] + obj.group(4))


# Hook to colorize Splint's function names
def funcname_hook(line):
    fre = re.compile("(.*)(: \(in function )(.*)(\).*)")
    obj = fre.match(line)
    if (obj is not None):
        print(colors["yellow"] + obj.group(1) + colors["normal"] +
              obj.group(2) + colors["magenta"] + obj.group(3) +
              colors["normal"] + obj.group(4))


def funcname_hook_2(line):
    fre = re.compile("(.*: )(\S*$)")
    obj = fre.match(line)
    if (obj is not None):
        lineno_hook(obj.group(1))
        print(" "*21 + colors["orange"] + obj.group(2) + colors["normal"])


def funcname_hook_3(line):
    print("WE FOUND FUNC HOOK 3!!")
    # fre = re.compile("(.*?)(\S*?(?:(?:\(.*?\))|(?: \(.*?\))))(.*)")
    fre = re.compile("(.*?)(\S*?((\(.*?\))|( \(.*?\))))(.*)")
    obj = fre.match(line)
    if (obj is not None):
        print(obj.group(1) + colors["red"] + obj.group(2) +
              colors["normal"] + obj.group(3))


def is_help(argument):
    help_args = ("h", "H", "-h", "--help")
    for arg in help_args:
        if argument == arg:
            return True
    return False


hooks = {'title': title_hook,
         'funcname': funcname_hook,
         'error': error_hook,
         'expl': explaination_hook,
         'info': info_hook,
         'funcname2': funcname_hook_2,
         'lineno': lineno_hook,
         # 'funcname3': funcname_hook_3
         }

regex_uncompiled = {'title': "Splint \d.*",
                    'funcname': ".*\(in function .*\).*",
                    'error': "\s{4,4}\S.*",
                    'expl': "^\s{2,2}\S.*",
                    'info': "Command Line:.*",
                    'funcname2': ": \S*$",
                    'lineno': '\d*:\d*:',
                    # 'funcname3': "\S*?(\(.*?\)| \(.*?\))"
                    }

# ## START OF SCRIPT ##

# Compile the regexes
for reg in list(regex_uncompiled.keys()):
    regexes[reg] = re.compile(regex_uncompiled[reg])

# Check if any commands were supplied. If not, display usage.
if len(sys.argv) < 2 or is_help(sys.argv[1]):
    print("USAGE:  " + sys.argv[0] + " <SPLINT OPTIONS>\n" +
          "OR:  " + sys.argv[0] + " -m <splint> <SPLINT OPTIONS>")
    print("""
This script calls 'splint' automatically and can be called in place of splint.
Should your copy of splint not be in PATH, you can explicitly specify it with
the parameter '-m <SPLINT BINARY>'. All other paramaters are passed to splint.
See splint's excellent documentation for more details.
""")
    sys.exit(1)


# Build the commandline.
cmdline = ""
start = 1
if (sys.argv[1] == "-m"):
    start = 2
else:
    cmdline += "splint "

for param in sys.argv[start:]:
    if cmdline == "":
        cmdline += param
    else:
        cmdline += (" " + param)

# Output will be redirected to a temporary file for analysis.
cmdline += "  > .splint.out 2>&1"

# Display and execute.
print("Executing command '" + cmdline + "'")
os.system(cmdline)

# Read output and remove temp file.
f = open(".splint.out")
output = f.readlines()
os.system("rm .splint.out")

# process output
for line in output:
    # erase trailing newline
    stripped_line = line.strip("\n")
    seen = 0
    # try to match this line with a regex
    for name in regexes:
        if regexes[name].search(stripped_line):
            seen = 1
            hooks[name](stripped_line)
            break
    # if no regex matched, simply print
    if seen == 0:
        print(stripped_line)
