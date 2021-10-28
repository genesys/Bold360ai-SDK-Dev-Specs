
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
    "http" => "https://bold360ai-mobile-artifacts.s3.amazonaws.com/ios/dev/BoldCore/BoldCore_version_v0.0.1.rc6_commit_9d09e7c0355b093c295a3d54678dead0efb58088.zip"
}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end