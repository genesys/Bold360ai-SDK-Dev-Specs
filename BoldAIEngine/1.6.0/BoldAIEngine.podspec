Pod::Spec.new do |s|
s.name             = 'BoldAIEngine'
s.version = '1.6.0'
s.summary          = 'BoldAIEngine is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
BoldAIEngine is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldAIEngine'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldAIEngine_version_v1.6.0.rc4_commit_c9d0b3176ddbe8f417bd490778dbb0684305d9a7.zip"
}
s.vendored_frameworks = 'BoldAIEngine.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
