Pod::Spec.new do |s|
s.name             = 'NanorepEngine'
s.version = '1.5.10'
s.summary          = 'Nanorep is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
Nanorep is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'nanorep'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/NanorepEngine_version_v1.5.10.rc1_commit_8bbc87848ed567e946f8bf65cd6579f75c347543.zip"
}
s.vendored_frameworks = 'NanorepEngine.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
