# Edge CD Architecture

## Objective

Define a lightweight Continuous Deployment (CD) architecture for delivering compiled C++ application binaries to Ubuntu-based edge devices.

This deployment model is intended for edge environments where applications run directly on the target device without relying on Docker image delivery or ROS-specific runtime assumptions.

---

## Deployment Unit

The deployment unit is a compiled and versioned C++ binary artifact.

Key decisions:
- Deploy compiled binaries instead of Docker images
- Do not use a ROS-specific packaging or deployment model
- Keep the deployment artifact simple and directly executable on the target Ubuntu device

---

## Delivery Mechanism

The binary artifact is delivered from the CI/CD pipeline to the target device through secure remote access.

Selected approach:
- GitHub Actions is used as the CI/CD entry point
- SSH is used for remote access
- SCP is used for binary transfer

This approach keeps the delivery model simple, transparent, and suitable for edge device deployment.

---

## Target Runtime Model

The application runs as a native process on the Ubuntu-based target device.

Initial runtime approach:
- Native binary execution
- Lightweight script-based process control
- Flexible runtime model that can evolve later if needed

The initial architecture intentionally avoids binding the design to systemd or other heavier runtime assumptions at this stage.

---

## Target Directory Layout

A structured directory layout is used on the target device to support deployment, rollback, validation, and troubleshooting.

Example layout:

/opt/edge-app/
- current/
- releases/
- logs/
- scripts/

Suggested usage:
- `current/` stores the active binary or active version reference
- `releases/` stores versioned binary releases
- `logs/` stores runtime logs
- `scripts/` stores deployment and operational helper scripts

Example structure:

/opt/edge-app/
- current/edge-app
- releases/v1.0.0/edge-app
- releases/v1.0.1/edge-app
- logs/edge-app.log
- scripts/deploy.sh
- scripts/start.sh
- scripts/stop.sh
- scripts/restart.sh
- scripts/rollback.sh

---

## Deployment Flow

The deployment flow is defined as follows:

1. Source code is built in CI
2. A versioned binary artifact is produced
3. The artifact is transferred to the target device via SCP
4. The artifact is stored under a versioned release directory
5. The active application binary is updated
6. The application process is restarted
7. Deployment is validated through process and log checks

This design provides a direct and controlled path from CI artifact creation to edge device runtime execution.

---

## Validation Strategy

Deployment validation is required after each deployment.

Validation includes:
- Process status verification
- Log inspection
- Basic runtime behavior verification

The goal is to confirm that the application starts correctly and behaves as expected after deployment.

---

## Rollback Strategy

Rollback is handled manually in the initial phase.

Rollback approach:
- Keep previous versioned binary releases on the target device
- Allow switching back to a previously known-good binary version
- Restart the application after rollback

This provides a safe recovery path when a newly deployed version fails or behaves unexpectedly.

---

## Release Retention Policy

The target device keeps only a limited number of recent releases.

Policy:
- Retain the latest 3 binary releases
- Use retained versions for rollback and troubleshooting
- Perform cleanup only after successful deployment validation
- Never remove the currently active version

The target device is not intended to serve as a long-term artifact repository. Long-term storage should remain in the CI/CD or release platform.

---

## Summary

This architecture defines a lightweight binary-based edge CD model for Ubuntu-based target devices.

Key outcomes:
- Binary-based deployment instead of Docker image delivery
- SSH/SCP-based artifact transfer
- Native process execution on Ubuntu
- Versioned release storage on the device
- Deployment validation through process and log checks
- Manual rollback using retained releases
- Limited on-device retention for safe and controlled operation
