# FullStack-Blogging-App

Comprehensive guide for the FullStack Blogging App (Spring Boot + Thymeleaf) and associated DevOps artifacts (Docker, Helm, Terraform for EKS, Jenkins pipeline).

---

## Project summary

- Name: twitter-app (artifactId: `twitter-app`, version `0.0.3`)
- Stack: Java 17, Spring Boot 3.x, Thymeleaf, H2 (file-backed for dev), Spring Data JPA, Spring Security
- Packaging: Maven (`mvnw` wrapper present)
- Container images: Docker images built from `Dockerfile` or `Dockerfile.multi` and pushed to Docker Hub (`abrahimcse/bloggingapp:latest` by default in CI)
- Kubernetes: Helm chart at `k8s/helm/FullStack-Blogging-App` and a fallback manifest `deployment-service.yml`
- Infrastructure: Terraform configs under `EKS_Terraform` to provision an EKS cluster
- CI/CD: Jenkins pipeline defined in `Jenkinsfile` (build, test, scan, build/push image, deploy to Kubernetes)

---

## Table of contents

- Prerequisites
- Quick local development
- Build and run with Docker
- Multi-stage build (recommended for CI)
- Deploy to Kubernetes (Helm)
- Provision EKS with Terraform (high level)
- CI/CD (Jenkinsfile overview)
- Project structure
- Troubleshooting & notes
- Contributing
- License

---

## Prerequisites

- Java 17
- Maven 3.x (or use the included `mvnw` / `mvnw.cmd`)
- Docker (if building images)
- kubectl and Helm (for Kubernetes/Helm deploys)
- Terraform >= 1.3 (for the `EKS_Terraform` folder)
- AWS CLI (when provisioning or using EKS)

If you plan to use the Jenkins pipeline as-is you'll also need a Jenkins instance configured with the tools and credentials referenced in `Jenkinsfile` (jdk, maven, SonarQube, Docker registry credentials, kube creds, etc.).

---

## Quick local development

Run the application locally (dev profile uses a file-backed H2 DB):

```bash
cd FullStack-Blogging-App
# Using the included wrapper (Unix/Linux/macOS)
./mvnw spring-boot:run

# or build and run the jar
./mvnw package -DskipTests
java -jar target/*.jar
```

App defaults to port 8080. H2 console is enabled at `/h2-console` (see `src/main/resources/application.properties`).

Notes:
- Development uses `spring.jpa.hibernate.ddl-auto=create` so the schema is created on startup. This is fine for local/dev but remove or replace with migrations for production.

---

## Build and run with Docker

Simple 2-step build and run (local):

```bash
# from project root
docker build -t yourusername/bloggingapp:local -f Dockerfile .
docker run --rm -p 8080:8080 yourusername/bloggingapp:local
```

The `Dockerfile` expects the JAR under `target/*.jar`. Use the multi-stage `Dockerfile.multi` when you want Docker to build the app inside a Maven image (recommended for CI):

```bash
docker build -t yourusername/bloggingapp:local -f Dockerfile.multi .
```

Replace `yourusername` with your registry/user or the production image repository.

---

## Multi-stage build (CI-friendly)

`Dockerfile.multi` builds the app using Maven in the first stage and produces a small runtime image in the second stage. This keeps CI artifacts small and reproducible.

Recommended: use `Dockerfile.multi` in your CI pipeline so builds are consistent and don't rely on host tooling.

---

## Deploy to Kubernetes (Helm)

The Helm chart is located at `k8s/helm/FullStack-Blogging-App`.

Default values are in `k8s/helm/FullStack-Blogging-App/values.yaml`. By default the chart uses the image `abrahimcse/bloggingapp:latest` and creates a `LoadBalancer` service.

To install with Helm:

```bash
# from repository root
helm upgrade --install bloggingapp ./k8s/helm/FullStack-Blogging-App -n webapps --create-namespace \
  --set image.repository=<your-registry>/bloggingapp --set image.tag=<tag>
```

Fallback (kubectl):

```bash
kubectl apply -f deployment-service.yml
```

Verify:

```bash
kubectl get pods -n webapps
kubectl get svc -n webapps
```

---

## Provisioning EKS with Terraform (high level)

Terraform configs live under `EKS_Terraform/`. The repo includes a `README-TERRAFORM.md` with local usage tips. Important points:

- Do NOT commit `.terraform` or provider binaries; they are local artifacts and can be large. The repo already contains guidance and a `.gitignore` to prevent this.
- Recommended workflow:
  1. Configure AWS credentials (environment or `aws configure`).
  2. Optionally configure an S3 backend + DynamoDB for locking in `main.tf`.
  3. Run `terraform init`, `terraform plan -out eks.plan`, then `terraform apply "eks.plan"`.
  4. Use the Terraform outputs to run `aws eks update-kubeconfig ...` so you can use kubectl.

See `EKS_Terraform/README-TERRAFORM.md` for specific commands and security notes.

---

## CI/CD (Jenkinsfile overview)

The `Jenkinsfile` defines a multi-stage pipeline (checkout, compile, test, static scans, SonarQube, package, deploy to Nexus, build & scan Docker image, push image, deploy to cluster). Key notes:

- It expects configured Jenkins tools (JDK 17, Maven 3, Sonar Scanner) and credentials (`git-cred`, `docker-cred`, `k8-cred`, `sonar-token`).
- Image pushed in pipeline: `abrahimcse/bloggingapp:latest` (update this to your registry in your Jenkins credentials/vars).
- Deploy step prefers Helm but falls back to `kubectl apply -f deployment-service.yaml`.

When configuring Jenkins, ensure secrets and access to Docker registry and cluster are stored securely (Credentials store) and jobs run on trusted agents.

---

## Project structure

Key folders and files:

- `pom.xml` — Maven build file (artifactId `twitter-app`)
- `mvnw`, `mvnw.cmd` — Maven wrappers for consistent builds
- `Dockerfile`, `Dockerfile.multi` — Single-stage and multi-stage container builds
- `Jenkinsfile` — CI/CD pipeline for Jenkins
- `EKS_Terraform/` — Terraform code for provisioning EKS cluster
- `k8s/helm/FullStack-Blogging-App` — Helm chart for the app
- `deployment-service.yml` — Simple Kubernetes deployment + service (fallback)
- `src/` — Spring Boot application sources (controllers, services, templates)

---

## Troubleshooting & notes

- Large file / GitHub push failures: Do not commit `.terraform` or provider binaries. If a large file is pushed, you must remove it from history (git filter-repo/filter-branch + force-push) or use Git LFS. This repository has had such a file removed — see `EKS_Terraform/README-TERRAFORM.md` and root `.gitignore`.
- H2 database: the app uses a file-backed H2 DB by default (`jdbc:h2:file:./data/twitterapp`). For production, replace with a managed DB and use migration tooling (Flyway/Liquibase).
- Kubernetes readiness/liveness: values in `values.yaml` include probe settings. Tune them based on app startup characteristics.

---

## Contributing

Recommended checklist for contributions:

1. Run `./mvnw test` and ensure tests pass.
2. Don't commit local artifacts: `.terraform/`, `*.tfstate`, compiled jars, or large binary files.
3. Follow existing code style and include unit tests for new behavior.
4. If you change infra or CI, update README and any docs in `EKS_Terraform/`, `k8s/`, or `Jenkinsfile`.

If you want, I can add a `CONTRIBUTING.md` and a pre-commit hook to block accidental adds of `.terraform` or large files.

---

## License

Include your preferred license here. If none is present, add one (for example, `MIT` or `Apache-2.0`).

---

If you want, I can also:

- Create `CONTRIBUTING.md` and a pre-commit hook to prevent committing `.terraform` or large binaries.
- Add a repository-level `Makefile` or scripts to simplify common tasks (build, docker-build, helm-install, terraform-init).

---

Contact / Maintainers

Update these fields with maintainers or contact details for the project owner.
