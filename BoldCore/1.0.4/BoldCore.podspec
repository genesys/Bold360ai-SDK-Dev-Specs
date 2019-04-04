
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '1.0.4'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldCore_version_v1.0.4.rc44_commit_d93b89d8f499d6fb0e1e8a00381649907a854d35.zip"
}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
