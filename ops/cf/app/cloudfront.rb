resource :CloudfrontDistribution, 'AWS::CloudFront::Distribution', DependsOn: [:CloudfrontOAI, :ResponseHeadersPolicy, :WebS3] do
  DistributionConfig do
    # This config wasn't used because it relies on a custom domain and SSL certificate
    # See note in "Going further" section of README about removing custom domain due to lack of SSL certificate automation w/ ACM
    # Aliases [
    #   Fn::sub('${domain}')
    # ]
    DefaultCacheBehavior do
      Compress true
      DefaultTTL 86400
      ForwardedValues do
        QueryString true
      end
      MaxTTL 31536000
      TargetOriginId Fn::get_att(:WebS3, :Arn)
      ResponseHeadersPolicyId Fn::ref(:ResponseHeadersPolicy)
      ViewerProtocolPolicy 'allow-all'
    end
    CustomErrorResponses [
      {
        ErrorCachingMinTTL: 60,
        ErrorCode: 404,
        ResponseCode: 404,
        ResponsePagePath: '/404.html'
      },
      {
        ErrorCachingMinTTL: 60,
        ErrorCode: 403,
        ResponseCode: 403,
        ResponsePagePath: '/403.html'
      }
    ]
    Enabled true
    HttpVersion 'http2'
    DefaultRootObject 'index.html'
    IPV6Enabled true
    Origins [
      {
        DomainName: Fn::get_att(:WebS3, :DomainName),
        Id: Fn::get_att(:WebS3, :Arn),
        S3OriginConfig: {
          OriginAccessIdentity: Fn::Sub('origin-access-identity/cloudfront/${CloudfrontOAI}')
        }
      }
    ]
    PriceClass 'PriceClass_All'
  end
end

resource :CloudfrontOAI, 'AWS::CloudFront::CloudFrontOriginAccessIdentity' do
  CloudFrontOriginAccessIdentityConfig do
    Comment Fn::sub('CloudFront OAI for ${domain}')
  end
end

# This config wasn't used because it relies on a custom domain and SSL certificate
# See note in "Going further" section of README about removing custom domain due to lack of SSL certificate automation w/ ACM
# resource :Route53HostedZone, 'AWS::Route53::HostedZone' do
#   Name Fn::sub('${domain}.')
# end

# resource :Route53RecordSetGroup, 'AWS::Route53::RecordSetGroup', DependsOn: [:Route53HostedZone] do
#   HostedZoneName Fn::sub('${domain}.')
#   RecordSets [
#     {
#       Name: Fn::ref(:domain),
#       Type: 'A',
#       AliasTarget: {
#         DNSName: Fn::sub('${subdomain}.${domain}'),
#         EvaluateTargetHealth: false,
#         HostedZoneId: 'Z2FDTNDATAQYW2'
#       }
#     }
#   ]
# end

resource :ResponseHeadersPolicy, 'AWS::CloudFront::ResponseHeadersPolicy' do
  ResponseHeadersPolicyConfig do
    Name Fn::sub("${AWS::StackName}-static-site-security-headers")
    SecurityHeadersConfig do
      StrictTransportSecurity do
        AccessControlMaxAgeSec 63072000
        IncludeSubdomains true
        Override true
        Preload true
      end
      ContentSecurityPolicy do
        ContentSecurityPolicy "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
        Override true
      end
      ContentTypeOptions do
        Override true
      end
      FrameOptions do
        FrameOption 'DENY'
        Override true
      end
      ReferrerPolicy do
        ReferrerPolicy 'same-origin'
        Override true
      end
      XSSProtection do
        ModeBlock true
        Override true
        Protection true
      end
    end
  end
end
