# Digantara SRE 2 Assessment – Self-Hosted Gitea & Grafana with SSO via Authelia (Deployed on AWS EC2)

## Services Used

- **Gitea** – Git repository management  
- **Grafana** – Monitoring and dashboards  
- **Authelia** – Single Sign-On (SSO) authentication  
- **Nginx** – Reverse proxy  
- **Docker** – Container orchestration  
- **Terraform** – Infrastructure provisioning on AWS EC2  

---

## Features

- Secure access to Gitea and Grafana via Authelia-based SSO  
- Reverse proxy routing handled by Nginx  
- AWS EC2 hosting via Terraform (`terraform/main.tf`)  
- Docker Compose-based container setup for all services  
- TLS (HTTPS) enabled using self-signed certificates  

---

## Hosting on AWS EC2 via Terraform

To provision an EC2 instance and automatically install Docker:

1. Ensure AWS credentials are configured locally using `aws configure`.
2. Update the `key_name` and `private_key` path in `terraform/main.tf`.
3. Navigate to the `terraform` directory and run:

```bash
terraform init
terraform plan
terraform apply

Once the instance is ready, connect:

ssh -i ~/.ssh/<your-key>.pem ubuntu@<ec2-public-ip>
```
---
## Setup Instructions on EC2

```bash
# Clone the repo
git clone https://github.com/Shalu-star/sre2-digantara-assessment.git
cd sre2-digantara-assessment

# Set correct permissions
sudo chown -R 472:472 ./grafana
sudo chown -R ubuntu:ubuntu gitea

# Generate SSL certificates
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/privkey.pem \
  -out ssl/fullchain.pem \
  -subj "/CN=<ec2-public-ip>" 

# Start all services
docker-compose up -d
```
---

## Access URLs

- https://<ec2-public-ip>/ → Authelia Login
- https://<ec2-public-ip>/gitea/ → Gitea
- https://<ec2-public-ip>/grafana/ → Grafana

---

## Auth Credentials

Defined in authelia/config/users_database.yml:

users:
  shalu:
    displayname: "Shalu"
    password: <argon2id-hash>
    email: shalu@example.com
    groups:
      - admins

To generate password hash for users:
docker run --rm authelia/authelia authelia crypto hash generate bcrypt --password <your password> --no-confirm

---

## Architecture Overview

Nginx acts as a reverse proxy and handles all HTTPS requests. It routes requests to:

- `/gitea/` → Gitea container
- `/grafana/` → Grafana container
- `/authelia/` → Authelia login and APIs

### Auth Flow:

1. User visits a protected route (e.g., `/grafana/`)
2. Nginx sends a verification request to `/authelia_auth_verify`
3. If not authenticated, user is redirected to `/authelia/` login
4. Upon login, Authelia sets a session cookie
5. Nginx forwards the request to the target service along with `X-Remote-*` headers

---

## Configuration Files

- `authelia/config/configuration.yml`
- `authelia/config/users_database.yml`
- `nginx/nginx.conf`
- `gitea/gitea/conf/app.ini` - (SECRET/ACCESS tokens via openssl rand -hex 32)
- `docker-compose.yml`
- `terraform/main.tf`

---

## Final Result

- **Grafana**: Authenticated user (`shalu`) is able to access the full dashboard interface after login.
- **Gitea**: After login via Authelia, users are redirected to the **Explore** page (public view); Gitea’s internal login is disabled as per SSO flow.
- The SSO redirection, cookie validation, and header forwarding all work as intended.

---

## Known Limitations

- Native login UIs for Gitea and Grafana still appear but are bypassed via Authelia SSO flow.
- Username/password login is **intentionally rejected** on these UIs; access is controlled by Authelia.