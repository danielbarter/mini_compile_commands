#! @python@

from socketserver import UnixStreamServer, StreamRequestHandler
import os

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"

os.unlink(unix_socket_file)

class Handler(StreamRequestHandler):
    def handle(self):
        while True:
            msg = self.rfile.readline().strip()
            if msg:
                print("Data recived from client is: {}".format(msg))
            else:
                return


with UnixStreamServer(unix_socket_file, Handler) as server:
    server.serve_forever()
