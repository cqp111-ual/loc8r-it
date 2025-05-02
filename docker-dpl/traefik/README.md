# Traefik Docker Deployment

This repository contains base deployment examples for Traefik in Docker (*docker compose*).

Before starting, create the external network for Traefik by running the following command:

```bash
docker network create --driver=bridge traefik-proxy
```

All containers that you want to route through Traefik must be connected to this network and have the appropriate labels added.

This setup is ready to handle both HTTPS with certificates and TCP routing with SSL. A basic configuration is already provided.

For more details, refer to the official Traefik documentation: [Traefik Docs](https://doc.traefik.io/traefik/).