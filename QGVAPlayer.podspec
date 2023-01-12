#
#  Be sure to run `pod spec lint QGRouter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "QGVAPlayer"
  spec.version      = "1.0.19"
  spec.summary      = "video animation player."
  spec.platform     = :ios, "8.0"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = "video animation player - 高效的特效动画播放组件."

  spec.homepage     = "https://github.com/Tencent/vap"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  #spec.license      = {
        #:type => 'Copyright',
        #:text => <<-LICENSE
              #© 1998-2019 Tencent. All rights reserved.
        #LICENSE
    #}
  #spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.license       = 'MIT'

# 集成源码
    puts "Pod Install #{spec.name} Source"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "tencent" => "tencent@gmail.com" }
  # Or just: spec.author    = "tencent"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/Tencent/vap.git", :tag => "iOS#{spec.version}"}


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files = 'iOS/QGVAPlayer/QGVAPlayer/**/*.{h,m}', 'iOS/QGVAPlayer/QGVAPlayer/Shaders/QGHWDShaders.metal'

  # spec.subspec 'Shaders' do |ss|
  #   ss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Shaders/**/*.{h,m}'
  # end

  # spec.subspec 'Classes' do |ss|
  #   ss.source_files  = 'iOS/QGVAPlayer/QGVAPlayer/Classes/*.{h,m}'
  #     ss.subspec 'Models' do |sss|
  #       sss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Classes/Models/**/*.{h,m}'
  #     end
  #     ss.subspec 'Views' do |sss|
  #       sss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Classes/Views/**/*.{h,m}'
  #     end
  #     ss.subspec 'Controllers' do |sss|
  #       sss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Classes/Controllers/**/*.{h,m}'
  #     end
  #     ss.subspec 'MP4Parser' do |sss|
  #       sss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Classes/MP4Parser/**/*.{h,m}'
  #     end
  #     ss.subspec 'Utils' do |sss|
  #       sss.source_files = 'iOS/QGVAPlayer/QGVAPlayer/Classes/Utils/**/*.{h,m}'
  #     end
  # end



  # spec.exclude_files = "Classes/Exclude"

  #spec.public_header_files = "iOS/QGVAPlayer/QGVAPlayer/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  spec.frameworks = "Metal", "MetalKit"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
  #spec.user_target_xcconfig  = { 'OTHER_LDFLAGS' => "-force_load ${BUILT_PRODUCTS_DIR}/#{spec.name}/lib#{spec.name}.a" }

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
