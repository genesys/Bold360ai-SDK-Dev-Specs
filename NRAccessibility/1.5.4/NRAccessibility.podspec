Pod::Spec.new do |s|
s.name             = 'NRAccessibility'
s.version = '1.5.4'
s.summary          = 'Nanorep is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
Nanorep is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'nanorep'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/NRAccessibility_version_v1.5.4.rc1_commit_f6c04e65b55947f7b7481d1a717d4f21b52ef596.zip"
}
s.vendored_frameworks = 'NRAccessibility.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
