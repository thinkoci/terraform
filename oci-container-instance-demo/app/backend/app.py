#!/usr/bin/env python3
"""Tiny dependency-free JSON API for the OCI Container Instance demo."""

from __future__ import annotations

import json
import os
import socket
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import urlparse

APP_NAME = os.environ.get("APP_NAME", "oci-ci-demo")
PORT = int(os.environ.get("PORT", "8080"))
MAX_BODY_BYTES = 16 * 1024


class ApiHandler(BaseHTTPRequestHandler):
    server_version = "OciContainerDemo/1.0"

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.address_string()} - {fmt % args}", flush=True)

    def _send_json(self, status: HTTPStatus, payload: dict[str, Any]) -> None:
        body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        self.send_response(status.value)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self) -> dict[str, Any]:
        try:
            content_length = int(self.headers.get("Content-Length", "0"))
        except ValueError as exc:
            raise ValueError("Invalid Content-Length header") from exc

        if content_length <= 0:
            raise ValueError("Request body is required")
        if content_length > MAX_BODY_BYTES:
            raise ValueError(f"Request body exceeds {MAX_BODY_BYTES} bytes")

        raw = self.rfile.read(content_length)
        try:
            payload = json.loads(raw.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ValueError("Request body must be valid UTF-8 JSON") from exc

        if not isinstance(payload, dict):
            raise ValueError("JSON body must be an object")
        return payload

    def do_GET(self) -> None:  # noqa: N802 - required by BaseHTTPRequestHandler
        path = urlparse(self.path).path
        common = {
            "service": "python-backend",
            "app": APP_NAME,
            "hostname": socket.gethostname(),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

        if path == "/api/health":
            self._send_json(HTTPStatus.OK, {"status": "ok", **common})
            return

        if path == "/api/message":
            self._send_json(
                HTTPStatus.OK,
                {
                    "message": "Hello from the backend running on OCI Container Instances.",
                    **common,
                },
            )
            return

        self._send_json(HTTPStatus.NOT_FOUND, {"error": "Not found", "path": path})

    def do_POST(self) -> None:  # noqa: N802 - required by BaseHTTPRequestHandler
        path = urlparse(self.path).path
        if path != "/api/echo":
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "Not found", "path": path})
            return

        try:
            payload = self._read_json()
        except ValueError as exc:
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": str(exc)})
            return

        self._send_json(
            HTTPStatus.OK,
            {
                "echo": payload,
                "service": "python-backend",
                "hostname": socket.gethostname(),
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), ApiHandler)
    print(f"Starting {APP_NAME} backend on 0.0.0.0:{PORT}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
