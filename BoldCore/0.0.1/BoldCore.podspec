
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '0.0.1'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://genesys.github.io/bold360-mobile-docs-ios/docs/overview'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://genesysdx.jfrog.io/artifactory/bold-ios.dev/BoldCore/BoldCore_version_v0.0.1.rc19_commit_0ecc4b1fe6f9a65502db5ff401888e6e97155967.zip"
}
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end