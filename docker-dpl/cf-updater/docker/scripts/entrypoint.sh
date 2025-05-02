#!/bin/bash

# Validar frecuencia
if ! [[ "$UPDATE_FREQ" =~ ^[0-9]+$ ]] || [ "$UPDATE_FREQ" -lt 1 ] || [ "$UPDATE_FREQ" -gt 30 ]; then
  echo "[error] Invalid UPDATE_FREQ='$UPDATE_FREQ'. Using default value of 5." >&2
  UPDATE_FREQ=5
fi

echo "[info] Starting cron with UPDATE_FREQ=${UPDATE_FREQ} minutes."

# Generar crontab a partir de plantilla
sed "s/{{FREQ}}/${UPDATE_FREQ}/" /app/crontab.tpl > /etc/cron.d/dns-cron

# Dar permisos y cargar cron
chmod 0644 /etc/cron.d/dns-cron
crontab /etc/cron.d/dns-cron

# Lanzar cron
cron && tail -f /var/log/cron/update.log
