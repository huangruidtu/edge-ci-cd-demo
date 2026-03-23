# CI/CD Trigger Model

This document explains how the pipeline behaves at different GitHub trigger points.

The workflow is intentionally layered so that development branches get fast feedback, while release tags trigger the full artifact and delivery flow.

---

## Overview

The pipeline is split into three main execution levels:

1. **Development branch validation**
2. **Pull request / main branch validation**
3. **Release tag build and delivery**

This separation helps balance:
- developer feedback speed
- security and quality checks
- release-oriented artifact delivery

---

## 1. Development Branch (`dev`)

The `dev` branch is used for active implementation and iterative updates.

### Purpose
Provide fast feedback without running the full release-oriented pipeline every time.

### Typical checks
- source checkout
- static analysis (`cppcheck`)
- basic CI validation
- optional lightweight internal Docker build check

### Why this level exists
The development branch should stay fast enough for daily iteration.  
At this stage, the goal is not to produce release artifacts, but to catch obvious issues early.

### Expected outcome
- quick validation for ongoing work
- faster inner development loop
- reduced cost compared with full release pipeline execution

---

## 2. Pull Request and Main Branch

This level is used when code is proposed for integration or has already been merged into the main line.

### Trigger points
- pull request into `main`
- direct updates validated against `main`
- merged mainline verification

### Purpose
Run a stronger quality and security gate before code is considered release-ready.

### Typical checks
- source checkout
- `cppcheck`
- Docker build
- `Trivy FS` scan
- `Trivy image` scan
- layered DevSecOps validation

### Why this level exists
This stage is the main quality gate.  
It is stricter than `dev` because code at this level is much closer to release.

### Expected outcome
- validated source code
- validated container build
- dependency and image scan results
- stronger confidence before release tagging

---

## 3. Release Tags (`vX.Y.Z`)

This level is used for versioned releases.

### Trigger points
- Git tag such as `v1.2.8`
- semantic version based release events

### Purpose
Turn validated code into versioned release artifacts and push them through the edge delivery path.

### Typical actions
- build ARM release artifact
- package binary with release version
- upload artifact to S3
- download artifact from S3 in deployment stage
- deliver binary to the target edge device
- invoke device-side `stop.sh` / `start.sh`
- support later manual rollback through previously published versions

### Why this level exists
A release tag represents an intentional release event.  
This is the point where the pipeline moves from validation into controlled delivery.

### Expected outcome
- versioned ARM binary artifact
- artifact stored in S3 under release path
- automated delivery flow executed
- release becomes eligible for rollback selection later

---

## Trigger Matrix

| Trigger | Main Goal | Typical Actions |
|---|---|---|
| `dev` branch | Fast feedback | `cppcheck`, lightweight CI validation |
| PR / `main` | Quality and security gate | `cppcheck`, Docker build, Trivy FS, Trivy image |
| Tag (`vX.Y.Z`) | Release and delivery | ARM artifact build, S3 publication, automated deployment |

---

## Design Rationale

### Why not run the full pipeline on every branch?
Because release-oriented steps are more expensive and slower.  
They should only run when the code has already passed normal validation and a real versioned release is intended.

### Why keep `dev` lighter?
Because developers need faster iteration during implementation.

### Why make tag the delivery trigger?
Because binary publication and deployment should be tied to explicit release intent, not to every intermediate commit.

---

## Final Interpretation

The pipeline follows this progression:

- **`dev`** = fast developer feedback
- **PR / `main`** = strong validation gate
- **tag** = versioned artifact build and controlled edge delivery

This layered trigger model helps keep the workflow both practical and explainable for embedded / edge delivery scenarios.
