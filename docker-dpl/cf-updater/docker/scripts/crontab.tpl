PATH=$PATH:/usr/local/bin:/usr/bin
*/{{FREQ}} * * * * python3 /app/update-dns.py >> /var/log/cron/update.log 2>&1
