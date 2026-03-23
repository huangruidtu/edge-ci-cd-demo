# Security and Pipeline Efficiency

This document summarizes the main security controls and efficiency-related design decisions used in this project’s CI/CD pipeline.

The goal is to explain not only **what** was implemented, but also **why** these choices were made.

---

## 1. Security Strategy Overview

The pipeline is not treated as a simple build-and-release path.  
It is designed as a layered validation and controlled delivery flow.

The main security goals are:

- catch source-level issues early
- detect vulnerable dependencies and risky filesystem content
- scan built container images before release
- reduce unnecessary privilege in AWS access
- keep release actions more controlled than normal development actions

The security model is layered instead of relying on a single tool.

---

## 2. Security Controls Implemented

## 2.1 Static Analysis (SAST) with `cppcheck`

### What was done
The pipeline integrates `cppcheck` for C++ static analysis.

### Why it matters
This provides early feedback before release packaging and helps detect:
- obvious code defects
- suspicious constructs
- maintainability issues

### Why it is useful in this project
Since the project is centered on a C++ edge application, source-level analysis is an important first security and quality gate.

---

## 2.2 Software Composition / Filesystem Scan with `Trivy FS`

### What was done
`Trivy FS` is used to scan the repository filesystem and dependency-related content.

### Why it matters
This helps detect:
- vulnerable dependencies
- risky files in the repository
- known issues before packaging or release

### Why it is useful in this project
Even small projects can inherit risk through dependencies or build context.  
Scanning the filesystem helps stop problems earlier in the pipeline.

---

## 2.3 Container Image Scan with `Trivy image`

### What was done
Built container images are scanned with `Trivy image`.

### Why it matters
This helps identify:
- vulnerable OS packages
- image-level security issues
- risky artifacts embedded in the built image

### Why it is useful in this project
Even though the final edge delivery path is binary-based, the project still uses container-based build and CI validation patterns.  
Image scanning improves confidence in the build path and keeps the project aligned with common DevSecOps practice.

---

## 2.4 Layered Security Gate

### What was done
Security checks are not isolated. They are part of a layered gate model:
- static analysis
- filesystem / dependency scan
- container image scan

### Why it matters
No single tool is enough on its own.  
Using multiple checks provides broader coverage and reduces blind spots.

### Design idea
The pipeline gradually increases validation depth depending on the trigger:
- lighter validation on `dev`
- stronger validation on PR / `main`
- release-oriented build and delivery on tags

This keeps security meaningful without making every branch equally heavy.

---

## 2.5 Least-Privilege IAM for S3 Artifact Publishing

### What was done
Artifact publication to S3 was intentionally scoped with least-privilege IAM instead of broad permissions.

### Why it matters
The release workflow only needs limited access to:
- upload artifacts
- read required release objects
- interact with the intended S3 bucket path

### Why it is useful in this project
This reduces blast radius if credentials are misused and makes the release path more realistic from a cloud security perspective.

---

## 2.6 Controlled Secret Usage

### What was done
Sensitive data is stored in GitHub Secrets, including:
- AWS credentials
- AWS region
- SSH private key for deployment
- target device connection information

### Why it matters
Secrets should not be hardcoded in workflow files or scripts.

### Why it is useful in this project
The project includes cloud publication and device delivery, so controlling secret handling is necessary for even a small demo pipeline.

---

## 2.7 Dependency Update Automation with Dependabot

### What was done
Dependabot was introduced to automate dependency update monitoring and pull request generation.

### Why it matters
Security is not only about scanning for issues.  
It also requires a mechanism for continuously reacting to outdated or vulnerable dependencies.

Dependabot helps by:
- detecting available dependency updates
- generating update pull requests automatically
- keeping dependency maintenance visible in the normal GitHub workflow
- reducing the risk of leaving known vulnerable versions unchanged for too long

### Why it is useful in this project
This project already uses layered validation such as static analysis and Trivy-based scanning.  
Dependabot complements those controls by improving the update side of the security process.

In other words:
- scanning helps detect risk
- Dependabot helps drive remediation

### Practical value
Dependabot improves the long-term maintainability and security posture of the pipeline by making dependency hygiene part of the normal development and review flow.

---

## 2.8 Versioned Release Artifacts

### What was done
Versioned release artifacts are published to S3 under release-specific paths.

### Why it matters
This supports:
- traceability
- rollback
- deterministic release retrieval
- controlled redeployment

### Why it is useful in this project
Security is not only about scanning.  
It is also about making releases reproducible and easier to reason about.

---

## 2.9 Separation of Normal Flow and Rollback Flow

### What was done
Manual rollback is implemented as a separate manually triggered workflow.

### Why it matters
Rollback is a sensitive operational action and should be explicit.

### Why it is useful in this project
Separating rollback from the normal release path improves control and makes the system easier to explain and operate.

---

## 3. Efficiency / Acceleration Strategy Overview

Security was not the only focus.  
Pipeline efficiency was also considered so that validation remains practical.

The main efficiency goals are:

- keep development feedback reasonably fast
- avoid running the heaviest stages on every branch
- separate validation from release actions
- reuse artifacts and version paths where possible
- keep the workflow understandable and not over-engineered

---

## 4. Efficiency / Acceleration Decisions

## 4.1 Layered Trigger Model

### What was done
The workflow is split across:
- `dev`
- PR / `main`
- tag

### Why it improves efficiency
Not every branch needs the full release-oriented flow.

### Practical effect
- `dev` stays lighter for fast iteration
- PR / `main` provides stronger gatekeeping
- tag triggers release-oriented build and delivery

This reduces unnecessary heavy execution during daily development.

---

## 4.2 Docker Layer Caching

### What was done
Docker layer caching was included in the CI pipeline.

### Why it improves efficiency
It reduces rebuild cost when only small parts of the application change.

### Why it matters in this project
The project repeatedly builds container images during CI validation, so caching helps keep feedback cycles shorter.

---

## 4.3 Separation of CI and Release Responsibilities

### What was done
The pipeline separates:
- normal validation flow
- versioned artifact build and release flow
- deployment flow
- rollback flow

### Why it improves efficiency
This avoids running expensive release logic during every normal development check.

### Why it matters
A single oversized workflow would be harder to maintain and slower to operate.

---

## 4.4 S3 as Artifact Handoff Point

### What was done
S3 is used as the release artifact handoff point between build and deployment.

### Why it improves efficiency
This makes the pipeline easier to reason about:
- build produces artifact
- S3 stores artifact
- deployment retrieves artifact

### Why it matters
This clean separation reduces coupling between stages and simplifies release reuse and rollback.

---

## 4.5 Self-Hosted Runner for Delivery Control

### What was done
A self-hosted runner is used in the edge delivery path.

### Why it improves practicality
The target board is on a private LAN and cannot be reached directly from GitHub-hosted runners.

### Why it matters
This is less about raw speed and more about operational fit.  
It makes the edge delivery model realistic and workable.

---

## 4.6 Reuse of Existing Device-Side Runtime Scripts

### What was done
The deployment flow reuses the device-side:
- `start.sh`
- `stop.sh`

### Why it improves efficiency
It avoids reinventing runtime control logic in the CI/CD workflow itself.

### Why it matters
The pipeline stays simpler by delegating runtime behavior to the target device’s existing control mechanism.

---

## 4.7 Versioned Binary Model Supports Cheap Rollback

### What was done
Rollback reuses previously published versioned release binaries instead of introducing a more complex recovery model.

### Why it improves efficiency
This keeps rollback simple:
- select version
- download from S3
- redeploy

### Why it matters
The system benefits from versioning without requiring a heavy custom release manager.

---

## 5. Key Trade-Offs

This project intentionally balances security and simplicity.

## Trade-Off 1: Stronger validation vs faster feedback
- More scans increase security
- Fewer checks increase speed

The solution used here:
- lighter `dev` flow
- stronger PR / `main` flow
- explicit release flow on tags

## Trade-Off 2: Simplicity vs complete platform coverage
- The board’s legacy runtime is difficult to support fully
- The pipeline architecture is still valid even if the target runtime is older than modern toolchains

The solution used here:
- treat legacy runtime compatibility as a separate platform concern
- keep CI/CD architecture explainable and workable

## Trade-Off 3: Centralized release control vs local device complexity
- S3 as source of truth keeps release handling simple
- device-side runtime remains lightweight

The solution used here:
- use S3 for artifact history
- use the device only as deployment target
- keep rollback manual and controlled

---

## 6. Final Summary

The pipeline security model is based on:

- source-level static analysis
- dependency / filesystem scanning
- image scanning
- dependency update automation with Dependabot
- least-privilege artifact publication
- controlled secret handling
- explicit versioned releases
- separate rollback workflow

The pipeline efficiency model is based on:

- layered trigger design
- faster `dev` feedback
- stronger PR / `main` validation
- explicit tag-based release flow
- Docker caching
- S3 as artifact handoff point
- self-hosted runner for realistic private-network delivery
- simple version-based rollback

In short:

**Security is implemented as layered validation and controlled access.  
Efficiency is implemented as trigger separation, caching, artifact reuse, and clear stage boundaries.**
