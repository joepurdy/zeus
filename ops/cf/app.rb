description 'app stack'

## stack dependencies
parameter :db, type: :String

## DNS domains for route53
parameter :domain, type: :String, default: 'hjkl.cloud'
parameter :subdomain, type: :String, default: 'zeus'

## Lambda container image for API service
# note: in real world usage this image would reference a container with actual application code
accountId = ENV['AWS_ACCOUNT_ID'] || 'invalid'
parameter :lambdaImage, type: :String, default: "#{accountId}.dkr.ecr.us-east-1.amazonaws.com/zeus/lambda-api:latest"

include_template(
  'app/cloudfront.rb',
  'app/s3.rb',
  'app/lambda.rb'
)
