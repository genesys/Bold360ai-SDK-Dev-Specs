# Copyright © 2018 bold360ai(LogMeIn).
# BoldEngine SDK.
#ֿ All rights reserved.
# ===================================================================================================

Pod::Spec.new do |s|
  s.name             = 'BoldEngine'
  s.version = '1.0.x-dev'
  s.summary          = 'BoldEngine is an SDK that contains bold chat handler.'
  s.description      = <<-DESC
    BoldEngine is an SDK that contains bold chat handler.
                       DESC

  s.homepage         = 'https://github.com/nanorepsdk/NanorepUI/wiki'
  s.license = ''
  s.author           = 'Bold360'
  s.requires_arc = true
  s.ios.deployment_target  = '8.0'
  
  s.source           = { :git => "https://bitbucket.3amlabs.net/scm/bold/mobile-bold-engine-ios.git", :tag => s.version.to_s }
  s.public_header_files = 'BoldEngine/**/*.h'
  s.source_files = ['BoldEngine/**/*.{h,m}']
  s.exclude_files = ['BoldEngine/Info.plist']
  s.libraries = ['icucore']
  s.pod_target_xcconfig     = { 
    'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO',
    'OTHER_LDFLAGS' => '$(inherited)',
    'GCC_PREPROCESSOR_DEFINITIONS ' => '$(inherited)',
    'HEADER_SEARCH_PATHS ' => '$(inherited)'
    }

end