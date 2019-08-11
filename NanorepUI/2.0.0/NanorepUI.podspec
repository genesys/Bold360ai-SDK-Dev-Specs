# ===================================================================================================
# Copyright © 2018 bold360ai(LogMeIn).
# NanorepUI SDK.
#ֿ All rights reserved.
# ===================================================================================================

Pod::Spec.new do |s|
  s.name             = 'NanorepUI'
  s.version = '2.0.0'
  s.summary          = 'Nanorep is an SDK that contains two main services: Search & Conversation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Nanorep is an SDK that contains two main services: Search & Conversation.
                       DESC

  s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
  s.license = ''
  s.author           = 'Bold360'

    # scripts
    # s.script_phases = [
    #   { :name => 'extract-version-from-url',
    #   :script => '${PODS_TARGET_SRCROOT}/scripts/extract-version-from-url.sh ' + s.source["http"].to_s,
    #   :execution_position => :after_compile
    #   }
    # ]

s.source = {
"http" => "https://dl.bintray.com/nanorep/Specs-Dev/NanorepUI_version_v2.0.0.rc3_commit_dda57d7adac3fed232f5690e7627715a9b0c79c9.zip"
}

s.ios.deployment_target  = '9.0'

s.subspec 'Core' do |sp|
  sp.vendored_frameworks = 'NanorepUI.framework'
  sp.requires_arc = true

  # Private Pod frameworks
  sp.dependency 'NanorepEngine'
  sp.dependency 'NRAccessibility'
  sp.pod_target_xcconfig = { 'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO' }
end

s.subspec 'Bold' do |ssp|
# TODO:: add boldHandler from external repo
  ssp.dependency 'NanorepUI/Core'
  ssp.dependency 'BoldEngine'
end

s.default_subspec = 'Core'

end
