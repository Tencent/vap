Pod::Spec.new do |s|
  s.name             = 'TCMediaX'
  s.version          = '3.5.29004'
  s.summary          = 'TCMediaX base SDK (local xcframework).'
  s.homepage         = 'https://cloud.tencent.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Tencent' => 'tencent@tencent.com' }
  s.platform         = :ios, '12.0'

  # 通过 Podfile 的 :path 定位到当前目录；vendored_frameworks 相对于该目录
  s.source           = { :path => '.' }
  s.vendored_frameworks = 'TCMediaX.xcframework'

  s.ios.frameworks   = ['Security']
  s.ios.libraries    = ['c++']

  s.requires_arc     = true
end
