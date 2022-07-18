# Zeus - Arcadia SRE Homework <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->

- [Background](#background)
- [Installing / Getting started](#installing--getting-started)
  - [Initial Configuration](#initial-configuration)
- [Architecture Overview](#architecture-overview)
  - [App](#app)
  - [DB](#db)
- [References](#references)
- [Going further](#going-further)
  - [Scaling the DynamoDB tables](#scaling-the-dynamodb-tables)
  - [Better understanding of cross-referencing resource values with Stax](#better-understanding-of-cross-referencing-resource-values-with-stax)
  - [SSL certificate automation with ACM](#ssl-certificate-automation-with-acm)
  - [Improve IAM roles/permissions](#improve-iam-rolespermissions)
  - [Additional functions or a monolith API service](#additional-functions-or-a-monolith-api-service)

## Background

I opted to review and learn the basics of [https://github.com/rlister/stax](https://github.com/rlister/stax) and [https://github.com/seanedwards/cfer](https://github.com/seanedwards/cfer) to complete the homework. While I haven't used either prior, instead primarily using Terraform as my Infrastructure-as-Code tool of choice, I was curious how Arcadia's team managed AWS resources and wanted to learn something new in the process.

I used [Gitpod](https://www.gitpod.io/) as a development environment, however reviewers won't need to learn/use Gitpod to review my solution. Feel free to ignore the [.gitpod.yml](.gitpod.yml) file and the [.gitpod/](.gitpod/) directory as this config is specific to Gitpod and not a part of the config for the homework.

If you have questions before we sync up and review together feel free to reach out by e-mail: [joe@purdy.dev](mailto:joe@purdy.dev). 

## Installing / Getting started

You'll need a working Ruby dev environment with bundler to get started. You'll also need to configure the AWS SDK with credentials for the AWS environment you want to provision infrastructure into. You'll also need to create and push an image to an ECR repository for the Lambda function. Review the [Initial Configuration](#initial-configuration) section below for more details.

I used ephemeral sandbox AWS accounts provided by A Cloud Guru (see: [Cloud Sandbox](https://acloudguru.com/platform/cloud-sandbox-playgrounds)) for my testing.

```shell
# Install Ruby deps with bundler
cd ops/ && bundle install

# Invoke stax to provision infrastructure with CloudFormation
bundle exec stax create
```

Running the above commands will install Ruby dependencies and use stax to provision the infrastructure according to the config I wrote for this homework. If you want to destroy the infrastructure you can run `bundle exec stax delete` from within the `ops/` directory.

### Initial Configuration

As mentioned previously you'll need to configure the AWS SDK, there's a number of ways to do this and you can review the [official docs for the AWS Ruby SDK](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html) if you'd like to go over all the options. The method I used while working on this was to set specific environment variables.

```shell
# Configure environment variables for AWS SDK
export AWS_ACCESS_KEY_ID=AKIA***************
export AWS_SECRET_ACCESS_KEY=************************
export AWS_ACCOUNT_ID=1234**********
export AWS_REGION=us-east-1
```

You'll also need to create an ECR repository with a container image for the lambda function and push an image:
```shell
aws ecr create-repository \
  --repository-name zeus/lambda-api

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker pull public.ecr.aws/lambda/provided:al2
docker tag public.ecr.aws/lambda/provided:al2 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/zeus/lambda-api:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/zeus/lambda-api:latest
```

## Architecture Overview

I kept my solution minimal to both account for the timebox I was working with (I wanted to stay within 1-3 hours) and to allow for further discussion about how to scale or alter my solution during the team review interview that follows.

My solution creates two CloudFormation stacks:
- app
- db

### App

For the App stack I've included resources for deploying a statically compiled JavaScript web app to S3 and using CloudFront as a CDN. Note: I didn't include any actual application code with the homework, it's assumed that the web frontend can be deployed as static HTML, CSS, and JS to the S3 bucket and served via CloudFront.

I've also included a Lambda function that would act as an API layer between the web frontend and the DynamoDB and S3 resources from the database stack. An IAM policy was crafted to permit read only access from the Lambda function to the resources from the DB stack.

### DB

The DB stack provisions two DynamoDB global tables (in a single region) and an additional S3 bucket. My thinking here is that the DynamoDB tables will hold application metadata about customer accounts and utility statements while the generated PDFs will be stored in the S3 bucket and referenced by a key stored in the DynamoDB statements table.

Using global tables in a single region results in the same billing costs as provisioning a non-global table while allowing future scalabilty if needed by increasing replicas and adjusting autoscaling policies for reads and writes.

## References

These are a few resources/references I found helpful while completing the homework:

- [github.com/rlister/stax](https://github.com/rlister/stax)
- [github.com/seanedwards/cfer](https://github.com/seanedwards/cfer)
- [github.com/rlister/divvy][github.com/rlister/divvy]
  - This came in handy as an idiomatic reference by stax' author on how to link non-trivial resources together
- AWS CloudFormation Template Reference: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html
- IAM JSON policy reference: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html

## Going further

As I completed the homework I added some additional notes in the sections below describing some thoughts I had around ways to improve or expand on the solution given more time and context.

### Scaling the DynamoDB tables

I opted to use a single region/replica DynamoDB Global Tables to allow future updates to scale the tables across multiple regions or multiple replicas as needed. This allows for flexible updates when/if there's a need for increased performance or redundency.

The tables also use autoscaling policies for Read and Write throughput giving additional knobs to tune when/if the time comes.

### Better understanding of cross-referencing resource values with Stax

I encountered errors trying to reference resources created in other blocks early on. Likely a simple learning curve to Stax/Cfer/CloudFormation where my intution didn't match the design of these tools. The error that finally did me in was `[FAIL] Template format error: Unresolved resource dependencies [WebBucketArn, WebBucketName] in the Resources block of the template`. I was trying to reference outputs from another resource and since that failed I just scratched the outputs all together and used `Fn::get_att()` instead. With more exposure and practice with Stax I would expect to understand the idiomatic way to make these references.

Note: Later on when working to create an IAM policy granting read access to the Lambda function from the app stack to resources from the db stack I had to figure out an idiomatic way to reference resources created elsewhere. I learned to link outputs to parameters and import their values to resources with `Fn::import_value()` by reviewing [github.com/rlister/divvy][github.com/rlister/divvy] for examples.

### SSL certificate automation with ACM

I ended up altering my config not to use a custom domain for the CloudFront distribution. I simply commented out the Alias config to leave my original direction for reference. The reason I backed this out was because to add an alternate domain to a CloudFront distribution you need to attach a SSL certificate and given the time limit and the complexity this would add for reviewers looking to provision my config in their own test accounts I opted to remove the custom domain config. This could certainly be handled with ACM though if you were trying to do this for real with a dedicated domain.

### Improve IAM roles/permissions

I've been using GCP (Google Cloud Platform) rather than AWS in my most recent role and my IAM knowledge is rusty. I used the reference docs to add role permissions to the lambda function from the app stack that I believe would grant read access to data stored in the DynamoDB and S3 resources provisioned in the db stack. That said, I suspect there's more to be done and/or improved on the IAM permissions. With more time and collaboration with a regular IAM practitioner I would likely improve the security controls for the resources managed.

[github.com/rlister/divvy]: https://github.com/rlister/divvy

### Additional functions or a monolith API service

The current architecture only supplies permission to the lambda function for reading data from resources in the DB stack. Given the core prompt for the homework was to create infrastructure for "an AWS application that will allow a customer to look up their Arcadia Power utility statement through a web interface" I'd say read only access satisfies that. However, in a real-world scenario I'd assume we need additional infrastructure to handle writing new data and updating existing values.

Depending on the full requirements of the application the lambda function aspect of the App stack could be expanded for additional functionality/functions or changed to a more monolithic API service to satisfy a broad range of requirements.