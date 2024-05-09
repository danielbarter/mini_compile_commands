#! @python@/bin/python

import os
import re
import sys
from pathlib import Path

directory = Path(sys.argv[1]).absolute()

keep_regex_raw = os.getenv("MCC_KEEP_REGEXP")

if keep_regex_raw is not None:
    keep_regex = keep_regex_raw.replace("\n", "")
else:
    keep_regex = r".*\.cc$|.*\.c$|.*\.cpp$|.*\.cxx$|.*\.h$|.*\.hh$|.*\.m$"

keep_regex_comp = re.compile(keep_regex)


for dirpath, dirnames, filenames in os.walk(directory, topdown=False):
    p = Path(dirpath)
    p_rel = p.relative_to(directory)
    for filename in filenames:
        if not keep_regex_comp.search(str(p_rel / filename)):
            os.remove(p / filename)

    # dont remove the root build folder
    if not os.listdir(p) and not p.samefile(directory):
        p.rmdir()
