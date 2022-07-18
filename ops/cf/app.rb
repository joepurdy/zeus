description 'app stack'

# This config wasn't used because it relies on a custom domain and SSL certificate
# See note in "Going further" section of README about removing custom domain due to lack of SSL certificate automation w/ ACM
#
## DNS domains for route53
# parameter :domain, type: :String, default: 'hjkl.cloud'
# parameter :subdomain, type: :String, default: 'zeus'

include_template(
  'app/cloudfront.rb',
  'app/s3.rb'
)
