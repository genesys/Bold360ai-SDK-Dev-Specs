Pod::Spec.new do |s|
s.name             = 'BoldAIEngine'
s.version = '1.8.4'
s.summary          = 'BoldAIEngine is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
BoldAIEngine is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'BoldAIEngine'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldAIEngine_version_v1.8.4.rc1_commit_a3d6898fb633760f4645885859363e19b189afd0.zip"
}
s.vendored_frameworks = 'BoldAIEngine.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

# Private Pod frameworks
s.dependency 'BoldCore'

end
