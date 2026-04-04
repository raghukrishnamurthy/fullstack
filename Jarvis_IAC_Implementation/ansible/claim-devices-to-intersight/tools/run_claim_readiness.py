#!/usr/bin/env python3
"""Gather claim-readiness data for a single SaaS claim target."""

from __future__ import annotations

import json
import os
from typing import Any
from xml.etree import ElementTree

import requests


def env_bool(name: str, default: bool = False) -> bool:
    raw = os.environ.get(name, "")
    if not raw:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def env_json(name: str, default: Any) -> Any:
    raw = os.environ.get(name, "")
    if not raw.strip():
        return default
    return json.loads(raw)


def first_result(payload: Any) -> dict[str, Any]:
    if isinstance(payload, list):
        return payload[0] if payload else {}
    if isinstance(payload, dict):
        for key in ("Results", "results", "Items", "items"):
            value = payload.get(key)
            if isinstance(value, list) and value:
                return value[0]
        return payload
    return {}


def pick(payload: Any, *keys: str) -> Any:
    item = first_result(payload)
    for key in keys:
        if key in item and item[key] is not None:
            return item[key]
    return None


def normalize_claim_key(serial_number: Any) -> str:
    raw = str(serial_number or "").strip()
    if not raw:
        return ""
    parts = sorted(part.strip() for part in raw.split("&") if part.strip())
    return "&".join(parts)


def useable_credentials(credentials: list[dict[str, Any]]) -> list[dict[str, str]]:
    usable: list[dict[str, str]] = []
    for item in credentials:
        if not isinstance(item, dict):
            continue
        username = str(item.get("username", "")).strip()
        password = str(item.get("password", "")).strip()
        if username and password:
            usable.append({"username": username, "password": password})
    return usable


def http_json(
    session: requests.Session,
    method: str,
    url: str,
    *,
    verify: bool,
    timeout: int,
    **kwargs: Any,
) -> Any:
    response = session.request(method=method, url=url, verify=verify, timeout=timeout, **kwargs)
    response.raise_for_status()
    if not response.content:
        return {}
    return response.json()


def xml_login(
    endpoint: str,
    username: str,
    password: str,
    *,
    verify: bool,
    timeout: int,
) -> tuple[requests.Session, dict[str, str]]:
    session = requests.Session()
    response = session.post(
        f"https://{endpoint}/nuova",
        data=f'<aaaLogin inName="{username}" inPassword="{password}" />',
        verify=verify,
        timeout=timeout,
    )
    response.raise_for_status()
    root = ElementTree.fromstring(response.content)
    cookie = str(root.attrib.get("outCookie", "")).strip()
    if not cookie:
        raise ValueError("XML login did not return outCookie")
    return session, {"ucsmcookie": f"ucsm-cookie={cookie}"}


def xml_logout(
    session: requests.Session,
    endpoint: str,
    headers: dict[str, str],
    *,
    verify: bool,
    timeout: int,
) -> None:
    raw_cookie = str(headers.get("ucsmcookie", "")).replace("ucsm-cookie=", "", 1).strip()
    if not raw_cookie:
        return
    try:
        session.post(
            f"https://{endpoint}/nuova",
            data=f'<aaaLogout inCookie="{raw_cookie}" />',
            verify=verify,
            timeout=timeout,
        )
    except Exception:
        pass


def imm_login(
    endpoint: str,
    username: str,
    password: str,
    *,
    verify: bool,
    timeout: int,
) -> tuple[requests.Session, dict[str, str]]:
    session = requests.Session()
    response = session.post(
        f"https://{endpoint}/Login",
        json={"User": username, "Password": password},
        verify=verify,
        timeout=timeout,
    )
    response.raise_for_status()
    payload = response.json()
    session_id = str(payload.get("SessionId", "")).strip()
    if not session_id:
        raise ValueError("IMM login did not return SessionId")
    return session, {"Cookie": f"sessionId={session_id}"}


def imm_logout(
    session: requests.Session,
    endpoint: str,
    headers: dict[str, str],
    *,
    verify: bool,
    timeout: int,
) -> None:
    request_headers: dict[str, str] = {}
    if str(headers.get("Cookie", "")).strip():
        request_headers["Cookie"] = str(headers["Cookie"])
    csrf = str(session.cookies.get("csrf", "")).strip()
    if csrf:
        request_headers["X-CSRF-Token"] = csrf
    if not request_headers.get("Cookie"):
        return
    try:
        session.post(
            f"https://{endpoint}/Logout",
            headers=request_headers,
            verify=verify,
            timeout=timeout,
        )
    except Exception:
        pass


def connector_payload(
    endpoint: str,
    target: dict[str, Any],
    credentials: list[dict[str, str]],
    *,
    verify: bool,
    timeout: int,
) -> tuple[dict[str, Any], dict[str, Any]]:
    device_type = str(target.get("device_type", "")).strip().lower()
    if device_type not in {"imc", "imm"}:
        return {}, {
            "endpoint": endpoint,
            "device_type": device_type or "unknown",
            "status": "skipped",
            "changed": False,
            "reason": "claim_readiness_not_supported",
            "messages": [f"Claim readiness not required for {device_type or 'unknown'}"],
        }

    failures: list[str] = []
    for credential in credentials:
        session: requests.Session | None = None
        headers: dict[str, str] = {}
        try:
            if device_type == "imc":
                session, headers = xml_login(
                    endpoint,
                    credential["username"],
                    credential["password"],
                    verify=verify,
                    timeout=timeout,
                )
            else:
                session, headers = imm_login(
                    endpoint,
                    credential["username"],
                    credential["password"],
                    verify=verify,
                    timeout=timeout,
                )

            systems = http_json(
                session,
                "GET",
                f"https://{endpoint}/connector/Systems",
                verify=verify,
                timeout=timeout,
                headers=headers,
            )
            system = first_result(systems)
            ownership = pick(system, "AccountOwnershipState", "AccountOwnershipStatus")
            connection = pick(system, "ConnectionState", "ConnectionStatus")
            enabled = str(pick(system, "AdminState", "Adminstate", "Enabled") or "").strip().lower()

            identifiers = http_json(
                session,
                "GET",
                f"https://{endpoint}/connector/DeviceIdentifiers",
                verify=verify,
                timeout=timeout,
                headers=headers,
            )
            serial_number = pick(identifiers, "Id", "SerialNumber", "Identifier", "serial_number")

            token = ""
            claimed = str(ownership or "").strip().lower() not in {"", "not claimed"}
            if not claimed:
                tokens = http_json(
                    session,
                    "GET",
                    f"https://{endpoint}/connector/SecurityTokens",
                    verify=verify,
                    timeout=timeout,
                    headers=headers,
                )
                token = str(pick(tokens, "Token", "SecurityToken", "security_token") or "").strip()

            result = {
                "endpoint": endpoint,
                "device_type": device_type or "unknown",
                "changed": False,
                "connection_state": connection,
                "account_ownership_state": ownership,
                "connector_enabled": enabled in {"1", "true", "yes", "on", "enabled", "enable"},
                "normalized_claim_key": normalize_claim_key(serial_number),
                "claim_serial_number_present": bool(str(serial_number or "").strip()),
                "claim_security_token_present": bool(token),
            }

            if claimed and str(serial_number or "").strip():
                updated = dict(target)
                updated["claim_serial_number"] = str(serial_number).strip()
                updated["normalized_claim_key"] = normalize_claim_key(serial_number)
                updated["claim_security_token"] = ""
                updated["connection_state"] = connection
                updated["account_ownership_state"] = ownership
                updated["connector_enabled"] = result["connector_enabled"]
                updated["claim_submission_required"] = False
                return updated, {
                    **result,
                    "status": "already_claimed",
                    "reason": "connector_reports_already_claimed",
                    "messages": ["Connector reports the device is already claimed"],
                }

            if not str(serial_number or "").strip() or not token:
                return {}, {
                    **result,
                    "status": "failed",
                    "reason": "claim_readiness_incomplete",
                    "messages": ["Connector did not return both serial and security token"],
                }

            updated = dict(target)
            updated["claim_serial_number"] = str(serial_number).strip()
            updated["normalized_claim_key"] = normalize_claim_key(serial_number)
            updated["claim_security_token"] = token
            updated["connection_state"] = connection
            updated["account_ownership_state"] = ownership
            updated["connector_enabled"] = result["connector_enabled"]
            updated["claim_submission_required"] = True
            return updated, {
                **result,
                "status": "ready_for_claim",
                "reason": "claim_readiness_retrieved",
                "messages": ["Claim readiness retrieved successfully"],
            }
        except Exception as exc:
            failures.append(str(exc))
        finally:
            if session is not None:
                if device_type == "imc":
                    xml_logout(session, endpoint, headers, verify=verify, timeout=timeout)
                else:
                    imm_logout(session, endpoint, headers, verify=verify, timeout=timeout)
                session.close()

    return {}, {
        "endpoint": endpoint,
        "device_type": device_type or "unknown",
        "status": "failed",
        "changed": False,
        "reason": "claim_readiness_retrieval_failed",
        "messages": failures or ["Claim readiness retrieval failed for all provided credentials"],
    }


def main() -> None:
    endpoint = str(os.environ.get("ENDPOINT", "")).strip()
    prepared_targets = env_json("PREPARED_TARGETS_JSON", [])
    desired_credentials = useable_credentials(env_json("DESIRED_CREDENTIALS_JSON", []))
    verify = env_bool("VALIDATE_CERTS", default=False)
    timeout = int(str(os.environ.get("TIMEOUT", "20")).strip() or "20")

    target = next(
        (
            item
            for item in prepared_targets
            if isinstance(item, dict) and str(item.get("endpoint", "")).strip() == endpoint
        ),
        None,
    )
    if target is None:
        print(
            json.dumps(
                {
                    "claim_ready_target": {},
                    "result": {
                        "endpoint": endpoint,
                        "status": "failed",
                        "changed": False,
                        "reason": "prepared_target_missing",
                        "messages": ["Prepared target metadata was not available for this host"],
                    },
                }
            )
        )
        return

    ready_target, result = connector_payload(
        endpoint,
        target,
        desired_credentials,
        verify=verify,
        timeout=timeout,
    )
    print(json.dumps({"claim_ready_target": ready_target, "result": result}))


if __name__ == "__main__":
    main()
