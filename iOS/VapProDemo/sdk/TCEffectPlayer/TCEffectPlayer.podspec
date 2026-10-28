Pod::Spec.new do |s|
  s.name             = 'TCEffectPlayer'
  s.version          = '3.5.29004'
  s.summary          = 'TCEffectPlayer VAP Pro SDK (local xcframework).'
  s.homepage         = 'https://cloud.tencent.com'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Tencent' => 'tencent@tencent.com' }
  s.platform         = :ios, '12.0'

  s.source           = { :path => '.' }
  s.vendored_frameworks = 'TCEffectPlayer.xcframework'

  s.dependency 'TCMediaX'

  s.requires_arc     = true
end
