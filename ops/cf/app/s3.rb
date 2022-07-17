resource :WebS3, 'AWS::S3::Bucket' do
  BucketEncryption do
    ServerSideEncryptionConfiguration [
      ServerSideEncryptionByDefault: {
        SSEAlgorithm: 'AES256'
      }
    ]
  end
end
