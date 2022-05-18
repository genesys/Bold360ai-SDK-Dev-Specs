Pod::Spec.new do |s|
s.name             = 'BoldAIEngine'
s.version = '0.0.0'
s.summary          = 'BoldAIEngine is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
BoldAIEngine is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://genesys.github.io/bold360-mobile-docs-ios/docs/overview'
s.license = 'private'
s.author           = 'BoldAIEngine'
s.source = {
    "http" => "https://bold360ai-mobile-artifacts.s3.amazonaws.com/ios/dev/BoldAIEngine/BoldAIEngine_version_v0.0.0.rc1_commit_4092d9417074e14e2c28649a261356f1a57f28dd.zip"
}
s.vendored_frameworks = 'BoldAIEngine.framework'
s.requires_arc = true
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.ios.deployment_target  = '9.0'

# Private Pod frameworks
s.dependency 'BoldCore', '0.0.0'

end