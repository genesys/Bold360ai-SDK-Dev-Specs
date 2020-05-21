
Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '3.4.0'
s.summary          = 'BoldCore.'

s.description      = <<-DESC
BoldCore
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldCore'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldCore_version_v3.4.0.rc1_commit_b3ed0880bb6a8c762513fc37847101ec2fb78053.zip"
}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
