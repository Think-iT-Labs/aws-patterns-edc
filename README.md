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

This pattern deploys a Kubernetes cluster that will host data space connectors and their services through Amazon Elastic Kubernetes Service (Amazon EKS).

The [Eclipse Dataspace Components (EDC)](https://github.com/eclipse-edc) control plane and data plane are both deployed on Amazon EKS. The official Tractus-X Helm chart deploys PostgreSQL and HashiCorp Vault services as dependencies.

In addition, this pattern replaces the centralized identity service used in previous versions with a decentralized identity model. It uses the [Eclipse Decentralized Claims Protocol](https://eclipse-dataspace-dcp.github.io/decentralized-claims-protocol), which is the Eclipse EDC’s implementation for decentralized identity.

## Prerequisites

* An active AWS account to deploy the infrastructure in your chosen AWS Region
* [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured in your chosen AWS Region
* [AWS security credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* [Git](https://github.com/git-guides/install-git) on your workstation
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/)
* [Postman](https://www.postman.com/downloads/)
* An [AWS Certificate Manager (ACM)](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) SSL/TLS certificate
* A DNS name that will point to an Application Load Balancer (the DNS name must be covered by the ACM certificate)

#### Product versions

* AWS CLI version 2+
* Terraform 1.12.0+
* kubectl 1.32+
* Helm 3
* Postman Collection v2.1

## Architecture

The MVDS architecture comprises one virtual private cloud (VPC) for Amazon EKS.

### Amazon EKS architecture

Data spaces are designed to be technology-agnostic solutions, and multiple implementations exist. This pattern uses an Amazon EKS cluster to deploy the data space technical components. The following diagram shows the deployment of the EKS cluster. Worker nodes are installed in private subnets.

![eks architecture](./assets/Amazon%20EKS%20architecture.png)

## Best practices

**Amazon EKS and isolation of participants’ infrastructures**

Namespaces in Kubernetes will separate the company X provider’s infrastructure from the company Y consumer’s infrastructure in this pattern. For more information, see [EKS Best Practices Guides](https://docs.aws.amazon.com/eks/latest/best-practices/security.html).

In a more realistic situation, each participant would have a separate Kubernetes cluster running within their own AWS account.

## Epics
(click on ▶ to expand or ▼ to collapse)

<details>
  <summary><strong style="font-size:1.17em; font-weight:bold;">Set up the environment, and provision an EKS cluster and EC2 instances</strong></summary>

#### Clone the repository

To clone the repository to your workstation, run the following command:

```bash
git clone https://github.com/Think-iT-Labs/aws-patterns-edc
cd aws-patterns-edc/infrastructure
```
>The workstation must have access to your AWS account.

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
cd .. 
cd eks
terraform init
terraform plan
terraform apply -auto-approve
```
>The provisioning process may take **about 10 to 15 minutes** to complete. Please wait until it finishes fully and ensure there are no errors in the Terraform CLI output.

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
>Replace `<AWS REGION>` with the AWS Region where you provisioned the EKS cluster.

To confirm that your EKS nodes are running and are in the ready state, run the following command:

```bash
kubectl get nodes
```