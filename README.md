# edge-ci-cd-demo

A practical CI/CD and DevSecOps demo for a C++ edge application, built step by step from basic CI to self-hosted binary delivery for Ubuntu-based edge devices.

---

# 🚀 Project Overview

This project demonstrates how a simple C++ application delivery flow can evolve into a more realistic **embedded / edge-oriented CI/CD pipeline**.

Instead of treating deployment as a pure cloud-native problem, this demo focuses on a more constrained edge scenario:

- C++ application
- GitHub Actions based automation
- layered DevSecOps validation
- versioned ARM binary artifacts
- S3 as artifact handoff point
- self-hosted runner based delivery control
- automated deployment to a private-network target device
- manual rollback using previously published binary releases

The project is intentionally built in stages so that each step reflects a real engineering decision rather than a single oversized workflow added all at once.

---

# 🧱 Scope of the Demo

This repository focuses on the following delivery model:

1. Validate source code and container build flow in CI
2. Harden the pipeline with layered security checks
3. Build versioned ARM binary artifacts for edge delivery
4. Publish release artifacts to S3
5. Use a self-hosted runner to automate binary delivery to the target device
6. Support manual rollback using versioned release artifacts

This demo does **not** try to hide platform reality:

- the target board is on a private LAN
- the target board runs a legacy Ubuntu 14.04 environment
- legacy runtime compatibility is treated as a platform-specific concern, not as the core definition of whether the CI/CD architecture itself is valid

---

# 🗺️ Project Evolution

## Day 1 — Establish CI Foundation

Day 1 focuses on creating a reproducible CI foundation for a small C++ application.

### What was implemented
- GitHub repository and project structure
- simple C++ application
- GitHub Actions CI pipeline
- multi-branch strategy (`dev`, `main`, PR)
- Docker build integration
- immutable image tagging strategy
- initial push to AWS ECR
- README and architecture overview

### Outcome
A working CI pipeline capable of:
- building the application
- packaging it into a container image
- tagging artifacts consistently
- publishing to a registry

---

## Day 2 — Harden the Pipeline with DevSecOps

Day 2 evolves the CI layer into a more security-oriented validation pipeline.

### What was added
- SAST with `cppcheck`
- SCA / filesystem scan with `Trivy FS`
- container image scan with `Trivy image`
- layered security gate
- release-oriented versioning strategy
- dependency monitoring with Dependabot

### Validation model
- **dev branch** → fast feedback, SAST only
- **PR / main** → build + SAST + SCA + image scan
- **tag stage** → validated release-ready flow

### Outcome
A layered DevSecOps pipeline that:
- validates source code
- scans dependencies
- scans built images
- blocks insecure artifacts from progressing

---

## Day 3 — Implement Edge CD for Binary-Based Delivery

Day 3 extends the project from CI into a more realistic edge-oriented CD story.

### What was added
- ARMv7 binary packaging
- versioned binary publication to S3
- self-hosted runner participation
- automated binary delivery to the target edge device
- runtime-path aligned deployment
- manual rollback workflow using previous binary releases

### Key architectural decisions
- **S3** is used as the versioned artifact handoff point
- **self-hosted runner** is used for controlled delivery in a private-network scenario
- the **target board** is treated as a deployment target
- legacy runtime compatibility on the board is tracked separately from the CI/CD orchestration design

### Outcome
A practical edge delivery flow that can:
- build versioned ARM artifacts
- publish them to S3
- automatically deploy them to the target device
- manually roll back to previous versions

---

# 🧠 Final Delivery Model

The final architecture can be summarized as:

```text
Source Code
   |
   v
GitHub Actions CI
   |
   +--> SAST (cppcheck)
   +--> Docker build
   +--> Trivy FS scan
   +--> Trivy image scan
   |
   v
Tagged Release
   |
   v
Self-Hosted Build / Delivery Control
   |
   +--> Build versioned ARM artifact
   +--> Publish artifact to S3
   +--> Download artifact from S3
   +--> Copy binary to target device
   +--> Restart app using start.sh / stop.sh
   |
   v
Target Ubuntu Edge Device

🏗️ Workflow Structure
1. CI Validation Job

Runs on GitHub-hosted infrastructure and focuses on validation:

checkout code
run cppcheck
build Docker image
run Trivy FS
run Trivy image

Purpose:

fast developer feedback on dev
stricter validation on PR / main
trusted release gate for tagged versions
2. ARM Artifact Build Job

Runs in the controlled self-hosted path and focuses on release binary generation:

build versioned ARM artifact
package release binary
publish artifact to S3 under a versioned release path

Typical artifact path:

s3://edge-cicd-demo-artifacts/edge-demo/releases/<version>/edge-app

Purpose:

separate binary artifact delivery from container-only delivery
make release versions addressable and rollback-friendly
3. Automated Deployment Job

Runs through the self-hosted delivery path and focuses on device-side delivery:

download selected versioned artifact from S3
copy binary to the target runtime path
reuse existing stop.sh / start.sh on the device

Purpose:

automate the delivery hop to a private-network target
align with the existing runtime structure already on the device
4. Manual Rollback Workflow

A dedicated manually triggered workflow allows redeployment of a previously published version.

Rollback model:

operator selects a release version
workflow downloads that version from S3
workflow redeploys it to the target device
existing runtime scripts are reused

Purpose:

keep rollback explicit and operator-controlled
reuse versioned release artifacts as the source of truth
🔐 Security Strategy

This project uses a layered DevSecOps model rather than a single scan step.

SAST

Tool:

cppcheck

Purpose:

detect code-level issues early
provide fast developer feedback
SCA / Filesystem Scanning

Tool:

Trivy FS

Purpose:

scan dependencies and project filesystem
detect vulnerable components before release
Image Scanning

Tool:

Trivy image

Purpose:

scan built container images
catch OS and package vulnerabilities
Security Gate

Policy:

fail on HIGH / CRITICAL

Purpose:

prevent insecure artifacts from being promoted
🏷️ Versioning Strategy

This demo uses semantic versioning for release artifacts.

Why versioned artifacts?

Because edge delivery and rollback need deterministic release references.

Examples:

v1.2.4
v1.2.8
v1.3.0

Versioned releases are used for:

S3 binary artifact publication
deployment targeting
manual rollback selection
📦 Artifact Strategy
Container image path

Container build remains part of CI / validation history.

Binary artifact path

The edge delivery path focuses on the versioned ARM binary.

Why?
Because the target edge device consumes a native binary release rather than a container image.

S3 as handoff point

S3 is used as:

release storage
version source of truth
deployment handoff point
rollback source
🔁 Rollback Model

Rollback is implemented as:

manual redeployment of a previously published versioned binary artifact

This means:

rollback is separate from the normal release flow
rollback uses the same artifact structure as forward deployment
rollback remains explainable and easy to operate

This project intentionally uses a manual rollback workflow instead of embedding rollback logic into the normal CI/CD pipeline.

🌐 Why Self-Hosted Runner?

A self-hosted runner is kept in the delivery architecture because real edge / embedded scenarios often involve:

private-network targets
internal access control
non-public deployment paths
stronger control over build and delivery context

Even when not every stage strictly requires self-hosting, the model is more representative of realistic embedded delivery environments than a purely cloud-hosted CI/CD story.

⚠️ Legacy Board Runtime Compatibility

One important finding from this project is that:

CI/CD orchestration success and target runtime compatibility are not the same problem.

The target board used in this demo runs a very old Ubuntu 14.04 environment.
That created runtime compatibility limitations with newer toolchains and libraries.

This was handled as a separate concern:

the pipeline design itself was still completed
artifact build, publication, and delivery were still implemented
the board’s legacy runtime constraints were documented as a platform-specific issue

This separation is intentional and reflects a realistic engineering boundary.

📂 Repository Highlights
Main workflow
.github/workflows/ci-build.yml

This file contains the current CI/CD orchestration flow.

Suggested future rename: edge-cicd.yml

Manual rollback workflow
.github/workflows/manual-rollback.yml

This file provides the manually triggered rollback path.

📈 What This Project Demonstrates

This demo shows how a small C++ project can evolve through:

basic CI automation
container build and tagging
layered DevSecOps hardening
release-oriented ARM artifact generation
self-hosted runner controlled edge delivery
S3-based artifact handoff
manual rollback using versioned binary releases

In short, it demonstrates:

from simple CI → to layered DevSecOps → to practical edge-oriented CI/CD

🧩 Key Design Decisions
Why separate CI and CD?

Because validation and delivery solve different problems.

CI validates source and artifacts
CD promotes and delivers artifacts
Why versioned binary releases?

Because rollback and edge delivery need deterministic artifact references.

Why keep S3 in the middle?

Because it provides a clean handoff point between build and deployment.

Why keep rollback manual?

Because rollback should be operator-controlled and easy to reason about.

Why treat board compatibility separately?

Because target runtime limitations should not invalidate the core CI/CD orchestration design.

✅ Final Outcome

A practical, explainable, and staged edge CI/CD demo that includes:

reproducible CI foundation
layered DevSecOps validation
versioned ARM artifact generation
S3 publication
automated delivery to a private-network target
manual rollback using versioned binary releases

This repository is not just a pipeline file — it is a small but realistic story of how delivery architecture evolves under real embedded and edge constraints.