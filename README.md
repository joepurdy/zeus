# Zeus - Arcadia SRE Homework <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->

- [Background](#background)
- [Installing / Getting started](#installing--getting-started)
  - [Initial Configuration](#initial-configuration)
- [Architecture](#architecture)
  - [VPC](#vpc)
  - [App](#app)
  - [DB](#db)
- [References](#references)
- [Going further](#going-further)
  - [Scaling the DynamoDB tables](#scaling-the-dynamodb-tables)
  - [Better understanding of cross-referencing resource values with Stax](#better-understanding-of-cross-referencing-resource-values-with-stax)
  - [SSL certificate automation with ACM](#ssl-certificate-automation-with-acm)

## Background

I opted to review and learn the basics of [https://github.com/rlister/stax](https://github.com/rlister/stax) and [https://github.com/seanedwards/cfer](https://github.com/seanedwards/cfer) to complete the homework. While I haven't used either prior, instead primarily using Terraform as my Infrastructure-as-Code tool of choice, I was curious how Arcadia's team managed AWS resources and wanted to learn something new in the process.

I used [Gitpod](https://www.gitpod.io/) as a development environment, however reviewers won't need to learn/use Gitpod to review my solution. Feel free to ignore the [.gitpod.yml](.gitpod.yml) file and the [.gitpod/](.gitpod/) directory as this config is specific to Gitpod and not a part of the config for the homework.

If you have questions before we sync up and review together feel free to reach out by e-mail: [joe@purdy.dev](mailto:joe@purdy.dev). 

## Installing / Getting started

You'll need a working Ruby dev environment with bundler to get started. You'll also need to configure the AWS SDK with credentials for the AWS environment you want to provision infrastructure into. I used ephemeral sandbox AWS accounts provided by A Cloud Guru (see: [Cloud Sandbox](https://acloudguru.com/platform/cloud-sandbox-playgrounds)) for my testing.

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

docker tag public.ecr.aws/lambda/provided:al2 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/zeus/lambda-api:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/zeus/lambda-api:latest
```

## Architecture

I kept my solution minimal to both account for the timebox I was working with (I wanted to stay within 1-3 hours) and to allow for further discussion about how to scale or alter my solution during the team review interview that follows.

My solution creates three CloudFormation stacks:
- vpc
- app
- db

### VPC

The VPC stack is a straightforward AWS VPC for networked services from the App and DB stacks to communicate through. An Internet Gateway is attached to allow outgoing packets to the internet and VPC endpoints are created for private networking for S3 and DynamoDB from the DB stack.

### App

For the App stack I've included resources for deploying a statically compiled JavaScript web app to S3 and using CloudFront as a CDN. Note: I didn't include any actual application code with the homework, it's assumed that the web frontend can be deployed as static HTML, CSS, and JS to the S3 bucket and served via CloudFront.

I've also included a Lambda function that would act as an API layer between the web frontend and the DynamoDB and S3 resources from the database stack.

### DB

The DB stack provisions DynamoDB and an additional S3 bucket. My thinking here is that the DynamoDB service will hold application metadata about customer accounts and utility statements while the generated PDFs will be stored in the S3 bucket and referenced by a key stored in DynamoDB. 

## References

These are a few resources/references I found helpful while completing the homework:

- [github.com/rlister/stax](https://github.com/rlister/stax)
- [github.com/seanedwards/cfer](https://github.com/seanedwards/cfer)
- AWS CloudFormation Template Reference: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html

## Going further

### Scaling the DynamoDB tables

I opted to use a single region/replica DynamoDB Global Tables to allow future updates to scale the tables across multiple regions or multiple replicas as needed. This allows for flexible updates when/if there's a need for increased performance or redundency.

The tables also use autoscaling policies for Read and Write throughput giving additional knobs to tune when/if the time comes.

### Better understanding of cross-referencing resource values with Stax

Ran into a bunch of trouble trying to reference resources created in other blocks. Likely a simple learning curve to Stax/Cfer/CloudFormation. The error that finally did me in was `[FAIL] Template format error: Unresolved resource dependencies [WebBucketArn, WebBucketName] in the Resources block of the template`. I was trying to reference outputs from another resource and since that failed I just scratched the outputs all together and used `Fn::get_att()` instead.

### SSL certificate automation with ACM

I ended up altering my config not to use a custom domain afterall for the CloudFront distribution. I simply commented out the Alias config to leave it for reference. THe reason I backed this out was because to add an alternate domain to a CloudFront distribution you need to attach a SSL certificate and given the time limit and the complexity this would add for reviewers looking to provision my config in their own test accounts I opted to remove the custom domain bits.

This could certainly be handled with ACM though if you were trying to do this for real with a dedicated domain.

