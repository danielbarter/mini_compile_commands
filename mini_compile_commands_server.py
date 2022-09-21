#! @python@

from socketserver import UnixStreamServer, StreamRequestHandler
import os

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"

if os.path.isfile(unix_socket_file):
    os.remove(unix_socket_file)

class Handler(StreamRequestHandler):
    def handle(self):
        msg = self.rfile.read()
        print("added compile command:", msg)
        self.server.compile_commands.append(msg)

class Server(UnixStreamServer):


    def __init__(self, server_address, RequestHandlerClass):
        super().__init__(server_address, RequestHandlerClass)
        self.compile_commands = []

    def server_close(self):
        print(self.compile_commands)

with Server(unix_socket_file, Handler) as server:
    server.serve_forever()
