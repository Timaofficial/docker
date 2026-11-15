
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ("/", "/health"):
            self.send_error(404)
            return

        body = json.dumps({
            "status": "online",
            "service": "Lapio Plays",
            "sshx": "running"
        }).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print("[HTTP]", fmt % args)


port = int(os.environ.get("PORT", "10000"))

server = ThreadingHTTPServer(("0.0.0.0", port), Handler)

print(f"[HTTP] Health server listening on 0.0.0.0:{port}", flush=True)
server.serve_forever()
