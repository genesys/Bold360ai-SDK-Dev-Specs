# Copyright © 2018 bold360ai(LogMeIn).
# BoldEngine SDK.
#ֿ All rights reserved.
# ===================================================================================================

Pod::Spec.new do |s|
  s.name             = 'BoldEngine'
  s.version = '2.3.1'
  s.summary          = 'BoldEngine is an SDK that used as chat handler on bold ai.'

  s.description      = <<-DESC
    BoldEngine is an SDK that used as chat handler on bold ai.
                       DESC

  s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
  s.license          = ''
  s.author           = 'Bold360'


    # scripts
    # s.script_phases = [
    #   { :name => 'extract-version-from-url',
    #   :script => '${PODS_TARGET_SRCROOT}/scripts/extract-version-from-url.sh ' + s.source["http"].to_s,
    #   :execution_position => :after_compile
    #   }
    # ]

s.source = {
"http" => "https://dl.bintray.com/nanorep/Specs-Dev/BoldEngine_version_v2.3.1.rc1_commit_47b6f08b26e5ad2aa1e97b4214bd21bf2cead5c1.zip"
}
  
s.vendored_frameworks = 'BoldEngine.framework'
s.requires_arc = true
s.ios.deployment_target  = '9.0'
s.pod_target_xcconfig = { 'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO' }
s.libraries = ['icucore']

end
