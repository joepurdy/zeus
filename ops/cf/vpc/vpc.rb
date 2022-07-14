resource :vpc, 'AWS::EC2::VPC' do
  cidr_block '10.0.0.0/16'
  enable_dns_support true
  enable_dns_hostnames true
  instance_tenancy :default
  tag :Name, Fn::ref('AWS::StackName')
end

## allow internet access for instances in vpc
resource :igw, 'AWS::EC2::InternetGateway' do
  tag :Name, Fn::ref('AWS::StackName')
end

## attach gateway to vpc
resource :igwattach, 'AWS::EC2::VPCGatewayAttachment', DependsOn: [:vpc, :igw] do
  vpc_id Fn::ref(:vpc)
  internet_gateway_id Fn::ref(:igw)
end

## routing table for vpc
resource :routetable, 'AWS::EC2::RouteTable', DependsOn: [:vpc] do
  vpc_id Fn::ref(:vpc)
  tag :Name, Fn::ref('AWS::StackName')
end

## default route for outgoing packets
resource :route, 'AWS::EC2::Route', DependsOn: [:routetable, :igw] do
  route_table_id Fn::ref(:routetable)
  gateway_id Fn::ref(:igw)
  destination_cidr_block '0.0.0.0/0'
end

output :VpcId, Fn::ref(:vpc), export: Fn::sub('${AWS::StackName}-VpcId')