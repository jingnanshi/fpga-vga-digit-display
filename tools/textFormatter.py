#!/usr/bin/env python

# textFormatter.py
# David E Olumese [dolumese@g.hmc.edu] | Dec 2nd 2018
#
# Tool to format text for use in VGA control hardware
#

import re

TXT_MAX_LEN = 53

def main():
  txt = raw_input('Text to be formatted (53 char limit): ')
  txt = txt.upper() # expect upper case input

  if len(txt) > TXT_MAX_LEN:
    print "[Error] Input text is too long"
    return
  elif re.match("^[A-Z!? ]*$", txt) is None:
    print "[Error] Only A-Z, ?, !, and (SPACE) are valid characters"
    return

  output = ''
  for char in txt:
    charNum = ord(char)
    if charNum == 32:   charNum = 26  # (SPACE)
    elif charNum == 33: charNum = 28  # !
    elif charNum == 63: charNum = 27  # ?
    else:               charNum -= 65 # offset toward 0

    output += '{0:0{1}X}'.format(charNum, 2) + '\n'

  offset = (TXT_MAX_LEN - len(txt))/2
  print "Centering offset:", offset, "characters"
  print "\nResult\n------"
  print output

if __name__ == "__main__":
  main()
