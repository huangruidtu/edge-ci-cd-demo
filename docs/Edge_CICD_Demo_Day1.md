# edge-ci-cd-demo

Secure CI/CD pipeline for C++ edge application with GitHub Actions

---

# 🚀 Edge CI/CD Demo (Day 1)

This project demonstrates how a CI/CD pipeline evolves from a minimal setup to a production-aligned workflow.

Instead of building a complex system upfront, we incrementally improve the pipeline step by step, following real-world engineering practices.

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

# 🔄 Step 4 — Push to AWS ECR (Initial Design)

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

# ⚠️ Step 6 — Rethinking the Pipeline (Key Evolution 🔥)

After implementing the initial pipeline, we identified a major issue:

```text
Images were being pushed to ECR on every CI run
```

### ❗ Problems

* Unnecessary cloud usage (cost)
* Risk of accidental deployment
* No clear separation between validation and release

---

# 🚀 Final Design — 3-Level CI/CD Pipeline

We refactored the pipeline into three distinct stages:

---

## 🟢 1. Development Stage (dev branch)

* Fast feedback
* Build only
* No security scan
* No push to ECR

```text
Goal: Speed and developer productivity
```

---

## 🟡 2. Validation Stage (PR + main)

Triggered by:

* Pull Request → main
* Direct push → main

### What happens:

* Full Docker build
* Trivy security scan (fail on HIGH/CRITICAL)
* ❌ No push to ECR

```text
Goal: Ensure code is safe before release
```

---

## 🔴 3. Release Stage (GitHub Release)

Triggered by:

* Creating a GitHub Release (e.g. v1.0.0)

### What happens:

* Build Docker image
* Run security scan
* Push image to AWS ECR

```text
Goal: Controlled and intentional production release
```

---

# 🧩 Final CI/CD Flow

```
Developer (git push)
        ↓
        ├── dev branch → Fast CI (build only)
        │
        ├── PR / main → Validation CI (build + scan)
        │
        └── Release → Production pipeline
                         ↓
                    Push to ECR
```

---

# 🧠 Key Design Decisions

## Why separate CI and CD?

```text
Validation ≠ Deployment
```

* CI ensures code quality
* CD controls production release

---

## Why not push on main?

Even after merge, code is only **validated**, not released.

```text
Prevents accidental deployment
```

---

## Why release-based deployment?

* Explicit action
* Version-controlled
* Safe rollback

---

## Why incremental design?

We evolved the system step by step:

```text
Manual → CI → Optimization → Security → Controlled Release
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

This project demonstrates a real-world CI/CD evolution:

* From manual build → automated CI
* From latest tag → immutable versioning
* From slow builds → cached builds
* From insecure images → integrated security
* From uncontrolled deployment → release-driven delivery

The pipeline now reflects production-grade DevOps and DevSecOps practices.

