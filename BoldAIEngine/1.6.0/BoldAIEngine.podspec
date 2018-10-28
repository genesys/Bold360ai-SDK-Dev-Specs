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
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldAIEngine_version_v1.6.0.rc2_commit_a71f55d5f972b39e47ae5e38e64a3f15f4ad4f0a.zip"
}
s.vendored_frameworks = 'BoldAIEngine.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
