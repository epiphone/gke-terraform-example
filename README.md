# Google Kubernetes Engine full-stack example
[![CircleCI](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master.svg?style=svg)](https://circleci.com/gh/epiphone/gke-terraform-example/tree/master)

An example of deploying a web app on GKE. Consists of
- **GKE cluster** with a single node pool
  - [VPC-native](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips), [private](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters) and using [container-native load-balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing)
  - access to cluster master is limited to a single whitelisted IP: check the `K8S_MASTER_ALLOWED_IP` env variable below
- **Cloud SQL Postgres** instance with [private networking](https://cloud.google.com/blog/products/databases/introducing-private-networking-connection-for-cloud-sql)
  - connects to GKE through a [private IP](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#private-ip), ensuring traffic is never exposed to the public internet
- **Cloud Storage** and **Cloud CDN** for serving static assets
- **Cloud Load Balancing** routing `/api/*` to GKE and the rest to the static assets bucket
  - implemented in a bit of a roundabout way since `ingress-gce` [lacks support for backend buckets](https://github.com/kubernetes/ingress-gce/issues/33): we're [passing](.circleci/config.yml#L132) GKE backend's name in Terraform variables and attaching it to our default URL map
- **Cloud DNS** for domain management
    - check `ROOT_DOMAIN_NAME_<ENV>` below
- **Terraform**-defined infrastructure
  - using `kubectl` directly instead of the [Kubernetes Terraform provider](https://github.com/terraform-providers/terraform-provider-kubernetes) as the latter is missing an Ingress type, among others
- **CircleCI** pipeline
  - push to any non-master branch triggers `dev` deployment & push to `master` branch triggers `test` deployment
  - `prod` deployment triggered by an additional approval step at CircleCI UI

![architecture sketch](/doc/gke-sample-app.png)

## Setup

The following steps need to be completed manually before automation kicks in:

1. Create a new Google Cloud project per each environment
2. For each Google Cloud project,
    - set up a Cloud Storage bucket for storing [remote Terraform state](https://www.terraform.io/docs/backends/types/gcs.html)
    - set up a service IAM account to be used by Terraform. Attach the `Editor` and `Compute Network Agent` roles to the created user
3. Set environment variables in your CircleCI project (replacing `ENV` with an uppercase `DEV`, `TEST` and `PROD`):
    - `GOOGLE_PROJECT_ID_<ENV>`: env-specific Google project id
    - `GCLOUD_SERVICE_KEY_<ENV>`: env-specific service account key
    - `DB_PASSWORD_<ENV>`: env-specific password for the Postgres user that the application uses
    - `ROOT_DOMAIN_NAME_<ENV>`: env-specific root domain name, e.g. `dev.example.com`
    - `K8S_MASTER_ALLOWED_IP`: IP from which to access cluster master's public endpoint, i.e. the IP where you run `kubectl` at ([read more](https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks))
      - In CircleCI we temporarily whitelist the test host IP in order to run `kubectl`
4. [Enable](https://cloud.google.com/apis/docs/enable-disable-apis) the following Google Cloud APIs:
    - `cloudresourcemanager.googleapis.com`
    - `compute.googleapis.com`
    - `container.googleapis.com`
    - `containerregistry.googleapis.com`
    - `dns.googleapis.com`
    - `servicenetworking.googleapis.com`
    - `sqladmin.googleapis.com`

You might also want to acquire a domain and [update your domain registration](https://cloud.google.com/dns/docs/update-name-servers) to point to Google Cloud DNS name servers.

## Manual deployment

You can also sidestep CI and deploy locally:

1. Install [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html), [gcloud](https://cloud.google.com/sdk/#Quick_Start) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. [Login](https://www.terraform.io/docs/providers/google/provider_reference.html) to Google Cloud: `gcloud auth application-default login`
3. Update infra: `cd terraform/dev && terraform init && terraform apply`
4. Follow [instructions](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app) on building and pushing a Docker image to GKE:
    - `cd app`
    - `export PROJECT_ID="$(gcloud config get-value project -q)"`
    - `docker build -t gcr.io/${PROJECT_ID}/gke-app:v1 .`
    - `gcloud docker -- push gcr.io/${PROJECT_ID}/gke-app:v1`
5. Authenticate `kubectl`: `gcloud container clusters get-credentials $(terraform output cluster_name) --zone=$(terraform output cluster_zone)`
6. Render Kubernetes config template: `terraform output k8s_rendered_template > k8s.yml`
7. Update Kubernetes resources: `kubectl apply -f k8s.yml`

Read [here](https://cloud.google.com/sql/docs/postgres/quickstart-proxy-test) on how to connect to the Cloud SQL instance with a local `psql` client.

## Further work

- Cloud SQL high availability & automated backups
- [regional GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters)
- GKE autoscaling
- Cloud Armor DDoS protection
- SSL
- tune down service accounts privileges
- possible CI improvements:
    - add a step to [clean up old container images from GCR](https://gist.github.com/ahmetb/7ce6d741bd5baa194a3fac6b1fec8bb7)
    - prompt for extra approval on infra changes in master
    - don't rebuild docker image from `test` to `prod`
