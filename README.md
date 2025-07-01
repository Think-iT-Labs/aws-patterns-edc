# Set up a minimum viable data space to share data between organizations on AWS

# Summary

Data spaces are federated networks for data exchange with trust and control over one's data as core principles. They enable organizations to share, exchange, and collaborate on data at scale by offering a cost-effective and technology-agnostic solution.

Data spaces have the potential to significantly drive efforts for a sustainable future by using data-driven problem solving with an end-to-end approach that involves all relevant stakeholders.

This pattern guides you through the example of how two companies can use data space technology on Amazon Web Services (AWS) to drive their carbon emissions‒reduction strategy forward. In this scenario, company X provides carbon-emissions data, which company Y consumes. See the Additional information section for the following data space specification details:

* Participants
* Business case
* Data space authority
* Data space components
* Data space services
* Data to be exchanged
* Data model
* Tractus-X EDC connector

The pattern includes steps for the following:

* Deploying the infrastructure needed for a basic data space with two participants running on AWS.
* Exchanging carbon emissions‒intensity data by using the connectors in a secure way.

This deployment pattern provisions a Kubernetes cluster using Amazon Elastic Kubernetes Service (Amazon EKS) to host data space connectors and their associated services.

The [Eclipse Dataspace Components Connector (EDC)](https://github.com/eclipse-edc/Connector) control plane and data plane are both deployed on Amazon EKS. 

This setup uses a variant of Eclipse EDC called [Eclipse Tractus-X](https://github.com/eclipse-tractusx), which provides the [Tractus-X Connector](https://github.com/eclipse-edc/Connector) Helm chart to deploy the control plane, data plane, and required dependencies such as PostgreSQL and HashiCorp Vault.

A significant architectural enhancement in this pattern is the transition from a centralized identity to a decentralized identity model. It implements the [Eclipse Decentralized Claims Protocol (DCP)](https://eclipse-dataspace-dcp.github.io/decentralized-claims-protocol), which is the Eclipse EDC’s reference implementation for managing Decentralized Identifiers (DIDs) and Verifiable Credentials (VCs).

As the pattern is based on Eclipse Tractus-X, it integrates with the [Tractus-X Identity Hub](https://github.com/eclipse-tractusx/tractusx-identityhub), a service that enables participants in the data space to manage their DIDs and VCs.

To support decentralized identity functionality, the following components are included in the deployment:

* **DID Issuer:** A centralized component responsible for issuing Verifiable Credentials to participants within the data space.

* **BPN-DID Resolution Service (BDRS)**: Acts as a centralized directory mapping Business Partner Numbers (BPNs) to their corresponding DIDs.

# Prerequisites

* An active AWS account to deploy the infrastructure in your chosen AWS Region
* [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured in your chosen AWS Region
* [AWS security credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* [Git](https://github.com/git-guides/install-git)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [python](https://www.python.org/downloads/)
* [Postman](https://www.postman.com/downloads/)
* An [AWS Certificate Manager (ACM)](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) SSL/TLS certificate
* A domain name managed by [Amazon Route 53](https://aws.amazon.com/route53/) that will point to an Application Load Balancer (the DNS name must be covered by the ACM certificate)

#### Product versions

* AWS CLI version 2+
* Terraform 1.12.0+
* kubectl 1.32+
* python 3.8+
* Postman Collection v2.1

# Architecture

The MVDS architecture comprises one virtual private cloud (VPC) for Amazon EKS.

## Amazon EKS architecture

Data spaces are designed to be technology-agnostic solutions, and multiple implementations exist. This pattern uses an Amazon EKS cluster to deploy the data space technical components. The following diagram shows the deployment of the EKS cluster. Worker nodes are installed in private subnets.

![eks architecture](./assets/Amazon%20EKS%20architecture.png)

## Dataspace deployment architecture

As this pattern uses an Amazon EKS cluster to deploy the core components of the dataspace. Each participant (company X and company Y) operates its own EDC components (Tractus-X variant) and supporting services within isolated Kubernetes namespaces. 

A dedicated authority namespace hosts the DID issuer for credential issuance and the BDRS server for mapping Business Partner Numbers (BPNs) to their corresponding DIDs.

![dataspace deployment architecture](./assets/Data%20space%20deployment%20architecture.png)

# Tools

### AWS services

* [Amazon Elastic Compute Cloud (Amazon EC2)](https://docs.aws.amazon.com/ec2/) provides scalable computing capacity in the AWS Cloud. You can launch as many virtual servers as you need and quickly scale them up or down.
* [Amazon Elastic Kubernetes Service (Amazon EKS)](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) helps you run Kubernetes on AWS without needing to install or maintain your own Kubernetes control plane or nodes.
* [Amazon Simple Storage Service (Amazon S3)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) is a cloud-based object storage service that helps you store, protect, and retrieve any amount of data.
* [Elastic Load Balancing (ELB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html) distributes incoming application or network traffic across multiple targets. For example, you can distribute traffic across EC2 instances, containers, and IP addresses in one or more Availability Zones.
* [Amazon Route 53](https://docs.aws.amazon.com/route53/) is a scalable and highly available Domain Name System (DNS) web service that helps you register domain names and route internet traffic to AWS resources.
* [AWS Certificate Manager (ACM)](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) lets you easily provision, manage, and deploy SSL/TLS certificates for use with AWS services and your internal connected resources.

### Other tools

* [Git](https://git-scm.com/) is an open-source, distributed version control system.
* [Terraform](https://www.terraform.io/) is an infrastructure as code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language.
* [Helm](https://helm.sh/) is an open source package manager for Kubernetes that helps you install and manage applications on your Kubernetes cluster.
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) is a command-line interface that helps you run commands against Kubernetes clusters.
* [Python](https://www.python.org/) is a programming language that lets you work quickly and integrate systems more effectively, used here as a scripting language.
* [Postman](https://www.postman.com/) is an API platform.
* [HashiCorp Vault](https://www.vaultproject.io/) provides secure storage with controlled access for credentials and other sensitive information.
* [PostgreSQL](https://www.postgresql.org/) is an open source relational database management system (RDBMS) that uses and extends the SQL language.

### Code repository

The infrastructure provisioning, deployment code, and Python scripting for this pattern are available in the GitHub repository [aws-patterns-edc](https://github.com/Think-iT-Labs/aws-patterns-edc).

# Best practices

**Amazon EKS and isolation of participants’ infrastructures**

Namespaces in Kubernetes will separate the company X provider’s infrastructure from the company Y consumer’s infrastructure in this pattern. For more information, see [EKS Best Practices Guides](https://docs.aws.amazon.com/eks/latest/best-practices/security.html).

In a more realistic situation, each participant would have a separate Kubernetes cluster running within their own AWS account.

# Epics

## Epic 1: Set up the environment, and provision an EKS cluster and EC2 instances

This epic guides you through the steps to set up the environment and provision an Amazon EKS cluster and EC2 instances. As a result, you will have an Amazon EKS cluster running in a VPC with the necessary resources to deploy the data space components as outlined in the [Amazon EKS architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Amazon%20EKS%20architecture.png).

### Clone the repository

To get started, clone the repository to your local machine:

1. Open a terminal window.
2. Run the following commands:

```bash
git clone https://github.com/Think-iT-Labs/aws-patterns-edc.git
cd aws-patterns-edc
```

### Provision the Amazon EKS Cluster with Terraform

This pattern uses Terraform to automate the deployment of the Amazon EKS architecture in your AWS account. The required Terraform configuration files are located in the `infrastructure/eks/` directory.

#### Configure the AWS Region

The infrastructure is provisioned in the `eu-central-1` AWS Region by default. If you want to deploy to a different Region, you must update the following variables in the `infrastructure/eks/terraform.tfvars` file:

*   `aws_region`: Set this to your preferred AWS Region (e.g., `"us-west-2"`).
*   `eks_availability_zones`: Update the list of Availability Zones to match your chosen Region (e.g., `["us-west-2a", "us-west-2b"]`).

---

⚠️ **Important: Domain Name and ACM Certificate**

As stated in the [Prerequisites](https://github.com/Think-iT-Labs/aws-patterns-edc/tree/main?tab=readme-ov-file#prerequisites), a registered domain name and a corresponding AWS Certificate Manager (ACM) certificate are required for this pattern.

This domain name will be used to create the necessary DNS records (sub-domains) for the Application Load Balancer (ALB). The ALB is provisioned in the Amazon EKS cluster and uses Ingress resources to route external traffic to the Eclipse EDC components, securely exposing them to the internet.

For example, if you provide the domain name `aws-patterns-edc.io`, the pattern will automatically create sub-domains such as `companyx.aws-patterns-edc.io` to expose the company X components.

You must provide your domain name using the `-var` flag when applying the Terraform configuration. This domain must be secured with an ACM certificate that you have already created in your AWS account.

For instructions on how to request a public certificate, see the [Request a public certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) guide in the AWS documentation.

---

#### Apply the Infrastructure Terraform configuration

> **Note:** Before proceeding, ensure you have an active AWS session in your current terminal. Your local AWS credentials must have the necessary permissions to create and manage EKS clusters and related resources.

To provision the EKS cluster, run the following commands:

1.  Navigate to the EKS infrastructure directory:

    ```bash
    cd infrastructure/eks
    ```

2.  Initialize Terraform to download the required providers:

    ```bash
    terraform init
    ```

3.  Apply the Terraform configuration to create the AWS resources. Replace `<YOUR_DOMAIN_NAME>` with the domain name you configured in the prerequisites.

    ```bash
    terraform apply -var="domain_name=<YOUR_DOMAIN_NAME>"
    ```

    When prompted, review the execution plan and type `yes` to confirm. To bypass the interactive prompt, you can use the `-auto-approve` flag:

    ```bash
    terraform apply -var="domain_name=<YOUR_DOMAIN_NAME>" -auto-approve
    ```
    
> The provisioning process may take **about 10 to 15 minutes** to complete. Please wait until it finishes fully and ensure there are no errors in the Terraform CLI output.

#### Resources created by the Terraform configuration

The Terraform configuration creates the following resources by default, as designed in the [Amazon EKS architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Amazon%20EKS%20architecture.png) diagram:

- A **VPC** with two **public** and two **private** subnets.
- An **Internet Gateway** attached to the VPC for internet connectivity.
- A **NAT Gateway** to enable internet access from the private subnets.
- An **Amazon EKS cluster** configured with two `t3a.medium` nodes provisioned in the private subnets.

Additionally, the configuration installs several add-ons inside the EKS cluster, including:

- **Metrics Server** for cluster resources monitoring.
- **AWS Load Balancer Controller** to automatically provision Application Load Balancers (ALBs) for Kubernetes Ingress resources on EKS.
- **External DNS** to automatically manage DNS records in the Route 53 hosted zone record, linking them to ALBs based on Ingress resources in EKS.

After you provision the private cluster, add the new EKS cluster to your local Kubernetes configuration by running the following command:

```bash
aws eks update-kubeconfig --name aws-patterns-edc --region <AWS REGION>
```

> Replace `<AWS REGION>` with the AWS Region where you provisioned the EKS cluster (default = eu-central-1).

To confirm that your EKS nodes are running and are in the ready state, run the following command:

```bash
kubectl get nodes
```

#### Bastion Host Consideration (optional)

The provided Terraform configuration does not include Bastion Hosts by default. However, the architecture is designed to support them if needed. In such cases, a Bastion Host should be provisioned in a public subnet to enable secure administrative access to resources in the private subnets, such as EKS worker nodes.

## Epic 2: Deploying the data space components on Amazon EKS

This epic guides you through the steps to deploy the data space components on the Amazon EKS cluster you provisioned in the previous epic. By the end, you will have a fully functional data space with two participants (company X and company Y), each operating in isolated namespaces, as illustrated in the [Dataspace deployment architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Data%20space%20deployment%20architecture.png).

### Generate DID resources

As this pattern uses the [Eclipse Decentralized Claims Protocol (DCP)](https://eclipse-dataspace-dcp.github.io/decentralized-claims-protocol) for decentralized identity management, you must generate the required Decentralized Identifier (DID) resources before deploying the data space components. These resources are essential for secure identity and credential management within the data space.

The required DID resources are:

1. **Issuer key pair**
   - Private key: Used to sign verifiable credentials.
   - Public key: Used by others to verify those credentials.

2. **Issuer DID document**
   - A JSON document containing the issuer's public key and metadata, following the [W3C DID specification](https://www.w3.org/TR/did-core/).
   - Must be hosted at a public URL so all participants can retrieve and use it to verify credentials.
   - Enables cryptographic verification and trust in the data space.

3. **Verifiable credentials**
   - Digital credentials issued by the issuer to each participant (company X and company Y).
   - Each credential includes:
     - The participant's Decentralized Identifier (DID)
     - The participant's Business Partner Number (BPN)
   - Credentials are signed by the issuer's private key.
   - Membership credentials prove a participant is an authorized member of the data space.
   - Other participants and services verify these credentials using the issuer's public key.

This pattern uses the `did:web` method to create DIDs that are accessible via HTTPS. All DID resources are tied to a domain name, which must match the one used in your EKS Terraform setup.

To generate the required DID resources based on the domain name, a Python script is provided in the repository. Follow these steps:

```bash
cd ../../deployment/assets/did

# Ensure pip is installed and upgrade it
python3 -m ensurepip --upgrade
python3 -m pip install --upgrade pip

# Install dependencies
python3 -m pip install -r requirements.txt

# Apply the script to generate the DID resources
python3 jwt-gen.py --regenerate-keys --sign-jwts --domain <YOUR_DOMAIN_NAME> --assets-dir .
```

> Replace `<YOUR_DOMAIN_NAME>` with the domain name used during infrastructure provisioning.

#### DID resources generation output files

Upon successful execution of the script, the following DID resources will be generated in the current directory:

- `issuer.pub.json`: The issuer's public key
- `issuer.key.json`: The issuer's private key
- `issuer.did.json`: The issuer's DID document
- `companyx.membership.jwt`: Membership credential for company X
- `companyy.membership.jwt`: Membership credential for company Y

These files are now ready for deployment. In the next step, the Terraform configuration will automatically:

- Deploy the DID issuer document (`issuer.did.json`) and make it publicly accessible by all participants for verification.
- Distribute the membership credentials (`companyx.membership.jwt` and `companyy.membership.jwt`) to the respective EDC Identity-hub for company X and company Y.

This process ensures that both the authority (issuer) and participant (company X and company Y) components are properly initialized with the required decentralized identity resources.

### Apply the Data space Terraform configuration

To deploy the data space components, navigate to the `deployment` folder in the repository and run the following commands:

```bash
cd ../..

terraform init

terraform apply

# type "yes" and press enter when prompted to do so
# alternatively execute terraform apply -auto-approve
```

> The deployment process may take **about 2 to 5 minutes** to complete. Please wait until it finishes fully and ensure there are no errors in the Terraform CLI output.

After the deployment is complete, verify that all data space components are running and healthy on your EKS cluster. Run the following command to check the status of all pods in the authority, companyx, and companyy namespaces:

```bash
kubectl get pods --all-namespaces | grep -E "(authority|companyx|companyy|issuer|bdrs-server)"
```

> **Note:** Review the **STATUS** column for each pod. All pods should display "Running" or "Completed". If any pods are not in a healthy state, use `kubectl logs <pod-name> -n <namespace>` and `kubectl describe pod <pod-name> -n <namespace>` to investigate and resolve any issues before proceeding.

### Data space endpoints verification

This step ensures that the data space endpoints for the authority, company X, and company Y are correctly set up and accessible.

Each participant's endpoint is exposed via Kubernetes Ingress resources within the EKS cluster. These Ingresses automatically provision an Application Load Balancer (ALB) in AWS, configure routing rules, and create DNS records in Route 53 for each subdomain. This automation is handled by the AWS Load Balancer Controller and External DNS add-ons.

**Expected endpoints after deployment:**
- `issuer.<YOUR_DOMAIN_NAME>` - DID Issuer service for verifiable credentials
- `bdrs.<YOUR_DOMAIN_NAME>` - BPN-DID Resolution Service
- `companyx.<YOUR_DOMAIN_NAME>` - Company X EDC connector
- `companyy.<YOUR_DOMAIN_NAME>` - Company Y EDC connector

To verify that the endpoints are provisioned and ready to use, run the following commands (replace `<YOUR_DOMAIN_NAME>` with your actual domain):

> You may need to wait a few minutes (~5) after deployment for the DNS records to propagate.

```bash
nslookup issuer.<YOUR_DOMAIN_NAME>

nslookup bdrs.<YOUR_DOMAIN_NAME>

nslookup companyx.<YOUR_DOMAIN_NAME>

nslookup companyy.<YOUR_DOMAIN_NAME>
```

> **Expected Result:** If the endpoints are set up correctly, each command should return the IP address of the Application Load Balancer (ALB) associated with that endpoint. For example:
> ```
> Server:    8.8.8.8
> Address:   8.8.8.8#53
> 
> Non-authoritative answer:
> Name:   issuer.your-domain.com
> Address: 52.59.123.456
> ```

#### Additional verification commands

You can also test endpoint accessibility using curl commands:

```bash
# Test DID Issuer endpoint
curl -k https://issuer.<YOUR_DOMAIN_NAME>

# Test connector management endpoints
curl -k https://companyx.<YOUR_DOMAIN_NAME>
curl -k https://companyy.<YOUR_DOMAIN_NAME>
```

> **Note:** The `-k` flag allows curl to proceed with insecure connections, which may be necessary during initial setup before certificates are fully propagated.

#### Troubleshooting data space endpoints accessibility

If you do not see the expected IP addresses, try the following troubleshooting steps:

- Wait a few minutes and try again. Provisioning an Application Load Balancer and DNS propagation can take several minutes.
- Check the status of the AWS Load Balancer Controller and External DNS add-ons in your EKS cluster. Ensure their pods are running and review their logs for any errors:
  - `kubectl get pods -n kube-system | grep -E "(aws-load-balancer-controller|external-dns)"`
  - `kubectl logs <pod-name> -n kube-system`
- Verify that the DNS records in Route 53 are correctly created and point to the ALB's DNS name.
- Review the ALB configuration in the AWS Management Console to ensure it is active and associated with the correct target groups and listeners.

> **Note:** Addressing issues in these areas should resolve most endpoint accessibility problems.**

## Epic 3: Preparing the data asset

This epic guides you through the steps to prepare the carbon-emissions intensity data asset for sharing between company X (the provider) and company Y (the consumer) within the data space. 

Additionally, this epic covers the preparation of S3 buckets for both companies to securely store and receive the data asset during the transfer process.

### Prepare the carbon-emissions intensity data to be shared

First, you need to decide on the data asset to be shared. The data of company X represents the carbon-emissions footprint of its vehicle fleet. Weight is Gross Vehicle Weight (GVW) in tonnes, and emissions are in grams of CO2 per tonne-kilometer (g CO2 e/t-km) according to the Wheel-to-Well (WTW) measurement:

* Vehicle type: Van; weight: < 3.5; emissions: 800
* Vehicle type: Urban truck; weight: 3.5‒7.5; emissions: 315
* Vehicle type: Medium goods vehicle (MGV); weight: 7.5‒20; emissions: 195
* Vehicle type: Heavy goods vehicle (HGV); weight: > 20; emissions: 115

The example data is in the [carbon_emissions_data.json](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/carbon_emissions_data.json) file in the [aws-patterns-edc](https://github.com/Think-iT-Labs/aws-patterns-edc) repository.

The company X uses Amazon S3 bucket to store objects (the data asset to be shared).

To create the S3 bucket and store the example data object there as a provider (company X). The following commands create an S3 bucket with default security settings. We highly recommend consulting [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html).

```bash
aws s3api create-bucket --bucket <COMPANY_X_BUCKET_NAME> --region <AWS_REGION>
# You need to add '--create-bucket-configuration LocationConstraint=<AWS_REGION>' if you want to create # the bucket outside of us-east-1 region
```

> The S3 bucket name should be globally unique. For more information about naming rules, see the [AWS documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).

After the S3 bucket is created, you can upload the carbon emissions data asset to the S3 bucket using the following command:

```bash
aws s3api put-object --bucket <COMPANY_X_BUCKET_NAME> --key <S3_OBJECT_NAME> --body <PATH_OF_THE_FILE_TO_UPLOAD>
```

> For consistency, we recommend using the name `carbon_emissions_data.json` for the S3 object. This is the name used in the example data asset.

### Prepare a company Y S3 bucket to receive the data asset

Company Y needs to create an S3 bucket to receive the data asset shared by company X.

In the data transfer process, the company Y connector will receive the data asset from company X and use an `HTTP PUSH` operation to store the data asset in company Y's designated S3 bucket.

Similar to company X, the following commands create an S3 bucket with default security settings.

```bash
aws s3api create-bucket --bucket <COMPANY_Y_BUCKET_NAME> --region <AWS_REGION>
# You need to add '--create-bucket-configuration LocationConstraint=<AWS_REGION>' if you want to create the bucket outside of us-east-1 region
```

### IAM policy and User for S3 buckets of company X and company Y

The EDC connector currently doesn't use temporary AWS credentials, such as those provided by assuming a role. The EDC supports only the use of an [IAM access key ID and secret access key combination](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

As two S3 buckets are required for later steps. One S3 bucket is used for storing data made available by the provider. The other S3 bucket is for data received by the consumer.

The IAM user should have permission to read and write objects only in the two named buckets.

Access key ID and secret access key pair need to be created and kept safe. After this MVDS has been decommissioned, the IAM user should be deleted.

The following code is an example IAM policy for the user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1708699805237",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::<S3 Provider (company X) Bucket>",
        "arn:aws:s3:::<S3 Provider (company Y) Bucket>",
        "arn:aws:s3:::<S3 Provider (company X) Bucket>/*",
        "arn:aws:s3:::<S3 Provider (company Y) Bucket>/*"
      ]
    }
  ]
}
```

---

⚠️ **Important:**
In real-world scenarios, you should use two separate IAM users, one for each S3 bucket. This example uses a single IAM user for simplicity.

In a more realistic situation, you should:
- Create an IAM policy that grants access only to the S3 bucket of the provider (company X) and attach it to the IAM user that will be used by the EDC connector of company X.
- Create a separate IAM policy that grants access only to the S3 bucket of the consumer (company Y) and attach it to the IAM user that will be used by the EDC connector of company Y.

This ensures that each EDC connector has the minimum required permissions for its respective S3 bucket, following the principle of least privilege. 

## Epic 4: Provide company X carbon-emissions footprint data through the connector

This epic guides you through the steps to provide the carbon-emissions footprint data from company X (the provider) to company Y (the consumer) using the EDC connectors deployed in the previous epic.

### Set up Postman to interact with the connectors

After deploying the data space and verifying that both the company X and company Y connectors are running and accessible, you can interact with them from your workstation using Postman as an HTTP client.

This repository provides ready-to-use Postman Collections for both the provider (company X) and consumer (company Y) connectors. These collections contain pre-configured requests for common data space operations.

**To get started:**
1. Open Postman on your workstation.
2. Import the following collections from the `data-sharing/api-collections/` directory in this repository:
   - `companyx.postman_collection.json` (for the provider connector)
   - `companyy.postman_collection.json` (for the consumer connector)
3. Each collection uses Postman variables to simplify configuration. Before sending requests, set the required variables (such as connector URLs) in the collection setting. 

By using these collections, you can test and interact with both connectors, register data assets, initiate data transfers, and validate the end-to-end data sharing process between company X and company Y.

###  Register the data asset to the provider’s connector by using Postman

An EDC connector data asset holds the id of the data and its location. In this case, the EDC connector data asset will point to the created object `carbon_emissions_data.json` in the S3 bucket:

* **Connector**: company X

* **Request**:  Create Carbon Emissions Data Asset

* **Collection** Variables: 
  * Update `COMPANY_X_CONNECTOR_URL` variable to the URL of the company X connector (e.g. `https://companyx.<YOUR_DOMAIN_NAME>`). .
  * Update `ASSET_ID` variable in request body with a unique asset ID for the carbon emissions data asset (e.g. `carbon-emissions`). 

* **Request Body**: Update the request body with the S3 bucket details that you created for company X.

> **Note:** If you chose a different S3 object name when uploading the data asset to the S3 bucket, update the `objectName` field accordingly.

```json
"dataAddress": {
    "@type": "DataAddress",
    "type": "AmazonS3",
    "objectName": "carbon_emissions_data.json",
    "region": "<REPLACE WITH THE BUCKET REGION>",
    "bucketName": "<REPLACE WITH THE SOURCE BUCKET NAME>",
    "accessKeyId": "<REPLACE WITH YOUR ACCESS KEY ID>",
    "secretAccessKey": "<REPLACE WITH SECRET ACCESS KEY>"
}
```

> **Note:** Use the Access Key ID and Secret Access Key from the IAM user created in the [IAM policy and user](#iam-policy-and-user-for-s3-buckets-of-company-x-and-company-y) section.

* **Response:** A successful request returns the created time and the ID of the newly created asset.

```json
{
  "@type": "IdResponse",
  "@id": "carbon-emissions",
  "createdAt": 1751366701521,
  ...
}
```

### Define the usage policy of the asset

Every data asset in an EDC data space requires a clear usage policy. For this pattern, we will create a policy that grants access only to participants holding a valid **membership credential**.

This policy ensures that only trusted participants, who have been issued a Verifiable Credential (VC) by the data space authority, can access the carbon emissions data. This is a core concept for establishing trust and secure access control.

Here’s how the access control works:
1.  **Request**: When company Y requests the data, it presents its membership credential.
2.  **Verification**: Company X's EDC connector automatically verifies the credential's signature against the public key of the data space authority.
3.  **Access**: If the credential is valid and signed by the trusted authority, access is granted.

* **Connector**: company X

* **Request**: Create "Membership" policy

* **Collection** Variables:
  * Update `POLICY_ID` variable with a unique policy ID for the membership-required policy (e.g. `require-membership`).

* **Response:** A successful request returns the created time and the ID of the newly created policy. 

```json
{
  "@type": "IdResponse",
  "@id": "require-membership",
  "createdAt": 1751367495395,
  ...
}
```

### Define an EDC Contract Offer for the asset and its usage policy

To make your data asset available to other participants, you need to create a **contract offer**.

This offer bundles the data asset with the `Membership` usage policy, making it discoverable under specific terms. When another participant (like company Y) accepts the contract, they agree to your rules, and the EDC connector automatically enforces them.

* **Connector**: company X

* **Request**: Create Contract Definition

* **Collection** Variables:
  * Update `CONTRACT_DEFINITION_ID` variable with an ID for the contract offer or definition. (e.g. `carbon-emissions-membership`).
  
* **Response:** A successful request returns the created time and the ID of the newly created Contract Definition.

```json
{
  "@type": "IdResponse",
  "@id": "carbon-emissions-membership",
  "createdAt": 1751367896707,
  ...
}
```

## Epic 5: Discover the asset and reach agreement on the defined contract

This epic guides you through the steps to discover the carbon-emissions intensity data asset shared by company X (the provider) and reach an agreement on the defined contract with company Y (the consumer).

### Request the data catalog shared by company X

As a data consumer in the data space, company Y first needs to discover the data that is being shared by other participants.

In this basic setup, you can do this by asking the consumer (company Y) connector to request the catalog of available assets from the provider (company X) connector directly.

* **Connector**: company Y

* **Request**: Request Catalog

* **Collection** Variables:
  * Update `COMPANY_Y_CONNECTOR_URL` variable to the URL of the company Y connector in the request URL.
  * Update `COMPANY_X_CONNECTOR_URL`. Set this as the `counterPartyAddress` in the request body. This is the URL of the company X connector since the catalog is targeted at the company X connector.
  * Update `COMPANY_X_BPN`. Set this as the `counterPartyId` in the request body. This is company X's Business Partner Number (BPN) which is `BPNL000000000001` in this setup.

* **Response**: The response contains all available data assets from the provider. Find the asset you are interested in and extract the following IDs from the `dcat:dataset` object:

In the response, locate the `dcat:dataset` object. The following snippet shows where to find the asset ID (`@id`) and the contract offer ID (`odrl:hasPolicy` -> `@id`):

```json
    "dcat:dataset": {
        "@id": "carbon-emissions", # The asset ID
        "@type": "dcat:Dataset",
        "odrl:hasPolicy": {
            "@id": "Y2FyYm9uLWVtaXNzaW9ucy1tZW1...", # The contract offer ID
            "@type": "odrl:Offer",
    ...   
```

  * `ASSET_ID_CARBON_EMISSIONS` ‒ The ID of the asset the consumer wants to negotiate

  * `CONTRACT_OFFER_ID_CARBON_EMISSIONS` ‒ The ID of the contract offer the consumer wants to negotiate
  
> **Note:** You need the asset ID and contract offer ID to initiate the contract negotiation in the next step.

###  Initiate a contract negotiation for the carbon-emissions intensity data from company X

Now that you have identified the asset that you want to consume, initiate a contract negotiation process between the consumer (company Y) and provider (company X) connectors.

* **Connector**: company Y

* **Request**: Initiate negotiation

From the previous step, update the following collection variables with the values you obtained from the response of the Request Catalog request.

* **Collection** Variables: 
  * `CONTRACT_OFFER_ID_CARBON_EMISSIONS` ‒ The ID of the contract offer the consumer wants to negotiate
  * `ASSET_ID_CARBON_EMISSIONS` ‒ The ID of the asset the consumer wants to negotiate

The process might take some time before reaching the **Finalized** state.

####  Checking the contract negotiation state and get the contract agreement ID

You can check the state of the Contract Negotiation and the corresponding Contract Agreement ID.

* **Connector**: company Y

* **Request**: Get All Contract Negotiations

* **Response**: The response lists all contract negotiations initiated by company Y. Find the negotiation for the desired asset and confirm its `state` is `FINALIZED`. The `contractAgreementId` from this object is required for the next step.
 
```json
    {
      "@type": "ContractNegotiation",
      "@id": "4141a14f-def1-4be7-b37a-8ff1a7f4cfa6",
      "type": "CONSUMER",
      "protocol": "dataspace-protocol-http",
      "state": "FINALIZED",
      "counterPartyId": "BPNL000000000001",
      "counterPartyAddress": "https://companyx.<YOUR_DOMAIN_NAME>/api/v1/dsp",
      "callbackAddresses": [],
      "createdAt": 1751369661409,
      "contractAgreementId": "052545d0-fe05-4fb9-b05c-8de24cf66184", # The ID of the finalized contract agreement
    ...   
```

  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID` ‒ The ID of the contract agreement of the finalized contract negotiation. 

> **Note:** The contract Agreement ID is used in the next step to initiate the data transfer process.

## Epic 6: Consume the data by using the contract agreement

With a finalized contract, company Y now has the green light to access the data from company X. This epic demonstrates two ways to transfer the data using the EDC connector:

1.  **S3 Push Transfer**: The provider's EDC connector pushes the data directly from its S3 bucket to the consumer's S3 bucket. This is a direct, backend-to-backend transfer.

2.  **HTTP Pull Transfer**: The consumer's EDC connector pulls the data through a secure HTTP endpoint.

### Consume data from S3 buckets (Option 1)

Use Amazon S3 integration with the EDC connector, and directly point to the S3 bucket in the consumer infrastructure as a destination:

* **Connector**: company Y

* **Request**: Initiate Transfer Process S3 (Push)

* **Collection** Variables:
  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID`, ‒ The Contract Agreement ID from the contract negotiation step.

* **Request Body**: Update the request body with the S3 bucket details that you created for company Y.

```json
"dataDestination": {
      "@type": "DataAddress",
      "type": "AmazonS3",
      "objectName": "carbon_emissions_data.json",
      "region": "<REPLACE WITH THE BUCKET REGION>",
      "bucketName": "<REPLACE WITH THE SOURCE BUCKET NAME>",  
      "accessKeyId": "<REPLACE WITH YOUR ACCESS KEY ID>",
      "secretAccessKey": "<REPLACE WITH SECRET ACCESS KEY>"
}
```
> **Note:** Use the Access Key ID and Secret Access Key from the IAM user created in the [IAM policy and user](#iam-policy-and-user-for-s3-buckets-of-company-x-and-company-y) section.

You can monitor the transfer process status by using the `Get All Transfer Processes` request in the company Y connector collection. The transfer process should eventually reach the **COMPLETED** state, indicating that the carbon footprint data asset has been successfully transferred to the company Y S3 bucket.

To verify that the data asset has been successfully transferred, check the company Y S3 bucket using the following command:

```bash
aws s3 ls s3://<COMPANY_Y_BUCKET_NAME>/
```

You should see the `carbon_emissions_data.json` file listed in the output. To further verify the transfer, you can download and inspect the file content:

```bash
aws s3 cp s3://<COMPANY_Y_BUCKET_NAME>/carbon_emissions_data.json ./downloaded_carbon_emissions_data.json
cat downloaded_carbon_emissions_data.json
```

### Consume data from the provider's public HTTP endpoint (Option 2)

This option demonstrates how to use the HTTP proxy capability of the EDC connector to pull the data asset from the provider's public HTTP endpoint.

#### Initiate a data transfer process

Use the HTTP proxy capability of the EDC connector to pull the data asset from the provider's public HTTP endpoint:

* **Connector**: company Y

* **Request**: Initiate Transfer Process HTTP Proxy (Pull)

* **Collection** Variables:
  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID`, ‒ The Contract Agreement ID from the contract negotiation step.
  * `COMPANY_X_DID` ‒ The Decentralized Identifier (DID) for company X (e.g., `did:web:companyx.<YOUR_DOMAIN_NAME>`).

* **Response**: The response contains the ID of the transfer process that was initiated. This ID is used in the next step to retrieve an access token for the Endpoint Data Reference (EDR).

```json
{
  "@type": "IdResponse",
  "@id": "73e407be-d033-4f17-b799-8bf53b439b59", # Transfer process ID
  "createdAt": 1751374116234,
  ...
}
```

* `TRANSFER_PROCESS_ID` ‒ The ID of the transfer process is used in the next step to retrieve an access token.

You can monitor the transfer process status by using the `Get All Transfer Processes` request in the company Y connector collection. The transfer process should eventually reach the **STARTED** state, indicating that the data transfer process has been initiated and is ready to proceed.

####  Get an access token for The Endpoint Data Reference

To access the data asset, you need to obtain an access token for the Endpoint Data Reference (EDR) of the transfer process. This token is required to authenticate and authorize the data transfer from the provider's public endpoint.

* **Connector**: company Y

* **Request**: Get EDR Data Address for TransferId

* **Collection** Variables:
  * Update `TRANSFER_PROCESS_ID` variable in the request URL with the transfer process ID from the transfer process step.

* **Response**: The response contains the access token and the EDR endpoint URL (company X connector's public endpoint). The access token is used to authenticate requests to the EDR endpoint.

```json
{
    "@type": "DataAddress",
    "flowType": "PULL",
    "endpointType": "https://w3id.org/idsa/v4.1/HTTP",
    "tx-auth:refreshEndpoint": "https://companyx.<YOUR_DOMAIN_NAME>/api/public/token",
    "transferTypeDestination": "HttpData",
    "tx-auth:audience": "did:web:companyy.learning.think-it.io",
    "type": "https://w3id.org/idsa/v4.1/HTTP",
    "endpoint": "https://companyx.<YOUR_DOMAIN_NAME>/api/public", # The company X connector's public endpoint
    "tx-auth:refreshToken": "eyJraWQiOiJkaWQ6d2ViOmNvbXBh...",
    "tx-auth:expiresIn": "300",
    "authorization": "eyJraWQiOiJkaWQ6d2ViOmNvbXBhbnl4Lmx...", # The access token
    "tx-auth:refreshAudience": "did:web:companyy.<YOUR_DOMAIN_NAME>",
    ...
}
```

* `ACCESS_TOKEN` ‒ The access token is used to authenticate requests to the EDR endpoint in the next step.

####  Download the data asset

Now that you have the `access token` and the `EDR endpoint URL`, you can download the carbon emissions data asset from the provider's public endpoint.

* **Connector**: company Y

* **Request**: Get Data Asset from The Public Endpoint

* **Collection** Variables:
  * Update `AUTHORIZATION` variable in the **request Headers** tab with the access token you received in the previous step.

* **Response**: The response contains the carbon emissions data asset in JSON format. You can save this response to a file or process it as needed.

```json
{
  "region": "Europe and South America",
  "vehicles": [
    {
      "type": "Van",
      "gross_vehicle_weight": "<3.5 t GVW",
      "emission_intensity": {
        "CO2": 800, "unit": "g CO2 e/t-km (WTW)"
      }
    },
    ...
}
```

# Conclusion

🎉 **Congratulations!** You have successfully set up a minimum viable data space on AWS and completed your first secure data exchange between two organizations.

## What You've Accomplished

Throughout this guide, you have:
* **Infrastructure Deployment**: Provisioned a production-ready Amazon EKS cluster with essential add-ons for data space operations
* **Decentralized Identity Management**: Generated and configured DIDs and Verifiable Credentials using the Eclipse DCP protocol
* **EDC Connector Deployment**: Set up Eclipse Tractus-X connectors for both provider and consumer participants
* **Secure Data Sharing**: Successfully exchanged carbon emissions data using both S3-to-S3 and HTTP proxy transfer methods
* **Policy-Based Access Control**: Implemented membership-based policies to ensure only authorized participants can access shared data
* **End-to-End Verification**: Validated the complete data sharing workflow from asset registration to successful data transfer

## Clean Up Resources

To avoid unnecessary AWS charges, remember to clean up the resources when you're done experimenting:

### Step 1: Clean up the data space components

```bash
# Navigate to the deployment directory aws-patterns-edc/deployment
terraform destroy -auto-approve
```

### Step 2: Clean up the EKS infrastructure

```bash
# Navigate to the deployment directory infrastructure/eks
terraform destroy -auto-approve
```

# Further References

**Data Spaces Standards:**
- [International Data Spaces (IDS)](https://internationaldataspaces.org/) - Reference architecture and standards
- [Data Spaces Support Centre](https://dssc.eu/) - European initiative with best practices and guidelines
- [Gaia-X](https://gaia-x.eu/) - European data infrastructure standards and federation services

**Eclipse EDC Ecosystem:**
- [Eclipse EDC Documentation](https://eclipse-edc.github.io/) - Comprehensive guides and API references
- [Eclipse EDC GitHub](https://github.com/eclipse-edc) - Source code, samples, and community discussions
- [Tractus-X Documentation](https://eclipse-tractusx.github.io/) - Industry-specific implementations and use cases

**AWS Integration:**
- [AWS for Data Spaces](https://aws.amazon.com/government-education/aws-for-data-spaces/) - AWS-specific guidance and services
- [Building data spaces for sustainability use cases ](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-building-data-spaces/introduction.html)(AWS Prescriptive Guidance strategy by [Think-it](https://www.think-it.io/))

