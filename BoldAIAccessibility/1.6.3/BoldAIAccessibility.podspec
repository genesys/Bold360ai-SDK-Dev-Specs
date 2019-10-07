Pod::Spec.new do |s|
s.name             = 'BoldAIAccessibility'
s.version = '1.6.3'
s.summary          = 'BoldAIAccessibility is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
Nanorep is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'bold360ai'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldAIAccessibility_version_v1.6.3.rc3_commit_99959f371ba66c9edddba17f4ce95da817585f62.zip"
}
s.vendored_frameworks = 'BoldAIAccessibility.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
