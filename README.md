# Digantara SRE 2 Assessment – Self-Hosted Gitea & Grafana with SSO via Authelia

## Services Used

- **Gitea** – Git repository management
- **Grafana** – Monitoring and dashboards
- **Authelia** – Single Sign-On (SSO) authentication
- **Nginx** – Reverse proxy
- **Docker** – Container orchestration
- **Terraform** – (Optional) Infrastructure provisioning

---

## Features

- Secure access to Gitea and Grafana using Authelia
- Reverse proxy routing via Nginx
- SSO login using Authelia as the identity provider
- Fully containerized using Docker Compose
- Successful login and access to Grafana dashboard
- Gitea protected by Authelia and redirected to Explore page after login

---

## Access Credentials

Authelia User:
- **Username**: `shalu`
- **Password**: `MyNewPass@123`

---

## Deployment Instructions

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
  -subj "/CN=3.110.86.116"  # CN = public IP of the EC2 instance

# Start all services
docker-compose up -d
```

---

## Access URLs

- https://3.110.86.116/
- https://3.110.86.116/gitea/
- https://3.110.86.116/grafana/

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
- `gitea/gitea/conf/app.ini`
- `docker-compose.yml`

---

## Final Result

- **Grafana**: Authenticated user (`shalu`) is able to access the full dashboard interface after login.
- **Gitea**: After login via Authelia, users are redirected to the **Explore** page (public view); Gitea’s internal login is disabled as per SSO flow.
- The SSO redirection, cookie validation, and header forwarding all work as intended.

---

## Known Limitations

- Native login UIs for Gitea and Grafana still appear but are bypassed via Authelia SSO flow.
- Username/password login is **intentionally rejected** on these UIs; access is controlled by Authelia.