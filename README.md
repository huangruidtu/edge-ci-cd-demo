# edge-ci-cd-demo
Secure CI/CD pipeline for C++ edge application with GitHub Actions

# Edge CI/CD Demo (Day 1)

This project demonstrates how a CI/CD pipeline evolves from a minimal setup to a more production-aligned workflow.

Instead of starting with a complex solution, we build incrementally and improve step by step.

---

# 🧱 Step 0 — Minimal Setup (Baseline)

## Dockerfile (Initial Version)

```dockerfile
FROM ubuntu:22.04

WORKDIR /app

COPY build/app .

CMD ["./app"]
```

## CI (Initial Idea)

```text
docker build -t edge-demo .
docker run edge-demo
```

### ❗ Problems

* No versioning → cannot trace builds
* No CI automation → manual process
* No optimization → slow builds
* No security checks → unsafe images

---

# 🔄 Step 1 — Introduce CI Pipeline

We move from manual build to GitHub Actions.

## What we added

* Automated build on push
* Basic Docker build in CI

### Why?

```text
To ensure every commit is automatically validated and built.
```

---

# 🔄 Step 2 — Add Image Tagging Strategy

## Problem

```text
Using "latest" is unreliable and non-deterministic.
```

## Solution

```text
Use commit SHA for tagging
```

## Result

```text
edge-demo-<commit-sha>
```

### Why?

* Each build is uniquely identifiable
* Enables rollback and traceability

---

# 🔄 Step 3 — Optimize Build with Caching

## Problem

```text
CI builds are slow because everything is rebuilt every time.
```

## Solution

* Use Docker Buildx
* Enable layer caching

## Result

```text
Faster CI builds and reduced resource usage
```

---

# 🔄 Step 4 — Push to AWS ECR

## Problem

```text
Images only exist locally in CI runner
```

## Solution

* Authenticate with AWS (IAM user + secrets)
* Push images to ECR

## Result

```text
Centralized image registry (ECR)
```

---

# 🔄 Step 5 — Introduce Security Scan (Trivy)

## Problem

```text
Images may contain vulnerabilities
```

## Solution

* Scan image before pushing
* Fail pipeline on HIGH / CRITICAL issues

## Result

```text
Insecure images are blocked early (DevSecOps - shift left)
```

---

# 🧩 Final CI Pipeline (Day 1)

1. Checkout code
2. Build Docker image (Buildx + cache)
3. Tag image with service name + commit SHA
4. Run security scan (Trivy)
5. Authenticate with AWS
6. Push image to ECR

---

# 🧠 Key Design Decisions

## Why SHA-based tagging?

Avoids mutable tags and ensures traceability.

---

## Why caching?

Improves CI efficiency and reduces build time.

---

## Why security scan in CI?

Detect vulnerabilities early before deployment.

---

## Why incremental design?

Instead of over-engineering, we evolve the system step by step:

```text
Manual → CI → Optimization → Security → Production-ready
```

---

# 📊 Architecture Overview

```
Developer (git push)
        ↓
GitHub Actions (CI)
        ↓
[ Build + Cache ]
        ↓
[ Tag (edge-demo-SHA) ]
        ↓
[ Security Scan (Trivy) ]
        ↓
[ Push to AWS ECR ]
```

---

# 📈 Future Improvements (Planned)

* SBOM generation
* Security reports (SARIF)
* GitHub Security tab integration
* Image signing (Cosign)
* Deployment (Kubernetes / ECS)

---

# 🧠 Summary

This project demonstrates a real-world CI/CD pipeline evolution:

* From manual build → automated CI
* From latest tag → immutable versioning
* From slow builds → cached builds
* From insecure images → integrated security scanning

The system is intentionally designed to evolve towards full DevSecOps maturity.

