resource :DynAccounts, 'AWS::DynamoDB::GlobalTable' do
  attribute_definitions [
    { AttributeName: :id, AttributeType: :S },
    { AttributeName: :email, AttributeType: :S },
  ]
  key_schema [
    { AttributeName: :id, KeyType: :HASH },
    { AttributeName: :email, KeyType: :RANGE },
  ]
  replicas [
    {
      Region: 'us-east-1',
      ReadProvisionedThroughputSettings: {
        ReadCapacityAutoScalingSettings: {
          MaxCapacity: 5,
          MinCapacity: 1,
          TargetTrackingScalingPolicyConfiguration: {
            TargetValue: 70.0
          }
        }
      },
      Tags: [
        {
          Key: 'Stack',
          Value: Fn::ref('AWS::StackName')
        }
      ]
    }
  ]
  SSE_specification do
    SSEEnabled true
  end
  WriteProvisionedThroughputSettings do
    WriteCapacityAutoScalingSettings do
      MaxCapacity 5
      MinCapacity 1
      TargetTrackingScalingPolicyConfiguration do
        TargetValue 70.0
      end
    end
  end
end

output :DynAccounts,    Fn::ref(:DynAccounts),           export: Fn::sub('${AWS::StackName}-DynAccounts')
output :DynAccountsArn, Fn::get_att(:DynAccounts, :Arn), export: Fn::sub('${AWS::StackName}-DynAccountsArn')