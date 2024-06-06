# Set up a minimum viable data space to share data between organizations - Repository for the AWS Pattern Guide

Data spaces are federated networks for data exchange with trust and control over one's data as core principles. They enable organizations to share, exchange, and collaborate on data at scale by offering a cost-effective and technology-agnostic solution.

Data spaces have the potential to significantly drive efforts for a sustainable future by using data-driven problem solving with an end-to-end approach that involves all relevant stakeholders.

This pattern guides you through the example of how two companies can use data space technology on Amazon Web Services (AWS) to drive their carbon emissions‒reduction strategy forward. In this scenario, company X provides carbon-emissions data, which company Y consumes. 

See the Additional information section in the AWS Pattern Guide for the following data space specification details:

* Participants
* Business case
* Data space authority
* Data space components
* Data space services
* Data to be exchanged
* Data model

The pattern includes steps for the following:
* Deploying the infrastructure needed for a basic data space with two participants running on AWS.
* Exchanging carbon emissions‒intensity data by using the connectors in a secure way.

This pattern deploys a Kubernetes cluster that will host data space connectors and their services through Amazon Elastic Kubernetes Service (Amazon EKS).

The Eclipse Dataspace Components (EDC) control plane and data plane are both deployed on Amazon EKS. The official Tractus-X Helm chart deploys PostgreSQL and HashiCorp Vault services as dependencies.

In addition, the identity service is deployed on Amazon Elastic Compute Cloud (Amazon EC2) to replicate a real-life scenario of a minimum viable data space (MVDS).

> Public link to the AWS Pattern: https://think-it.notion.site/Setup-a-Minimum-Viable-Data-Space-MVDS-on-AWS-c6c4fcff638d476f9159b1ad5534cf2b
