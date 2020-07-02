Pod::Spec.new do |s|
s.name             = 'BoldAIAccessibility'
s.version = '1.7.0'
s.summary          = 'BoldAIAccessibility is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
Nanorep is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'bold360ai'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldAIAccessibility_version_v1.7.0.rc3_commit_7c3b1c9533b45fbf7b06714f37893c8f9c4fb476.zip"
}
s.vendored_frameworks = 'BoldAIAccessibility.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
