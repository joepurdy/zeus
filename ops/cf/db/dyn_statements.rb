resource :DynStatements, 'AWS::DynamoDB::Table' do
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
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5,
      }
    }
  ]
  provisioned_throughput do
    read_capacity_units 5
    write_capacity_units 5
  end
  SSE_specification(
    SSEEnabled: true
  )
  tag :Stack, Fn::ref('AWS::StackName')
end

output :DynStatements,    Fn::ref(:DynStatements),           export: Fn::sub('${AWS::StackName}-DynStatements')
output :DynStatementsArn, Fn::get_att(:DynStatements, :Arn), export: Fn::sub('${AWS::StackName}-DynStatementsArn')