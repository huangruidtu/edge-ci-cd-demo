# Edge CI/CD Architecture

## Objective

Define a simple and practical CI/CD architecture for delivering a compiled C++ application to an Ubuntu-based edge device.

This architecture is designed for an edge / embedded scenario where:

- the application is delivered as a native binary
- the target device is on a private LAN
- deployment is controlled through a self-hosted runner
- versioned binary artifacts are stored in S3
- rollback is handled through previously published releases

---

## Final Scope

This project does **not** try to solve every device-side platform issue inside the pipeline itself.

The final scope is:

- validate code and artifacts in CI
- build a versioned ARM binary artifact
- publish the artifact to S3
- automatically deliver the artifact to the target device
- restart the application using existing device-side scripts
- support manual rollback to a previous version

Legacy target runtime compatibility is tracked separately as a platform-specific concern.

---

## High-Level Design

```text
Developer Push / PR / Tag
          |
          v
GitHub Actions
          |
          +-----------------------------+
          |                             |
          v                             v
   CI Validation Job              ARM Artifact Build Job
 (GitHub-hosted runner)          (Self-hosted runner: L14)
          |                             |
          |                             v
          |                      Versioned binary artifact
          |                             |
          |                             v
          |                         AWS S3
          |                             |
          +-----------------------------+
                                        |
                                        v
                           Deploy Job (Self-hosted runner: L14)
                                        |
                                        v
                          Ubuntu Edge Device (private LAN target)
                                        |
                                        v
                         stop.sh / start.sh / current runtime path

Main Components
1. GitHub-hosted CI Validation

This part is responsible for normal CI and DevSecOps validation.

It includes:

source checkout
SAST (cppcheck)
Docker build
filesystem / dependency scan (Trivy FS)
container image scan (Trivy image)

Purpose:

provide fast feedback on dev
enforce stronger checks on PR / main
ensure only validated code reaches release flow
2. Self-Hosted Runner (L14)

The L14 Ubuntu machine is the only self-hosted runner in scope.

Its role is:

build the ARM binary artifact
publish versioned binaries to S3
download versioned binaries from S3
deliver binaries to the target device
trigger the device-side restart flow

Why self-hosted:

the target device is on a private LAN
the delivery path is edge-oriented
the build / delivery path is more controlled and more realistic for embedded scenarios
3. S3 as Artifact Handoff Point

S3 is used as the source of truth for versioned binary releases.

Example release path:

s3://edge-cicd-demo-artifacts/edge-demo/releases/<version>/edge-app

Why S3 is important:

stores versioned binary outputs
separates build from deployment
gives a stable handoff point
supports manual rollback through previous versions
4. Target Edge Device

The target board is treated as a deployment target only.

It is not part of the build infrastructure in the final architecture.

The deployment job copies the binary to the runtime path on the device and reuses the existing scripts:

stop.sh
start.sh

The current runtime path is:

/home/devops/edge-app/current/edge-app
Delivery Flow

The final delivery flow is:

Developer pushes code or creates a PR
GitHub Actions runs CI validation
On release tags, the self-hosted runner builds a versioned ARM artifact
The artifact is uploaded to S3
The deployment job downloads the tagged artifact from S3
The binary is copied to the target runtime path on the device
The existing stop.sh / start.sh scripts are called

This creates a simple and explainable build → artifact → delivery path.

Rollback Flow

Rollback is implemented as a separate manually triggered workflow.

The rollback logic is:

operator selects a previous release version
workflow downloads that binary from S3
workflow copies it back to the device runtime path
workflow calls stop.sh and start.sh

This means rollback is:

manual
explicit
based on versioned release artifacts
separate from the normal release pipeline
Why This Architecture Makes Sense
Why not deploy Docker images to the device?

Because the target device consumes a native binary deployment model, not a container runtime model.

Why keep S3 in the middle?

Because S3 acts as a clean handoff point between build and deployment.

Why use a self-hosted runner?

Because edge / embedded delivery often involves private-network targets and controlled internal delivery paths.

Why separate pipeline design from board compatibility?

Because CI/CD orchestration and target runtime compatibility are different concerns.
The pipeline can still be valid even when the target board has legacy runtime limitations.

Runtime Compatibility Note

The target board is very old and runs a legacy Ubuntu 14.04 environment.

This caused runtime compatibility issues with newer build/runtime environments.

That issue is treated as:

a target platform concern
a separate follow-up issue
not a reason to invalidate the overall CI/CD architecture

This is an intentional engineering boundary.

Final Outcome

This architecture provides:

GitHub-hosted CI validation
self-hosted ARM artifact build
versioned S3 artifact publication
automated binary delivery to the target device
manual rollback through previous release versions
