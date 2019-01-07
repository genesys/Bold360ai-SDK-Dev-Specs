Pod::Spec.new do |s|
s.name             = 'BoldCore'
s.version = '1.0.0'
s.summary          = 'BoldCore is an SDK.'

s.description      = <<-DESC
BoldCore is an SDK.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'bold360ai'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldCore_version_v1.0.0.rc1_commit_a4db485cbb2a3eeba8c143596feb8ef99547eba6.zip"
}
s.vendored_frameworks = 'BoldCore.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
