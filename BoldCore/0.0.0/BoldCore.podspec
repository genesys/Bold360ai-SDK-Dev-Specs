
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '0.0.0'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://genesys.github.io/bold360-mobile-docs-ios/docs/overview'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://bold360ai-mobile-artifacts.s3.amazonaws.com/ios/dev/BoldCore/BoldCore_version_v0.0.0.rc2_commit_75b120f4f36f9f8843a3043868cd670271753dd4.zip"
}
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end