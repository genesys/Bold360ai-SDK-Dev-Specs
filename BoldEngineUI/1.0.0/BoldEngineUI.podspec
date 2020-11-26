# ===================================================================================================
# Copyright © 2020 bold360(LogMeIn).
# BoldEngineUI SDK.
#ֿ All rights reserved.
# ===================================================================================================

Pod::Spec.new do |s|
  s.name             = 'BoldEngineUI'
  s.version = '1.0.0'
  s.summary          = 'BoldEngineUI is an SDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  BoldEngineUI is an SDK.
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
"http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldEngineUI_version_v1.0.0.rc1_commit_038fe30959c8896ae1a49f70783abde9b14e2585.zip"
}

s.ios.deployment_target  = '10.0'

s.subspec 'Core' do |sp|
  sp.vendored_frameworks = 'BoldEngineUI.framework'
  sp.requires_arc = true

  # Private Pod frameworks
  sp.dependency 'BoldEngine'
  sp.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO'}
  sp.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
end

s.default_subspec = 'Core'

end
