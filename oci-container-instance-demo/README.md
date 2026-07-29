# OCI Container Instance Terraform Demo

A small DevOps project that provisions an Oracle Cloud Infrastructure (OCI) Container Instance and deploys two containers:

- **Frontend:** Nginx serves a static page on port 80 and reverse-proxies `/api/*`.
- **Backend:** A dependency-free Python JSON API listens on port 8080.

Both containers run in the same OCI Container Instance and share its network, so Nginx reaches the backend at `127.0.0.1:8080`.

The demo deliberately avoids Docker builds and a private registry. Terraform uploads the small source files as OCI `CONFIGFILE` volumes and mounts them into official public Nginx and Python images. This is convenient for a dummy project; production applications should normally build versioned images and publish them to OCIR or another registry.

This demo uses local Terraform state. For shared or production use, configure a remote state backend and review the networking, image pinning, observability, and TLS requirements.

## What Terraform creates

- One VCN
- One public subnet
- One internet gateway and route table
- One security list allowing inbound TCP/80
- One OCI Container Instance with an ephemeral public IP
- Two containers: `frontend` and `backend`

## Project layout

```text
.
├── app/
│   ├── backend/app.py
│   └── frontend/
│       ├── app.js
│       ├── default.conf
│       ├── index.html
│       └── styles.css
├── scripts/
│   ├── deploy.sh
│   ├── destroy.sh
│   ├── read_oci_config.py
│   └── smoke-test.sh
├── container-instance.tf
├── data.tf
├── locals.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── versions.tf
```

## Prerequisites

1. Terraform 1.6 or newer.
2. Python 3, used only to read the selected OCI config profile.
3. A working API-key profile in `~/.oci/config`.
4. OCI permissions to create Container Instances and networking resources.
5. Service limits and capacity for the selected Container Instance shape.
6. Bash and `curl` only when using the optional wrapper and smoke-test scripts.

A typical OCI config profile looks like this; never commit the real file or private key:

```ini
[DEFAULT]
user=ocid1.user...
fingerprint=aa:bb:cc:...
tenancy=ocid1.tenancy...
region=ap-mumbai-1
key_file=/Users/you/.oci/oci_api_key.pem
```

Terraform's OCI provider authenticates directly from this file. The included helper reads only `tenancy` and `region` so the configuration can default the deployment compartment to the tenancy root and query availability domains. It does not read or copy private-key contents.

## IAM policy

Administrators already have sufficient access. For a delegated group, the core permissions normally include:

```text
Allow group <group-name> to manage compute-container-family in compartment <compartment-name>
Allow group <group-name> to manage virtual-network-family in compartment <compartment-name>
```

This project creates the VCN itself, so `manage virtual-network-family` is required rather than only `use`. Public Docker Hub images are used, so no OCIR repository policy is required.

## Deploy

Optionally create a local variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set `oci_profile` when you use a profile other than `DEFAULT`. Setting `compartment_ocid` to a child compartment is recommended. If it is omitted, Terraform uses the tenancy OCID read from your local OCI config.

Run Terraform directly:

```bash
terraform init
terraform plan
terraform apply
```

Or use the wrapper, which also validates the configuration and runs a smoke test:

```bash
./scripts/deploy.sh
```

After apply completes:

```bash
terraform output -raw app_url
terraform output -raw api_health_url
terraform output -raw api_message_url
```

Open the `app_url` in a browser. The page calls the backend and displays its response.

## API endpoints

```bash
curl "$(terraform output -raw api_health_url)"
curl "$(terraform output -raw api_message_url)"

curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"text":"hello from curl"}' \
  "$(terraform output -raw app_url)/api/echo"
```

## Restrict public access

The default `allowed_cidr` is `0.0.0.0/0`, which makes port 80 public. For a personal demo, set it to your current public IP with a `/32` suffix:

```hcl
allowed_cidr = "203.0.113.10/32"
```

## Updating the app

Edit any file under `app/` and run:

```bash
terraform apply
```

The mounted configuration changes, so Terraform updates or recreates the Container Instance as required by the OCI provider.

## Logs and troubleshooting

List the container IDs:

```bash
terraform output container_ids
```

Retrieve logs with OCI CLI:

```bash
oci container-instances container retrieve-logs --container-id <container-ocid> --file -
```

Common issues:

- **Shape/capacity error:** try `CI.Standard.A1.Flex`, or another shape available in your region. `CI.Standard.E5.Flex` is available only in selected regions.
- **Authorization error:** verify permissions for `compute-container-family` and `virtual-network-family` in the target compartment.
- **Image-pull error:** confirm the subnet has the internet gateway route and outbound internet access; public images must be reachable from the Container Instance VNIC.
- **502 from Nginx:** inspect the `backend` container logs and verify its health check.
- **Profile error:** confirm the selected profile exists in `~/.oci/config` and its `key_file` path exists.

## Destroy

```bash
terraform destroy
```

Or:

```bash
./scripts/destroy.sh
```
