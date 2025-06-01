# Architecture Report for Digantara SRE 2 Assessment

## Environment Setup and Learning Curve

- I had no prior hands-on experience with Gitea, Authelia, Grafana, or Nginx.
- Initially launched a `t2.micro` EC2 instance, but it failed to support multiple containers due to limited resources. After analysis, I upgraded to a `t3.small` instance which resolved the container crash issue.
- Spent time understanding the role of reverse proxies, cookie-based session management, and SSO headers to integrate Authelia with Gitea and Grafana.
- Faced numerous technical hurdles but overcame them by reading documentation, debugging logs, and experimenting iteratively.

## Decisions Made

- Chose **Nginx** as the reverse proxy for compatibility with **Authelia**
- Used **Docker Compose** for orchestration of services
- Configured **SSO** using Authelia and `X-Remote-User` headers
- Setup protected routes and redirection logic for **Gitea** and **Grafana**

## Challenges Faced

- Cookie domain mismatch issues with Authelia (fixed with correct session config)
- **Grafana** permission errors due to volume ownership (resolved using UID `472`)
- **Gitea**'s header-based login required precise configuration in `[auth]` and reverse proxy (Nginx)

## Improvements If Time Permitted

- Setup **Loki** for Grafana log monitoring and observability
- Use **Terraform** for full EC2 and Docker provisioning (infra-as-code)

## Outcome

All services successfully run and are accessible via:

- Nginx routes to **Gitea** (`/gitea`) and **Grafana** (`/grafana`)
- **Authelia** protects access via login screen (`shalu` / `MyNewPass@123`)
- Post-login behavior:
  - Access to **Grafana dashboard** as user `shalu` is working and visible
  - **Gitea** explore page is reachable
