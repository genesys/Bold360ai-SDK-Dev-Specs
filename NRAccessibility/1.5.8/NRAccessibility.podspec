Pod::Spec.new do |s|
s.name             = 'NRAccessibility'
s.version = '1.5.8'
s.summary          = 'Nanorep is an SDK that contains two main services: Search & Conversation.'

s.description      = <<-DESC
Nanorep is an SDK that contains two main services: Search & Conversation.
DESC

s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
s.license = 'private'
s.author           = 'nanorep'
s.source = {
    "http" => "https://dl.bintray.com/nanorep/Specs-Dev/NRAccessibility_version_v1.5.8.rc1_commit_de771e7a906e270e32413bc98a1c9fe5b6aec57b.zip"
}
s.vendored_frameworks = 'NRAccessibility.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'

end
