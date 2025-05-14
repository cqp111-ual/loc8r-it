# Sonarqube

This container requires lots of resources (minimum 3g RAM)

```bash
sudo sysctl -w vm.max_map_count=262144
```

Create directory for sonarqube data with the right permissions:

```bash
mkdir sonarqube
sudo chown -R 1000:1000 sonarqube/
```

Set limits to at least:

```bash
mem_limit: 4g
cpus: 2
```
