# AWS Terraform Exercise

This has been tested using Terraform v0.11.x we advise you use this version as we will test your code with the same.

Please respond with a zip including your git files so the history of commits is included. Document your solution and notes on how to run it in a `NOTES.md` markdown file and include it in the root directory with this `README.md`.

Here we have some Terraform which builds a simple VPC. For now, we have just one instance running the web server Nginx in its default configuration, serving up the default welcome page.

To run the terraform use the following command:

```bash
terraform apply -var-file=dublin.tfvars
```

You can test the deployment using the following command:

```bash
terraform output web_domain | xargs curl
```

Complete all exercises, making sure to use git appropriately. Feel free to modify and refactor the existing code in order to best achieve your solution.

Exercises:

1. The EC2 instance running Nginx went down over the weekend and we had an outage, it's been decided that we need a solution that is more resilient. Please implement a solution that demonstrates best practice resilience within a single region.

2. We would like to be able to run the same stack closer to our customers in the US. Please build the same stack in the us-east-1 (Virginia) region. Note that Virginia has a different number of availability zones which we would like to take advantage of for better resilience. As for a CIDR block for the VPC use whatever you feel like, providing it's compliant with RFC-1918 and does not overlap with the dublin network.

3. We are looking to improve the security of our network and have decided we need a bastion server to avoid logging on directly to our servers. Add a bastion server, the bastion should be the only route to SSH onto servers in the VPC.

4. The team have decided to use the Java framework Spring Boot to build features for our website. Deploy the following sample application into the VPC, reconfigure Nginx as a reverse proxy to the Java app. Provide a Terraform output/curl command to get the hello world text that the application serves.

The sample java spring boot app is available here
`https://github.com/sebwells/example-java-spring-boot-app`
