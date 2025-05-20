import json
import os
import subprocess
import requests
from datetime import datetime

CONFIG_FILE = "/app/config.json"

# === Logging con timestamp y etiqueta ===
def log(message, level="info"):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [{level.upper()}] {message}")

# === Cargar configuración desde JSON ===
def load_config(path):
    if not os.path.exists(path):
        log(f"Config file not found: {path}", "error")
        return None
    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception as e:
        log(f"Error loading config: {e}", "error")
        return None

# === Obtener IP desde source ===
def resolve_source_ip(source):
    if source["type"] == "ip":
        return source["input"]
    elif source["type"] == "name":
        try:
            result = subprocess.run(["dig", "+short", source["input"]],
                                    capture_output=True, text=True)
            ip = result.stdout.strip().split("\n")[0]
            if ip:
                return ip
            else:
                log(f"No IP resolved for {source['input']}", "error")
        except Exception as e:
            log(f"Error resolving IP from name: {e}", "error")
    elif source["type"] == "cmd":
        try:
            result = subprocess.run(source["input"], shell=True, capture_output=True, text=True)
            ip = result.stdout.strip()
            if ip:
                return ip
            else:
                log(f"No IP resolved from command: {source['input']}", "error")
        except Exception as e:
            log(f"Error resolving IP from command: {e}", "error")
    else:
        log(f"Invalid source type: {source['type']}", "error")
    return None

# === Obtener zone_id desde Cloudflare ===
def get_zone_id(zone, headers):
    url = "https://api.cloudflare.com/client/v4/zones"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        zones = response.json().get("result", [])
        for z in zones:
            if z["name"] == zone:
                return z["id"]
    log(f"Error retrieving zone ID: {response.json()}", "error")
    return None

# === Obtener record_id desde Cloudflare ===
def get_dns_record_id(zone_id, record_name, headers):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        records = response.json().get("result", [])
        for record in records:
            if record["name"] == record_name:
                return record["id"], record["content"]
    log(f"Error retrieving DNS record ID: {response.json()}", "error")
    return None, None

# === Actualizar registro DNS ===
def update_dns_record(zone_id, record_id, record_name, new_ip, headers):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    data = {
        "type": "A",
        "name": record_name,
        "content": new_ip,
        "ttl": 1,
        "proxied": False
    }
    response = requests.put(url, headers=headers, json=data)
    if response.status_code == 200:
        log(f"Updated DNS record {record_name} to {new_ip}", "success")
    else:
        log(f"Failed to update DNS record {record_name}: {response.json()}", "error")

# === Main logic ===
def main():
    print(f"---------------------------------------------------")
    config = load_config(CONFIG_FILE)
    if not config:
        return

    api_token = config.get("api_token")
    entries = config.get("entries", [])
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }

    for entry in entries:
        source = entry.get("source")
        zone = entry.get("zone")
        record = entry.get("record")

        if not source or not zone or not record:
            log("Missing required fields in entry.", "error")
            continue

        source_ip = resolve_source_ip(source)
        if not source_ip:
            continue

        log(f"Resolved source IP for {record}: {source_ip}", "info")

        zone_id = get_zone_id(zone, headers)
        if not zone_id:
            continue

        record_id, current_ip = get_dns_record_id(zone_id, record, headers)
        if not record_id:
            continue

        if current_ip == source_ip:
            log(f"No update needed for {record}; IP unchanged ({source_ip})", "info")
        else:
            log(f"Updating {record} from {current_ip} to {source_ip}", "info")
            update_dns_record(zone_id, record_id, record, source_ip, headers)
    print(f"---------------------------------------------------")

if __name__ == "__main__":
    main()

