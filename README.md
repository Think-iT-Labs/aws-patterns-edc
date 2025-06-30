# Set up a minimum viable data space to share data between organizations on AWS

## Summary

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

This setup uses a variant of Eclipse EDC called [Eclipse Tractus-X](https://github.com/eclipse-tractusx), which includes a Helm chart for deploying the control plane, data plane, and required dependencies such as PostgreSQL and HashiCorp Vault.

A significant architectural enhancement in this pattern is the transition from a centralized identity to a decentralized identity model. It implements the [Eclipse Decentralized Claims Protocol (DCP)](https://eclipse-dataspace-dcp.github.io/decentralized-claims-protocol), which is the Eclipse EDC’s reference implementation for managing Decentralized Identifiers (DIDs) and Verifiable Credentials (VCs).

As the pattern is based on Eclipse Tractus-X, it integrates with the [Identity Hub](https://github.com/eclipse-tractusx/tractusx-identityhub), a service that enables participants in the data space to manage their DIDs and VCs.

To enable decentralized identity functionality, the following components will also be deployed:

* DID Issuer: A component responsible for issuing Verifiable Credentials to participants within the data space.

* BPN-DID Resolution Service (BDRS): Acts as a centralized directory mapping Business Partner Numbers (BPNs) to their corresponding DIDs.

## Prerequisites

* An active AWS account to deploy the infrastructure in your chosen AWS Region
* [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured in your chosen AWS Region
* [AWS security credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* [Git](https://github.com/git-guides/install-git)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [python](https://www.python.org/downloads/)
* [Postman](https://www.postman.com/downloads/)
* An [AWS Certificate Manager (ACM)](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) SSL/TLS certificate
* A DNS name that will point to an Application Load Balancer (the DNS name must be covered by the ACM certificate)

#### Product versions

* AWS CLI version 2+
* Terraform 1.12.0+
* kubectl 1.32+
* python 3.8+
* Postman Collection v2.1

## Architecture

The MVDS architecture comprises one virtual private cloud (VPC) for Amazon EKS.

### Amazon EKS architecture

Data spaces are designed to be technology-agnostic solutions, and multiple implementations exist. This pattern uses an Amazon EKS cluster to deploy the data space technical components. The following diagram shows the deployment of the EKS cluster. Worker nodes are installed in private subnets.

![eks architecture](./assets/Amazon%20EKS%20architecture.png)

### Dataspace deployment architecture

This pattern uses an Amazon EKS cluster to deploy the core components of the dataspace. Each participant (Company X and Company Y) operates its own EDC components (Tractus-X variant) and supporting services within isolated Kubernetes namespaces. A dedicated authority namespace hosts the DID issuer for credential management and the BDRS server for mapping Business Partner Numbers (BPNs) to their corresponding DIDs.

![dataspace deployment architecture](./assets/Data%20space%20deployment%20architecture.png)

## Best practices

**Amazon EKS and isolation of participants’ infrastructures**

Namespaces in Kubernetes will separate the company X provider’s infrastructure from the company Y consumer’s infrastructure in this pattern. For more information, see [EKS Best Practices Guides](https://docs.aws.amazon.com/eks/latest/best-practices/security.html).

In a more realistic situation, each participant would have a separate Kubernetes cluster running within their own AWS account.

## Epics

### Set up the environment, and provision an EKS cluster and EC2 instances

This epic guides you through the steps to set up the environment and provision an Amazon EKS cluster and EC2 instances. As a result, you will have an Amazon EKS cluster running in a VPC with the necessary resources to deploy the data space components as outlined in the [Amazon EKS architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Amazon%20EKS%20architecture.png).

#### Clone the repository

To clone the repository to your workstation, run the following command:

```bash
git clone https://github.com/Think-iT-Labs/aws-patterns-edc

cd aws-patterns-edc
```

> The workstation must have access to your AWS account.

#### Provision Amazon EKS cluster architecture using Terraform

To deploy the Amazon EKS architecture in your AWS account, this pattern uses Terraform to automate the infrastructure setup. Follow the step-by-step instructions below to provision the necessary resources.

The Terraform configuration is organized in the `infrastructure` folder of the repository, which includes a subfolder:

* `eks`: includes the configuration files for provisioning the EKS cluster.

The Terraform configuration for this pattern uses the `eu-central-1` AWS Region by default.
However, you can change it to your preferred region by updating the `aws_region` variable in `eks/terraform.tfvars` file.
Additionally, ensure that the `eks_availability_zones` variable is updated to match the Availability Zones for your chosen region.

---

⚠️ **Important:**

As mentioned in the [Prerequisites](https://github.com/Think-iT-Labs/aws-patterns-edc/tree/main?tab=readme-ov-file#prerequisites) section, a domain name is required.

You must set the Terraform variable `domain_name` in the `eks/terraform.tfvars` file to your custom domain. This domain must also be secured with an ACM (AWS Certificate Manager) certificate that you've already created in AWS.

Follow this guide to [create an ACM certificate](https://docs.aws.amazon.com/res/latest/ug/acm-certificate.html).

---

To provision the EKS cluster, run the following commands:

```bash
cd infrastructure/eks

terraform init

terraform apply

# type "yes" and press enter when prompted to do so
# alternatively execute terraform apply -auto-approve
```

> The provisioning process may take **about 10 to 15 minutes** to complete. Please wait until it finishes fully and ensure there are no errors in the Terraform CLI output.

The Terraform configuration creates the following resources by default, as designed in the [Amazon EKS architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Amazon%20EKS%20architecture.png) diagram:

- A VPC with two **public** and two **private** subnets.
- An **Internet Gateway** attached to the VPC for internet connectivity.
- A **NAT Gateway** to enable internet access from the private subnets.
- An **Amazon EKS cluster** configured with two `t3a.medium` nodes provisioned in the private subnets.

Additionally, the configuration installs several add-ons inside the EKS cluster, including:

- **Metrics Server** for cluster resources monitoring.
- **AWS Load Balancer Controller** to automatically provision Application Load Balancers (ALBs) for Kubernetes Ingress resources on EKS.
- **External DNS** to automatically manage DNS records in the Route 53 hosted zone record, linking them to ALBs based on Ingress resources in EKS.

**Bastion Host Consideration (optional):**

The provided Terraform configuration does not include Bastion Hosts by default. However, the architecture is designed to support them if needed. In such cases, a Bastion Host should be provisioned in a public subnet to enable secure administrative access to resources in the private subnets, such as EKS worker nodes.

After you provision the private cluster, add the new EKS cluster to your local Kubernetes configuration by running the following command:

```bash
aws eks update-kubeconfig --name aws-patterns-edc --region <AWS REGION>
```

> Replace `<AWS REGION>` with the AWS Region where you provisioned the EKS cluster.

To confirm that your EKS nodes are running and are in the ready state, run the following command:

```bash
kubectl get nodes
```

### Deploy the data space

This epic guides you through the steps to deploy the data space components on the Amazon EKS cluster you provisioned in the previous epic. By the end, you will have a fully functional data space with two participants (Company X and Company Y), each operating in isolated namespaces, as illustrated in the [Dataspace deployment architecture](https://github.com/Think-iT-Labs/aws-patterns-edc/blob/main/assets/Data%20space%20deployment%20architecture.png).

#### Generate DID resources

As this pattern uses the [Eclipse Decentralized Claims Protocol (DCP)](https://eclipse-dataspace-dcp.github.io/decentralized-claims-protocol) for decentralized identity management, you must generate the required Decentralized Identifier (DID) resources before deploying the data space components. These resources are essential for secure identity and credential management within the data space.

The required DID resources include:

- **Issuer key pair:** A cryptographic key pair for the DID issuer. The private key is used to sign verifiable credentials, and the public key is used to validate them.
- **Issuer DID document:** A standardized JSON document that contains the issuer's `public key` and relevant metadata, following the [W3C DID specification](https://www.w3.org/TR/did-core/). This document must be hosted at a publicly accessible URL. This allows all participants in the data space to retrieve the document and verify digital credentials signed by the issuer. By enabling cryptographic verification, the DID document is essential for establishing trust in the data exchange environment.
- **Verifiable credentials:** These are digital credentials issued to each participant (Company X and Company Y) by the data space authority. Each credential contains the participant's `Decentralized Identifier` (DID) and `Business Partner Number` (BPN), and is cryptographically signed by the authority's private key. This pattern uses `Membership credentials` serve as proof that a participant is an authorized member of the data space. Other participants and services can verify these credentials using the authority's public key, ensuring trust and secure access within the data space.

This pattern uses the DID method web (`did:web`) to create DIDs that are resolvable via HTTP(S) endpoints. All DID resources are therefore linked to a specific domain name. The generation of DID resources is based on a domain name that you must provide—this should be the same domain name used in the Terraform configuration for the EKS cluster in the previous epic.

To generate the required DID resources based on the domain name, a Python script is provided in the repository. Follow these steps:

```bash
cd ../../deployment/assets/did

pip install -r requirements.txt

python3 jwt-gen.py --regenerate-keys --sign-jwts --domain <DOMAIN NAME> --assets-dir .
```

> Replace `<DOMAIN NAME>` with the domain name used during infrastructure provisioning.

**Output Files**

Upon successful execution of the script, the following DID resources will be generated in the current directory:

- `issuer.pub.json`: The issuer's public key
- `issuer.key.json`: The issuer's private key
- `issuer.did.json`: The issuer's DID document
- `companyx.membership.jwt`: Membership credential for Company X
- `companyy.membership.jwt`: Membership credential for Company Y

These files are now ready for deployment. In the next step, the Terraform configuration will automatically:

- Deploy the DID issuer document (`issuer.did.json`) and make it publicly accessible by all participants for verification.
- Distribute the membership credentials (`companyx.membership.jwt` and `companyy.membership.jwt`) to the respective EDC Identity-hub for Company X and Company Y.

This process ensures that both the authority (issuer) and participant (Company X and Company Y) components are properly initialized with the required decentralized identity resources.

#### Apply the Terraform configuration

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
kubectl get pods --all-namespaces | grep -E "(authority|companyx|companyy)"
```

Review the STATUS column for each pod. All pods should display "Running" or "Completed". If any pods are not in a healthy state, use `kubectl logs <pod-name> -n <namespace>` and `kubectl describe pod <pod-name> -n <namespace>` to investigate and resolve any issues before proceeding.

#### Data space endpoints verification

This step ensures that the data space endpoints for the authority, Company X, and Company Y are correctly set up and accessible.

Each participant's endpoint is exposed via Kubernetes Ingress resources within the EKS cluster. These Ingresses automatically provision an Application Load Balancer (ALB) in AWS, configure routing rules, and create DNS records in Route 53 for each subdomain (issuer.<DOMAIN NAME>,bdrs..<DOMAIN NAME>, companyx.<DOMAIN NAME>, companyy.<DOMAIN NAME>). This automation is handled by the AWS Load Balancer Controller and External DNS add-ons.

To verify that the endpoints are provisioned and ready to use, run the following commands (replace `<DOMAIN NAME>` with your actual domain):

```bash
nslookup issuer.<DOMAIN NAME>

nslookup bdrs.<DOMAIN NAME>

nslookup companyx.<DOMAIN NAME>

nslookup companyy.<DOMAIN NAME>
```

If the endpoints are set up correctly, each command should return the IP address of the Application Load Balancer (ALB) associated with that endpoint.

If you do not see the expected IP addresses, try the following troubleshooting steps:

- Wait a few minutes and try again. Provisioning an Application Load Balancer and DNS propagation can take several minutes.
- Check the status of the AWS Load Balancer Controller and External DNS add-ons in your EKS cluster. Ensure their pods are running and review their logs for any errors:
  - `kubectl get pods -n kube-system | grep -E "(aws-load-balancer-controller|external-dns)"`
  - `kubectl logs <pod-name> -n kube-system`
- Verify that the DNS records in Route 53 are correctly created and point to the ALB's DNS name.
- Review the ALB configuration in the AWS Management Console to ensure it is active and associated with the correct target groups and listeners.

Addressing issues in these areas should resolve most endpoint accessibility problems.


### Prepare the carbon-emissions intensity data to be shared.

First you need to decide on the data asset to be shared. The data of company X represents the carbon-emissions footprint of its vehicle fleet. Weight is Gross Vehicle Weight (GVW) in tonnes, and emissions are in grams of CO2 per tonne-kilometer (g CO2 e/t-km) according to the Wheel-to-Well (WTW) measurement:

* Vehicle type: Van; weight: < 3.5; emissions: 800

* Vehicle type: Urban truck; weight: 3.5‒7.5; emissions: 315

* Vehicle type: Medium goods vehicle (MGV); weight: 7.5‒20; emissions: 195

* Vehicle type: Heavy goods vehicle (HGV); weight: > 20; emissions: 115

The example data is in the carbon_emissions_data.json file in the aws-patterns-edc repository.

Company X uses Amazon S3 bucket to store objects (the data asset to be shared).

Create the S3 bucket and store the example data object there. The following commands create an S3 bucket with default security settings. We highly recommend consulting [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html).

```bash
aws s3api create-bucket <COMPANY_X_BUCKET_NAME> --region <AWS_REGION>
# You need to add '--create-bucket-configuration 
# LocationConstraint=<AWS_REGION>' if you want to create # the bucket outside of us-east-1 region

aws s3api put-object --bucket <COMPANY_X_BUCKET_NAM> \
 --key <S3 OBJECT NAME> \
 --body <PATH OF THE FILE TO UPLOAD>
```

> The S3 bucket name should be globally unique. For more information about naming rules, see the [AWS documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).

### Prepare Company Y s3 bucket to receive the data asset.
Company Y needs to create an S3 bucket to receive the data asset shared by Company X.
in reallty the company Y CONNECTOR AFTEREHRN IT COME FOR STRANGET IT WILL USE HTTP PUSH TO PUSH THE DATA ASSET TO THE COMPANY Y S3 BUCKET.
As fro comeny x The following commands create an S3 bucket with default security settings. We highly recommend consulting [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html).

```bash
aws s3api create-bucket <COMPANY_Y_BUCKET_NAME> --region <AWS_REGION>
# You need to add '--create-bucket-configuration 
# LocationConstraint=<AWS_REGION>' if you want to create # the bucket outside of us-east-1 region
```

### IAM policy and User for S3 buckets of Company X and comamany Y.

The EDC connector currently doesn't use temporary AWS credentials, such as those provided by assuming a role. The EDC supports only the use of an [IAM access key ID and secret access key combination](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

Two S3 buckets are required for later steps. One S3 bucket is used for storing data made available by the provider. The other S3 bucket is for data received by the consumer.

The IAM user should have permission to read and write objects only in the two named buckets.

An access key ID and secret access key pair needs to be created and kept safe. After this MVDS has been decommissioned, the IAM user should be deleted.

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
        "arn:aws:s3:::<S3 Provider (Company X) Bucket>",
        "arn:aws:s3:::<S3 Provider (Company Y) Bucket>",
        "arn:aws:s3:::<S3 Provider (Company X) Bucket>/*",
        "arn:aws:s3:::<S3 Provider (Company Y) Bucket>/*"
      ]
    }
  ]
}
```
**Important:**
In real-world scenarios, you should use two separate IAM users, one for each S3 bucket. This example uses a single IAM user for simplicity.

In production, you should:
- Create an IAM policy that grants access only to the S3 bucket of the provider (Company X) and attach it to the IAM user that will be used by the EDC connector of Company X.
- Create a separate IAM policy that grants access only to the S3 bucket of the consumer (Company Y) and attach it to the IAM user that will be used by the EDC connector of Company Y.

This ensures that each EDC connector has the minimum required permissions for its respective S3 bucket, following the principle of least privilege. 

### Provide Company X carbon-emissions footprint data through the connector

#### Set up Postman to interact with the connectors

After deploying the data space and verifying that both the Company X and Company Y connectors are running and accessible, you can interact with them from your workstation using Postman as an HTTP client.

This repository provides ready-to-use Postman Collections for both the provider (Company X) and consumer (Company Y) connectors. These collections contain pre-configured requests for common data space operations.

**To get started:**
1. Open Postman on your workstation.
2. Import the following collections from the `data-sharing/api-collections/` directory in this repository:
   - `companyx.postman_collection.json` (for the provider connector)
   - `companyy.postman_collection.json` (for the consumer connector)
3. Each collection uses Postman variables to simplify configuration. Before sending requests, set the required variables (such as connector URLs) in the collection setting. 

By using these collections, you can easily test and interact with both connectors, register data assets, initiate data transfers, and validate the end-to-end data sharing process between Company X and Company Y.

####  Register the data asset to the provider’s connector by using Postman.

An EDC connector data asset holds the id of the data and its location. In this case, the EDC connector data asset will point to the created object in the S3 bucket:

* **Connector**: Company X

* **Request**:  Create Carbon Emissions Data Asset

* **Collection** Variables: 
  * Update `COMPANY_X_CONNECTOR_URL` variable to the URL of the Company X connector.
  * Update `ASSET_ID`. Choose a unique asset ID for the carbon emissions data asset (e.g. `carbon-emissions`). 

* **Request Body**: Update the request body with the S3 bucket that you created for the Company X.

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
* **Response:** A successful request returns the created time and the asset ID of the newly created asset.
```json
{
  "@id": "c89aa31c-ec4c-44ed-9e8c-1647f19d7583"
}
```

#### Define the usage policy of the asset.

An EDC data asset must be associated with clear usage policies. First, create the Policy Definition in the Company X connector.

The policy of Company X for this carbon emissions asset is to allow only participants who hold an active membership credential. This credential must be a verifiable credential (VC) that is cryptographically bound to a Decentralized Identifier (DID) and issued according to the Decentralized Claims Protocol (DCP) as implemented in the EDC dataspace.

How it works:
- Each participant in the dataspace is identified by a DID (Decentralized Identifier).
- The membership credential is a verifiable credential (VC) issued to the participant's DID by the authority (issuer) using DCP.
- When a participant requests access to the asset, they must present their membership credential.
- The EDC connector verifies the credential by checking its cryptographic signature against the issuer's public key (published in the issuer's DID document).
- Only if the credential is valid, active, and signed by the recognized authority, access is granted.

This process ensures that only legitimate, authorized participants—who can prove their membership using a valid, issuer-signed verifiable credential—are able to access the asset. Legal access is strictly enforced based on decentralized identity (DID) and verifiable credential (VC) verification using DCP in the EDC dataspace.

Note: This is why, in previous steps of this guide (see "Generate DID resources"), we generate the issuer DID document and the membership credentials for both Company X and Company Y. These credentials are then seeded into the EDC Identity-hub. This process ensures that each participant has a unique Decentralized Identifier (DID) and a verifiable membership credential, issued and signed by the authority. When a participant requests access to a data asset, the EDC connector can verify the presented credential against the issuer's DID document, confirming its authenticity and active status. Only participants with valid, issuer-signed credentials—proving their membership in the data space—are granted access, enabling secure, decentralized, and automated access control in the EDC dataspace.


* **Connector**: Company X

* **Request**: Create "Membership" policy

* **Collection** Variables: 
  * Update `POLICY_ID`. Choose a unique policy ID for the membership-required policy (e.g. `require-membership`).

* Response: A successful request returns the created time and the policy ID of the newly created policy. Update the collection variable POLICY_ID with the ID of the policy generated by the EDC connector after creation.
```json
{
"@id": "c89aa31c-ec4c-44ed-9e8c-1647f19d7583"
}
```

#### Define an EDC Contract Offer for the asset and its usage policy

To allow other participants to request access to your data, offer it in a contract that specifies the usage conditions and permissions. 

The contract offer serves as a binding agreement that explicitly links the data asset you created with the associated usage policy ("Membership"). By creating a contract offer, you define the terms under which the asset can be accessed and used.
This ensures that any participant requesting access to the asset must agree to and comply with the specified policy conditions (such as holding a valid, issuer-signed membership credential).
The EDC connector enforces these terms, enabling secure and automated access control in the data space.

* **Connector**: Company X

* **Request**: Create Contract Definition

* **Collection** Variables:
  * Update `CONTRACT_DEFINITION_ID` variable with an ID for the contract offer or definition. (e.g. `carbon-emissions-membership`).
* Response: A successful request returns the created time and the policy ID of the newly created policy. Update the collection variable POLICY_ID with the ID of the policy generated by the EDC connector after creation.
```json
{
"@id": "c89aa31c-ec4c-44ed-9e8c-1647f19d7583"
}
```

### Discover the asset and reach agreement on the defined contract

#### Request the data catalog shared by Company X.

As a data consumer in the data space, Company Y first needs to discover the data that is being shared by other participants.

In this basic setup, you can do this by asking the consumer (Company Y) connector to request the catalog of available assets from the provider (Company X) connector directly.

* **Connector**: Company Y

* **Request**: Request Catalog

* **Collection** Variables:
  * Update `COMPANY_Y_CONNECTOR_URL` variable to the URL of the Company Y connector in the request URL.
  * Update `COMPANY_X_CONNECTOR_URL`. Set this as the `counterPartyAddress` in the request body. This is the URL of the Company X connector since the catalog is targeted at the Company X connector.
  * Update `COMPANY_X_BPN`. Set this as the `counterPartyId` in the request body. This is Company X's Business Partner Number (BPN) which is `BPNL000000000001` in this setup.

* **Response**: All available data assets from the provider together with their attached usage policies. As a data consumer, look for the contract of your interest and update the following collection variables accordingly.

  * `CONTRACT_OFFER_ID_CARBON_EMISSIONS` ‒ The ID of the contract offer the consumer wants to negotiate
  
  * `ASSET_ID_CARBON_EMISSIONS` ‒ The ID of the asset the consumer wants to negotiate


####  Initiate a contract negotiation for the carbon-emissions intensity data from company X

Now that you have identified the asset that you want to consume, initiate a contract negotiation process between the consumer (company Y) and provider (company X) connectors.

* **Connector**: Company Y

* **Request**: Initiate negotiation

From the previous step, update the following collection variables with the values you obtained from the response of the Request Catalog request.
* **Collection** Variables: 
  * `CONTRACT_OFFER_ID_CARBON_EMISSIONS` ‒ The ID of the contract offer the consumer wants to negotiate
  
  * `ASSET_ID_CARBON_EMISSIONS` ‒ The ID of the asset the consumer wants to negotiate

The process might take some time before reaching the **Finalized** state.

####  Checking the contract negotiation state and get the contract agreement ID

You can check the state of the Contract Negotiation and the corresponding Contract Agreement ID.

* **Connector**: Company Y

* **Request**: Get All Contract Negotiations

* **Response**: All available data assets from the provider together with their attached usage policies. As a data consumer, look for the contract of your interest and update the following collection variables accordingly.

  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID` ‒ The ID of the contract agreement of the finalized contract negotiation. This ID is used in the next step to initiate the data transfer process.

### Consume the data by using the contract agreement

After a successful contract negotiation, Company Y, as the consumer, can initiate a data transfer process based on the agreed-upon contract. This process will leverage the capabilities of the Eclipse Data Connector (EDC).

Specifically, two key EDC connector features will be used in this pattern:

* **AWS S3 Integration (Push)**: The data asset will be directly transferred from Company X’s (the provider’s) S3 bucket and pushed to Company Y’s (the consumer’s) S3 bucket using the EDC connector, leveraging the "HttpData-PUSH" transfer type.

* **HTTP Proxy (Pull)**: For data asset accessible via an HTTP endpoint, the EDC connector will use its HTTP proxy capability to pull the data from Company X's public HTTP proxy endpoint, leveraging the "HttpData-PULL" transfer type.

#### Consume data from S3 buckets (Option 1)

Use Amazon S3 integration with the EDC connector, and directly point to the S3 bucket in the consumer infrastructure as a destination:

* **Connector**: Company Y

* **Request**: Initiate Transfer Process S3 (Push)

* **Collection** Variables:
  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID`, ‒ The Contract Agreement ID from the contract negotiation step.

* **Request Body**: Update the request body with the S3 bucket that you created for the Company Y.

```json
"dataDestination": {
      "@type": "DataAddress",
      "type": "AmazonS3",
      "objectName": "carbon_emissions_data.json",
      "region": "",
      "bucketName": "",
      "accessKeyId": "",
      "secretAccessKey": ""
}
```

You can check the status of the transfer process by using the `Get All Transfer Processes` request in the Company Y connector collection. The transfer process should eventually reach the **Started** state, indicating that the data has been started transferring the carbon foorptin data asset to the Company Y S3 bucket.

Check the S3 bucket of Company Y to verify that the data asset has been successfully transferred.


#### Consume data from the provider public HTTP endpoint (Option 2)

#### Initiate a data transfer process

Use the HTTP proxy capability of the EDC connector to pull the data asset from the provider's public HTTP endpoint:

* **Connector**: Company Y

* **Request**: Initiate Transfer Process HTTP Proxy (Pull)

* **Collection** Variables:
  * `CARBON_EMISSIONS_CONTRACT_AGREEMENT_ID`, ‒ The Contract Agreement ID from the contract negotiation step.

You can check the status of the transfer process by using the `Get All Transfer Processes` request in the Company Y connector collection. The transfer process should eventually reach the **Started** state.

* `TRANSFER_PROCESS_ID` ‒ The ID of the transfer process is used in the next step to retrieve an access token.

####  Get an access token for The Endpoint Data Reference

To access the data asset, you need to obtain an access token for the Endpoint Data Reference (EDR) of the transfer process. This token is required to authenticate and authorize the data transfer from the provider's public endpoint.

* **Connector**: Company Y

* **Request**: Get EDR Data Address for TransferId

* **Collection** Variables:
  * Update `TRANSFER_PROCESS_ID` variable in the request URL with the transfer process ID from the transfer process step.

The received payload is similar to the following:

```json
{
  "id": "dcc90391-3819-4b54-b401-1a005a029b78",
  "endpoint": "http://consumer-tractusx-connector-dataplane.consumer:8081/api/public",
  "authKey": "Authorization",
  "authCode": "<AUTH CODE YOU RECEIVE IN THE ENDPOINT>",
  "properties": {
    "https://w3id.org/edc/v0.0.1/ns/cid": "vehicle-carbon-footprint-contract:4563abf7-5dc7-4c28-bc3d-97f45e32edac:b073669b-db20-4c83-82df-46b583c4c062"
  }
}
```

####  Download the data asset

To download the data asset from the provider's public endpoint, you need to use the access token obtained in the previous step. This token will authenticate your request to access the data.

* **Connector**: Company Y

* **Request**: Get Data Asset from The Public Endpoint

* **Collection** Variables:
  * Update `COMPANY_X_CONNECTOR_URL` variable in the request URL with the provider (company X) connector URL.
  * Update `AUTHORIZATION` variable in the request Headers tab with the access token you received in the previous step.
  > Important: do not prepend a bearer prefix!

This will return the carbon emissions data asset in the response body.