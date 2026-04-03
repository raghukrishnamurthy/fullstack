#!/usr/bin/env python3
"""Check and reset Cisco IMC rack passwords from manufacturing to desired state."""

from __future__ import annotations

import json
import os
from typing import Any

import requests


def parse_bool(value: str | None, default: bool = False) -> bool:
    """Normalize string-like booleans from environment variables."""
    if value is None or value == "":
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def load_json_env(name: str, default: Any) -> Any:
    """Load a JSON environment variable into Python objects."""
    value = os.environ.get(name, "")
    if not value:
        return default
    return json.loads(value)


def request(
    session: requests.Session,
    method: str,
    url: str,
    *,
    verify_ssl: bool,
    timeout: int,
    **kwargs: Any,
) -> requests.Response | None:
    """Perform a best-effort HTTP request and return None on transport failure."""
    try:
        return session.request(method=method, url=url, verify=verify_ssl, timeout=timeout, **kwargs)
    except requests.exceptions.RequestException:
        return None


def redfish_account_uri(account_id: str = "1") -> str:
    """Return the default Redfish account resource for IMC targets."""
    return f"/redfish/v1/AccountService/Accounts/{account_id}"


def query_redfish_root(host: str, *, verify_ssl: bool, timeout: int) -> tuple[int | None, dict[str, Any], str]:
    """Read the Redfish service root."""
    session = requests.Session()
    response = request(session, "GET", f"https://{host}/redfish/v1", verify_ssl=verify_ssl, timeout=timeout)
    if response is None:
        return None, {}, "request_error"
    payload: dict[str, Any] = {}
    if response.content:
        try:
            payload = response.json()
        except ValueError:
            payload = {}
    return response.status_code, payload, ""


def is_cisco_imc_redfish_root(payload: dict[str, Any]) -> bool:
    """Detect Cisco IMC-style Redfish roots."""
    vendor = str(payload.get("Vendor", "")).strip().lower()
    product = str(payload.get("Product", "")).strip().upper()
    return vendor.startswith("cisco systems inc") and product.startswith("UCSC-")


def query_account(
    host: str,
    username: str,
    password: str,
    *,
    verify_ssl: bool,
    timeout: int,
) -> tuple[int | None, dict[str, Any], str]:
    """Read the default account object using Redfish basic auth."""
    session = requests.Session()
    response = request(
        session,
        "GET",
        f"https://{host}{redfish_account_uri()}",
        verify_ssl=verify_ssl,
        timeout=timeout,
        auth=(username, password),
    )
    if response is None:
        return None, {}, "request_error"
    payload: dict[str, Any] = {}
    if response.content:
        try:
            payload = response.json()
        except ValueError:
            payload = {}
    return response.status_code, payload, ""


def patch_password(
    host: str,
    username: str,
    password: str,
    new_password: str,
    *,
    verify_ssl: bool,
    timeout: int,
) -> tuple[int | None, str]:
    """Apply the desired password to the default Redfish account."""
    session = requests.Session()
    response = request(
        session,
        "PATCH",
        f"https://{host}{redfish_account_uri()}",
        verify_ssl=verify_ssl,
        timeout=timeout,
        auth=(username, password),
        headers={"Content-Type": "application/json"},
        json={"Password": new_password},
    )
    if response is None:
        return None, "request_error"
    return response.status_code, ""


def print_result(payload: dict[str, Any]) -> None:
    """Emit a JSON-safe result for the playbook to aggregate."""
    print(json.dumps(payload))


def main() -> None:
    """Evaluate rack password state and change to the desired password when needed."""
    endpoint = str(os.environ.get("ENDPOINT", "")).strip()
    target_id = str(os.environ.get("TARGET_ID", "")).strip()
    serial = str(os.environ.get("TARGET_SERIAL", "")).strip()
    desired = load_json_env("DESIRED_CREDENTIAL_JSON", {})
    manufacturing = load_json_env("MANUFACTURING_CREDENTIAL_JSON", {})
    verify_ssl = parse_bool(os.environ.get("VALIDATE_CERTS"), default=False)
    timeout = int(os.environ.get("TIMEOUT", "20"))

    desired_username = str(desired.get("username", "")).strip()
    desired_password = str(desired.get("password", "")).strip()
    manufacturing_username = str(manufacturing.get("username", "")).strip()
    manufacturing_password = str(manufacturing.get("password", "")).strip()

    if not endpoint:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "missing_endpoint",
                "messages": ["No endpoint was supplied for rack password reset."],
            }
        )
        return

    if not desired_username or not desired_password:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "desired_credential_missing",
                "messages": ["No usable desired rack credential was supplied."],
            }
        )
        return

    redfish_root_status, redfish_root_payload, redfish_root_error = query_redfish_root(
        endpoint,
        verify_ssl=verify_ssl,
        timeout=timeout,
    )
    redfish_root_vendor = str(redfish_root_payload.get("Vendor", "")).strip()
    redfish_root_product = str(redfish_root_payload.get("Product", "")).strip()

    if redfish_root_status != 200 or not is_cisco_imc_redfish_root(redfish_root_payload):
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "non_imc_redfish_target",
                "messages": ["The endpoint did not match the Cisco IMC Redfish fingerprint."],
                "redfish_root_status": redfish_root_status,
                "redfish_root_error": redfish_root_error,
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    desired_status, desired_payload, desired_error = query_account(
        endpoint,
        desired_username,
        desired_password,
        verify_ssl=verify_ssl,
        timeout=timeout,
    )
    if desired_status == 200:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "ready",
                "changed": False,
                "reason": "desired_password_already_active",
                "messages": ["Desired credential already works for the Redfish account."],
                "password_change_required": bool(desired_payload.get("PasswordChangeRequired", False)),
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    if not manufacturing_username or not manufacturing_password:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "manufacturing_credential_missing",
                "messages": ["Desired credential is not active and no manufacturing credential was supplied."],
                "desired_precheck_status": desired_status,
                "desired_precheck_error": desired_error,
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    default_status, default_payload, default_error = query_account(
        endpoint,
        manufacturing_username,
        manufacturing_password,
        verify_ssl=verify_ssl,
        timeout=timeout,
    )
    if default_status != 200:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "manufacturing_login_failed",
                "messages": ["Manufacturing credential could not read the Redfish account resource."],
                "desired_precheck_status": desired_status,
                "desired_precheck_error": desired_error,
                "manufacturing_precheck_status": default_status,
                "manufacturing_precheck_error": default_error,
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    if not bool(default_payload.get("PasswordChangeRequired", False)):
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "default_password_active_without_forced_change",
                "messages": ["Manufacturing credential worked, but Redfish did not report PasswordChangeRequired."],
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    patch_status, patch_error = patch_password(
        endpoint,
        manufacturing_username,
        manufacturing_password,
        desired_password,
        verify_ssl=verify_ssl,
        timeout=timeout,
    )
    if patch_status not in {200, 204}:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "failed",
                "changed": False,
                "reason": "password_reset_failed",
                "messages": [patch_error or f"Unexpected Redfish patch status {patch_status}"],
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    verify_status, _, verify_error = query_account(
        endpoint,
        desired_username,
        desired_password,
        verify_ssl=verify_ssl,
        timeout=timeout,
    )
    if verify_status == 200:
        print_result(
            {
                "target_id": target_id,
                "serial": serial,
                "endpoint": endpoint,
                "status": "changed",
                "changed": True,
                "reason": "password_reset_completed",
                "messages": ["Password change requirement was detected and the desired password was applied."],
                "redfish_root_vendor": redfish_root_vendor,
                "redfish_root_product": redfish_root_product,
            }
        )
        return

    print_result(
        {
            "target_id": target_id,
            "serial": serial,
            "endpoint": endpoint,
            "status": "failed",
            "changed": True,
            "reason": "password_reset_verification_failed",
            "messages": [verify_error or f"Desired credential verification failed with status {verify_status}"],
            "redfish_root_vendor": redfish_root_vendor,
            "redfish_root_product": redfish_root_product,
        }
    )


if __name__ == "__main__":
    main()
