resource :DynStatements, 'AWS::DynamoDB::GlobalTable' do
  attribute_definitions [
    { AttributeName: :id, AttributeType: :S },
    { AttributeName: :accountId, AttributeType: :S },
    { AttributeName: :blobKey, AttributeType: :S },
  ]
  key_schema [
    { AttributeName: :id, KeyType: :HASH },
    { AttributeName: :accountId, KeyType: :RANGE },
  ]
  global_secondary_indexes [
    {
      IndexName: :by_blobKey,
      KeySchema: [
        { AttributeName: :blobKey, KeyType: :HASH }
      ],
      Projection: {
        ProjectionType: :KEYS_ONLY,
      },
      WriteProvisionedThroughputSettings: {
        WriteCapacityAutoScalingSettings: {
          MaxCapacity: 5,
          MinCapacity: 1,
          TargetTrackingScalingPolicyConfiguration: {
            TargetValue: 70.0
          }
        }
      }
    }
  ]
  replicas [
    {
      Region: 'us-east-1',
      GlobalSecondaryIndexes: [
        {
          IndexName: :by_blobKey,
          ReadProvisionedThroughputSettings: {
            ReadCapacityAutoScalingSettings: {
              MaxCapacity: 5,
              MinCapacity: 1,
              TargetTrackingScalingPolicyConfiguration: {
                TargetValue: 70.0
              }
            }
          }
        }
      ],
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

output :DynStatements,    Fn::ref(:DynStatements),           export: Fn::sub('${AWS::StackName}-DynStatements')
output :DynStatementsArn, Fn::get_att(:DynStatements, :Arn), export: Fn::sub('${AWS::StackName}-DynStatementsArn')