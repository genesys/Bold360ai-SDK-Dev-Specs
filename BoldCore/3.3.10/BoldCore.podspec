
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '3.3.10'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldCore_version_v3.3.10.rc2_commit_069aed8841f5b45b293289c2c651d21f5fc48cb0.zip"
}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
