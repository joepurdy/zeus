description 'app stack'

## DNS domains for route53
parameter :domain, type: :String, default: 'hjkl.cloud'
parameter :subdomain, type: :String, default: 'zeus'

include_template(
  'app/cloudfront.rb',
  'app/s3.rb'
)
