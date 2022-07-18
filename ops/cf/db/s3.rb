resource :StatementS3, 'AWS::S3::Bucket' do
  BucketEncryption do
    ServerSideEncryptionConfiguration [
      ServerSideEncryptionByDefault: {
        SSEAlgorithm: 'AES256'
      }
    ]
  end
end

output :StatementS3,    Fn::ref(:StatementS3),           export: Fn::sub('${AWS::StackName}-StatementS3')
output :StatementS3Arn, Fn::get_att(:StatementS3, :Arn), export: Fn::sub('${AWS::StackName}-StatementS3Arn')