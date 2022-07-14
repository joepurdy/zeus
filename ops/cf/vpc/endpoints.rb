resource :vpcedyn, 'AWS::EC2::VPCEndpoint', DependsOn: [:vpc, :routetable] do
  vpc_id Fn::ref(:vpc)
  route_table_ids [Fn::ref(:routetable)]
  service_name Fn::sub('com.amazonaws.${AWS::Region}.dynamodb')
end

resource :vpces3, 'AWS::EC2::VPCEndpoint', DependsOn: [:vpc, :routetable] do
  vpc_id Fn::ref(:vpc)
  route_table_ids [Fn::ref(:routetable)]
  service_name Fn::sub('com.amazonaws.${AWS::Region}.s3')
end