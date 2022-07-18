resource :APIlambda, 'AWS::Lambda::Function', DependsOn: :iamlambda do
  package_type 'Image'
  code do
    image_uri Fn::ref(:lambdaImage)
  end
  role Fn::get_att(:iamlambda, :Arn)
end

resource :iamlambda, 'AWS::IAM::Role' do
  assume_role_policy_document(
    Version: '2012-10-17',
    Statement: [
      {
        Effect: 'Allow',
        Principal: {
          Service: 'lambda.amazonaws.com'
        },
        Action: 'sts:AssumeRole'
      }
    ]
  )
  managed_policy_arns(
    [
      'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
    ]
  )
end