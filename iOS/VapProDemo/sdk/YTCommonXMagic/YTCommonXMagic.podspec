Pod::Spec.new do |s|
  s.name             = 'YTCommonXMagic'
  s.version          = '1.4'
  s.summary          = 'YTCommonXMagic auth SDK (local xcframework).'
  s.homepage         = 'https://cloud.tencent.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Tencent' => 'tencent@tencent.com' }
  s.platform         = :ios, '12.0'

  s.source           = { :path => '.' }
  s.vendored_frameworks = 'YTCommonXMagic.xcframework'

  s.requires_arc     = true
end
