#! @python@/bin/python

from socketserver import UnixStreamServer, StreamRequestHandler
from time import localtime, strftime
import signal
import os
import sys
import pickle
import json

if len(sys.argv) == 1:
    compile_commands_output = "compile_commands.json"

elif len(sys.argv) == 2:
    compile_commands_output = sys.argv[1]

elif len(sys.argv) > 2:
    print("usage: mini_compile_commands_client.py compile_commands.json")
    sys.exit(1)

unix_socket_file = "/tmp/mini_compile_commands_unix_socket"

def log_message(*args, **kwargs):
    print(
        '[' + strftime('%H:%M:%S', localtime()) + ']',
        *args, **kwargs)

class Handler(StreamRequestHandler):
    def handle(self):
        compile_commands_binary = self.rfile.read()
        compile_commands = pickle.loads(compile_commands_binary)
        log_message("recived {} compile commands".format(len(compile_commands)))
        self.server.compile_commands.extend(compile_commands)

class Server(UnixStreamServer):

    def __init__(self, server_address, RequestHandlerClass):
        try:
            super().__init__(server_address, RequestHandlerClass)
        except:
            raise Exception(
                f'''
                Failed to initialize the server. This is most likely happening
                because the unix socket file already exists. Either
                1. mini_compile_commands_server.py shut down abnormally at some point
                2. there is already a mini_compile_commands_server.py instance running
                Remove {unix_socket_file} and try again
                '''
            )
        self.compile_commands = []

    def server_close(self):
        with open(compile_commands_output, 'w') as f:
            f.write(json.dumps(self.compile_commands, indent=4))
            f.write('\n')

        super().server_close()

server = Server(unix_socket_file, Handler)
print("awaiting compile commands...")

def signal_handler(sig, frame):
    print('')
    server.server_close()
    os.remove(unix_socket_file)
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

server.serve_forever()
