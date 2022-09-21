#! @python@

import socket
import time

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    client.connect(unix_socket_file)

    while True:
        client.send(b"aaa\n")
        time.sleep(1)

    client.close()
