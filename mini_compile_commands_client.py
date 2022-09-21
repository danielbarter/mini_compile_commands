#! @python@

import socket
import sys

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    client.connect(unix_socket_file)

    for i in range(3):
        client.send(sys.argv[1].encode('utf-8'))

    client.close()
