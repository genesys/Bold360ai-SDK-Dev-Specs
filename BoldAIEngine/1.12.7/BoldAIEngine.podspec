Pod::Spec.new do |s|
s.name             = 'BoldAIEngine'
s.version = '1.12.7'
s.summary          = 'BoldAIEngine is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
BoldAIEngine is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://genesys.github.io/bold360-mobile-docs-ios/docs/overview'
s.license = 'private'
s.author           = 'BoldAIEngine'
s.source = {
    "http" => "https://genesysdx.jfrog.io/artifactory/bold-ios.dev/BoldAIEngine/BoldAIEngine_version_v1.12.7.rc1_commit_675f7870f744c25eaee7e775962cfc9378cc2517.zip"
}
s.vendored_frameworks = 'BoldAIEngine.framework'
s.requires_arc = true
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.ios.deployment_target  = '9.0'

# Private Pod frameworks
s.dependency 'BoldCore', '3.7.2'

end