# cf-updater

A Docker container that periodically checks and updates Cloudflare's DNS records.

## Usage

1. **Define your configuration**  
   Create a file `config.json` based on `config.json.example`. You will need to define your [Cloudflare API Token with Edit DNS permissions](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/).
<br>

2. **Set periodicity with the `UPDATE_FREQ` environment variable**  
   Define how frequently the DNS records will be checked and updated. Minimum: 1 minute, Maximum: 30 minutes. Default: 5 minutes.
<br>

3. **Deploy locally**  
   Use the provided `docker-compose.yml` file to build and deploy the container. Run the following command to start the container:

 ```bash
 docker-compose up --build -d
 ```
