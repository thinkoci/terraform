#!/usr/bin/env python3
"""Read non-secret OCI profile metadata for Terraform's external data source."""

from __future__ import annotations

import configparser
import json
import os
import sys
from pathlib import Path
from typing import NoReturn


def fail(message: str) -> NoReturn:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    try:
        query = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        fail(f"Could not parse Terraform external-data input: {exc}")

    config_path = Path(os.path.expanduser(str(query.get("config_file", "~/.oci/config"))))
    profile = str(query.get("profile", "DEFAULT")).strip() or "DEFAULT"

    if not config_path.is_file():
        fail(
            f"OCI config file not found at {config_path}. "
            "Create it with 'oci setup config' or copy your working config to ~/.oci/config."
        )

    parser = configparser.ConfigParser(interpolation=None)
    try:
        with config_path.open("r", encoding="utf-8") as handle:
            parser.read_file(handle)
    except (OSError, configparser.Error) as exc:
        fail(f"Could not read OCI config file {config_path}: {exc}")

    if profile == "DEFAULT":
        values = parser.defaults()
    elif parser.has_section(profile):
        values = parser[profile]
    else:
        available = ["DEFAULT", *parser.sections()]
        fail(
            f"OCI profile '{profile}' was not found in {config_path}. "
            f"Available profiles: {', '.join(available)}"
        )

    required = ("tenancy", "user", "fingerprint", "key_file", "region")
    missing = [key for key in required if not str(values.get(key, "")).strip()]
    if missing:
        fail(
            f"OCI profile '{profile}' in {config_path} is missing: {', '.join(missing)}"
        )

    key_file = Path(os.path.expanduser(str(values["key_file"]).strip()))
    if not key_file.is_absolute():
        key_file = config_path.parent / key_file
    if not key_file.is_file():
        fail(f"OCI private key file referenced by profile '{profile}' was not found: {key_file}")

    result = {
        "tenancy": str(values["tenancy"]).strip(),
        "region": str(values["region"]).strip(),
        "profile": profile,
    }
    json.dump(result, sys.stdout)


if __name__ == "__main__":
    main()
