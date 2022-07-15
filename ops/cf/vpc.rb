description 'vpc stack'

include_template(
  'vpc/vpc.rb',
  'vpc/subnets.rb',
  'vpc/endpoints.rb'
)
