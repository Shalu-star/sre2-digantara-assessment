# Architecture Report for Digantara SRE 2 Assessment

##  Decisions Made

-  Chose **Nginx** as the reverse proxy for compatibility with **Authelia**
-  Used **Docker Compose** for orchestration of services
-  Configured **SSO** using Authelia and `X-Remote-User` headers
-  Setup protected routes and redirection logic for **Gitea** and **Grafana**

##  Challenges Faced

- Cookie domain mismatch issues with Authelia (fixed with correct session config)
- **Grafana** permission errors due to volume ownership (resolved using UID `472`)
- **Gitea**'s header-based login required precise configuration in `[auth]` and reverse proxy (Nginx)

## Improvements If Time Permitted

- Setup **Loki** for Grafana log monitoring and observability
- Use **Terraform** for full EC2 and Docker provisioning (infra-as-code)

## Outcome

All services successfully run and are accessible via:

- Nginx routes to Gitea and Grafana
- Authelia provides a login page and protects access
- After login, users are routed correctly, although Gitea/Grafana login forms remain visible (as expected for this setup)
