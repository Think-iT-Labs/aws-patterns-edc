# Setup a Minimum Viable Data Space (MVDS) on AWS

Data spaces are federated networks for data exchange with trust and control over one's data as core principles. 

They enable organisations to share, exchange and collaborate on data at scale by offering a cost-effective and technology agnostic solution. 

Data spaces have the potential to significantly drive our efforts for a sustainable future by leveraging data-driven problem solving with an end-to-end approach that involves all relevant stakeholders.

In this pattern, we guide you through the example of how two companies can leverage data space technology on top of AWS to drive their carbon emissions intensity strategy forward.

Concretely, we provide guided steps on:

1. How to deploy the infrastructure needed for a simple data space with two participants on top of AWS.
2. How to exchange carbon emissions intensity data using the connectors in a sovereign way.

This pattern deploys a Kubernetes cluster that will host data space connectors and their services via Amazon EKS. 

Both the EDC control plane and data plane will be deployed on Amazon EKS and we use the official Tractus-X helm chart that deploys PostgreSQL and Vault services as dependencies. 

In addition, we deploy the identity service on Amazon EC2 in order to replicate a real life scenario of an MVDS. 

> Public link to the AWS Pattern: https://think-it.notion.site/Setup-a-Minimum-Viable-Data-Space-MVDS-on-AWS-c6c4fcff638d476f9159b1ad5534cf2b