#! @python@/bin/python

import socket
import sys
import pickle
import re

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"
directory = sys.argv[1]
command = sys.argv[2::]

c_file_regex = re.compile(r'.*\.cc$|.*\.c$|.*\.cpp$|.*\.cxx$')
c_files = [ word for word in command if c_file_regex.search(word) ]
compile_commands = []

for c_file in c_files:
    compile_commands.append(
        { 'directory' : directory,
          'arguments' : command,
          'file' : c_file
        }
    )

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    try:
        client.connect(unix_socket_file)

        for i in range(3):
            client.send(pickle.dumps(compile_commands))

        client.close()

    except FileNotFoundError:
        print("Error: can't find {}. Is mini_compile_commands_server.py running?"
              .format(unix_socket_file))
