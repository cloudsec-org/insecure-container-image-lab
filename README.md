# insecure-lab-image

**Purpose**

This repository contains a deliberately *insecure* Docker image used only for offline labs, PoVs and scanner tests (SCA, secret scanning, basic AV detection). **It contains only fake/example secrets and harmless test artifacts — no real credentials and no real malware.**

> ⚠️ IMPORTANT: Use this image **only** in an isolated test environment (air-gapped VM or sandbox). Do **not** use in production or on networks with access to sensitive systems.



## Quick start (isolated lab)

1. Clone the repo locally in an isolated VM or sandbox.

```shell
https://github.com/cloudsec-org/insecure-container-image-lab.git

cd insecure-container-image-lab
```



2. Build the image (no network egress should be required if your environment is isolated):

```shell
docker build -t insecure-lab-image:1.0 .
```



3. Run the container in an isolated network/VM:

```shell
docker run --rm -p 8080:8080 --name insecure-lab --network none insecure-lab-image:1.0
```



4. Access the test app locally (if allowed) at `http://localhost:8080` within the sandbox.

## 