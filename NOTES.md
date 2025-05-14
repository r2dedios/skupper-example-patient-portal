# RH Summit demo (eXate + RedHat)
This document describes how works and how to deploy the demo for the RH Summit 2025 in collaboration with eXate.

## 1. Context
* 2 Openshift clusters v4.17 running on Azure, on different regions:
  * Alpha Cluster (ClusterID: 6c6d60c9-6358-4c2c-8f75-bfde4a668cf7) (RH Summit Demo): https://console-openshift-console.apps.exate-alpha.azure.sandboxedcontainers.com
  * Beta Cluster (ClusterID: 65dd9416-7eeb-4c7a-9488-e77ba14992c4) (Confidential Containers): https://console-openshift-console.apps.exate-beta.azure.sandboxedcontainers.com
* Azure subscription: Confidential Container (EA Subscription 1) (1a84145c-974c-4237-9046-64a34c09752f) (Contact: Jens Freimann)

## 2. URLs
2. Patient Portal
  * Patient Portal (Default): https://fronted-skupper-patient-portal-public.apps.exate-alpha.azure.sandboxedcontainers.com/
  * Patient Portal (Modified): https://frontend-exate-skupper-patient-portal-public.apps.exate-alpha.azure.sandboxedcontainers.com

3. Skupper Console: https://skupper-skupper-patient-portal-public.apps.exate-alpha.azure.sandboxedcontainers.com

4. Data Endpoints
  * Mocked data on Gravitee: https://gateway-gravitee-apim.apps.exate-alpha.azure.sandboxedcontainers.com/api/data
  * Mocked Crypted data on Gravitee: https://gateway-gravitee-apim.apps.exate-alpha.azure.sandboxedcontainers.com/dev/api/data

5. eXate APIGator Login Page: https://identity.exate.apps.exate-alpha.azure.sandboxedcontainers.com

## 3. Architecture
TODO Diagram


## 4. Custom Front-end for eXate
### Building modified frontend image
```sh
podman build -t quay.io/avillega/patient-portal-frontend:latest -f frontend/Containerfile frontend/
podman push quay.io/avillega/patient-portal-frontend:latest
```
```sh
# Internal Registry
podman build -t default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-public/patient-portal-frontend:latest -f frontend/Containerfile frontend/
podman push --tls-verify=false default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-public/patient-portal-frontend:latest
```
```sh
# All in one command
podman build -t quay.io/avillega/patient-portal-frontend:latest -f frontend/Containerfile frontend/ ; podman push quay.io/avillega/patient-portal-frontend:latest ; oc scale deployment/frontend-exate --replicas=0; oc scale deployment/frontend-exate --replicas=1
```

## 5. Custom router for eXate
### Building modified hub image
```sh
# QUAY.io
podman build -t quay.io/avillega/patient-portal-hub:latest -f hub/Containerfile hub/
podman push quay.io/avillega/patient-portal-hub:latest
```
```sh
# Internal Registry
podman build -t default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-hub/patient-portal-hub:latest -f hub/Containerfile hub/
podman push --tls-verify=false default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-hub/patient-portal-hub:latest
```

## 6. Custom DB for eXate
### Building modified DB image
```sh
podman build -t quay.io/avillega/patient-portal-database:latest -f database/Containerfile database/
podman push quay.io/avillega/patient-portal-database:latest
```
```sh
# Internal Registry
podman build -t default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-database/patient-portal-database:latest -f database/Containerfile database/
podman push --tls-verify=false default-route-openshift-image-registry.apps.exate-alpha.azure.sandboxedcontainers.com/skupper-patient-portal-database/patient-portal-database:latest
```


## 7 Installation
### 7.1 Project setup
Use a different terminal per module on the architecture (Public, CH, GB, US, Hub, DB)

**PUBLIC:**
```sh
export PS1="$PS1 - PUBLIC: "
export KUBECONFIG=./kubeconfig-public
oc project skupper-patient-portal-public || oc new-project skupper-patient-portal-public
```

**PRIVATE-GB:**
```sh
export PS1="$PS1 - PRIVATE-GB: "
export KUBECONFIG=./kubeconfig-private-gb
oc project skupper-patient-portal-private-gb || oc new-project skupper-patient-portal-private-gb
```

**PRIVATE-CH:**
```sh
export PS1="$PS1 - PRIVATE-CH: "
export KUBECONFIG=./kubeconfig-private-ch
oc project skupper-patient-portal-private-ch || oc new-project skupper-patient-portal-private-ch
```

**PRIVATE-US:**
```sh
export PS1="$PS1 - PRIVATE-US: "
export KUBECONFIG=./kubeconfig-private-us
oc project skupper-patient-portal-private-us || oc new-project skupper-patient-portal-private-us
```

**HUB:**
```sh
export PS1="$PS1 - HUB: "
export KUBECONFIG=./kubeconfig-hub
oc project skupper-patient-portal-hub || oc new-project skupper-patient-portal-hub
```

**DATABASE-VM:**
```sh
export PS1="$PS1 - DB: "
export SKUPPER_PLATFORM=podman
podman network create skupper
systemctl --user enable --now podman.socket
```


### 7.2 Patient Portal Deployment
**PUBLIC:**
```sh
oc apply -f frontend/kubernetes.yaml
oc logs -f deployment/frontend
```

**PRIVATE-GB:**
```sh
oc apply -f payment-processor/kubernetes.yaml
oc logs -f deployment/payment-processor
```

**PRIVATE-CH:**
```sh
oc apply -f payment-processor/kubernetes.yaml
oc logs -f deployment/payment-processor
```

**PRIVATE-US:**
```sh
oc apply -f payment-processor/kubernetes.yaml
oc logs -f deployment/payment-processor
```

**HUB:**
```sh
oc apply -f hub/kubernetes.yaml
oc logs -f deployment/hub-exate
```

**DATABASE-VM:**
```sh
# DB deployment
podman run --name database-target --network skupper --detach --rm -p 5432:5432 quay.io/avillega/patient-portal-database:exate

# DB Access
podman exec -it database-target psql -U patient_portal
```

## 8. Skupper network setup

### 8.1. Installation
Ensure yourself you have access to Alpha en Beta clusters before continuing


#### 8.2. Create Skupper network
**PUBLIC:**
```sh
skupper init --enable-console --enable-flow-collector
# Print Skupper console password
oc get secret skupper-console-users -n skupper-patient-portal-public -o jsonpath="{.data.admin}" | base64 -d | xargs echo
```

**PRIVATE-GB:**
```sh
skupper init --ingress none
```

**PRIVATE-CH:**
```sh
skupper init --ingress none
```

**PRIVATE-US:**
```sh
skupper init --ingress none
```

**HUB:**
```sh
skupper init
```

**DATABASE-VM:**
```sh
skupper init --ingress none
```

#### 8.3. Link Skupper sites

**PUBLIC:**
```sh
skupper token create --uses 2 ~/secret-public.token
scp -i ./skupper-node-a_key.pem ~/secret-public.token azureuser@172.187.147.100:/home/azureuser/secret-public.token
```

**DATABASE-VM:**
```sh
skupper link create ~/secret-public.token
skupper link status
```

**HUB:**
```sh
skupper link create ~/secret-public.token
skupper link status
skupper token create --uses 3 ~/secret-hub.token
```

**PRIVATE-GB:**
```sh
skupper link create ~/secret-hub.token
skupper link status
```

**PRIVATE-CH:**
```sh
skupper link create ~/secret-hub.token
skupper link status
```

**PRIVATE-US:**
```sh
skupper link create ~/secret-hub.token
skupper link status
```

#### 8.4. Expose application services
**PRIVATE-GB:**
```sh
skupper expose deployment/payment-processor --port 8080 --address payment-processor-gb
```

**PRIVATE-CH:**
```sh
skupper expose deployment/payment-processor --port 8080 --address payment-processor-ch
```

**PRIVATE-US:**
```sh
skupper expose deployment/payment-processor --port 8080 --address payment-processor-us
```

**DATABASE-VM:**
```sh
skupper service create database 5432
skupper service bind database host database-target --target-port 5432
```

**PUBLIC:**
```sh
skupper service create database 5432
```

**HUB:**
```sh
skupper expose deployment/hub-exate --port 8000 --address hub
```

#### 8.5. Deploy Apps

**PUBLIC:**
```sh
oc apply -f frontend/kubernetes.yaml
```

**PRIVATE-GB:**
```sh
oc apply -f payment-processor/kubernetes.yaml
```

**PRIVATE-CH:**
```sh
oc apply -f payment-processor/kubernetes.yaml
```

**PRIVATE-US:**
```sh
oc apply -f payment-processor/kubernetes.yaml
```

**HUB:**
```sh
oc apply -f hub/kubernetes.yaml
```

**DATABASE-VM:**
```sh
podman run --name database-target --network skupper --detach --rm -p 5432:5432 quay.io/skupper/patient-portal-database
```

#### 8.EXTRA Remove Skupper
**PUBLIC:**
```sh
skupper delete
```

**HUB:**
```sh
skupper delete
```

**PRIVATE-GB:**
```sh
skupper delete
```

**PRIVATE-CH:**
```sh
skupper delete
```

**PRIVATE-US:**
```sh
skupper delete
```

**DATABASE-VM:**
```sh
skupper delete
```

## Accessing the DB host
The DB host is stored on a separate VM RHEL9
```sh
ssh -i ./skupper-node-a_key.pem azureuser@172.187.147.100
```

## TODO
5. Include logic to don't create apptm cross-jurisdiction 


# Acknowledgments:
* Ted Ross
* Jens Freimann

### Deploying
```sh
oc new-project skupper-exate-patient-portal
oc apply -f frontend/kubernetes.yaml
```

podman exec -it database-target psql -U patient_portal

### Deploying

### Accessing the DB
```sh
```
