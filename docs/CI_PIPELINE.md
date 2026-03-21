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

Using "latest" is unreliable and non-deterministic.

## Solution

Use commit SHA for internal tracking and release version for production.

## Result

- Internal: commit SHA (traceability)
- External: release tag (e.g. v1.0.0)

### Why?

- SHA ensures traceability
- Version tag provides human-readable releases

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

# 🔄 Step 6 — Introduce Layered Security Gate (DevSecOps)

We upgraded the pipeline to enforce security through multiple layers.

---

## ❗ Problem

Security checks were incomplete and not structured:

- No dependency scanning
- No separation between fast and strict checks
- No enforced security gate

---

## ✅ Solution

### 1. SAST (Static Code Analysis)

- Tool: cppcheck
- Runs on all branches
- Provides fast developer feedback

---

### 2. SCA (Dependency Scanning)

- Tool: Trivy FS
- Scans project dependencies
- Detects vulnerable libraries

---

### 3. Container Image Scanning

- Tool: Trivy image
- Scans built Docker images
- Detects OS and base image vulnerabilities

---

### 4. Security Gate

```text
Pipeline fails on HIGH / CRITICAL vulnerabilities
```

- Enforced via exit codes
- Prevents insecure artifacts from progressing

---

## 🚀 Result

**Full DevSecOps pipeline with layered security enforcement**

---

# 🚀 Final Design — Layered CI Pipeline

---

## 🟢 Development Stage (dev branch)

- SAST only (cppcheck)  
- No Docker build  
- No security scan  

**Goal:** Fast feedback for developers

---

## 🟡 Validation Stage (PR + main)

**Triggered by:**

- Pull request to main  
- Push to main  

**What happens:**

- SAST (cppcheck)  
- Docker build  
- SCA (Trivy FS)  
- Image scan (Trivy image)  
- Security gate enforcement  

**Goal:** Ensure code is secure before merge

---

## 🔴 Release Stage

**Triggered by:**

- GitHub Release (e.g. v1.0.0)

**What happens:**

- Full validation (same as above)  
- Push image to AWS ECR  

**Goal:** Promote only trusted artifacts

---

## 🧩 Final CI Flow

```
Developer (git push)
        |
        v
   +---------------+
   |  dev branch   |
   +---------------+
           |
           v
     +------------+
     | SAST only  |
     +------------+


   +---------------+
   |   PR / main   |
   +---------------+
           |
           v
     +------------+
     |    SAST    |
     +------------+
           |
           v
     +------------+
     |   BUILD    |
     +------------+
           |
           v
     +------------+
     |    SCA     |
     +------------+
           |
           v
     +------------+
     | IMAGE SCAN |
     +------------+
           |
           v
     +------------+
     |    GATE    |
     +------------+


   +---------------+
   |    Release    |
   +---------------+
           |
           v
     +------------+
     |    SAST    |
     +------------+
           |
           v
     +------------+
     |   BUILD    |
     +------------+
           |
           v
     +------------+
     |    SCAN    |
     +------------+
           |
           v
     +------------+
     |    GATE    |
     +------------+
           |
           v
     +---------------+
     |  PUSH (ECR)   |
     +---------------+
```

---

# 🧠 Key Design Decisions

## Why layered security?

> Not all checks should run at all times

- Early stage → fast feedback
- Later stage → strict enforcement

---

## Why both SCA and image scanning?

> Different layers of the software supply chain

- SCA → dependency vulnerabilities
- Image scan → runtime and OS vulnerabilities

---

## Why enforce security with fail-fast?

> Security must block, not just report

---

## Why skip build in dev?

> Optimize developer experience

- Avoid slow feedback loops
- Focus on code-level validation

---

## Why separate CI and CD?

> Validation ≠ Deployment

- CI validates artifacts
- CD promotes and deploys artifacts

---

## 🔄 Dependency Management Strategy

This project uses Dependabot to monitor and propose dependency updates.

### Configuration

- Update frequency: weekly
- No grouping: each dependency update creates an individual pull request
- Manual review and merge strategy

### Workflow

1. Dependabot creates pull requests for dependency updates
2. Each PR is reviewed manually based on risk level
3. Merge decisions follow a structured evaluation process
4. After merge, CI pipeline validates:
   - SAST (cppcheck)
   - SCA (Trivy FS)
   - Image scanning (Trivy image)
   - Security gate enforcement

### Decision Strategy

Each dependency update is evaluated based on version type:

- Patch updates (e.g. 1.2.3 → 1.2.4)
  - Low risk
  - Typically merged directly

- Minor updates (e.g. 1.2.3 → 1.3.0)
  - Medium risk
  - Merge and validate via CI pipeline

- Major updates (e.g. 1.2.3 → 2.0.0)
  - High risk
  - Require manual testing and validation before merge

### Design Principles

- Maintain full control over dependency updates
- Avoid automatic merging of unknown changes
- Use CI as the validation gate
- Balance update frequency with system stability

---
# 📈 Future Improvements

- Image signing (Cosign)
- SBOM generation
- Security reporting (SARIF)
- Deployment automation (CD pipeline)
- Progressive delivery strategies

---

# 🧠 Summary

This project demonstrates a real-world DevSecOps evolution:

- From manual build → automated CI
- From latest tag → immutable versioning
- From slow builds → cached builds
- From basic scanning → layered security
- From passive checks → enforced security gates
- From uncontrolled deployment → release-driven delivery

The pipeline now reflects a production-grade DevSecOps architecture with progressive security enforcement.
