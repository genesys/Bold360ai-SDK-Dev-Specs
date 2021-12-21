
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '0.0.1'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://genesysdx.jfrog.io/artifactory/bold-ios.dev/BoldCore/BoldCore_version_v0.0.1.rc13_commit_87ddb3a3090f8003d8b4551e74b82d9157d16104.zip"
}
s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '10.0'

end