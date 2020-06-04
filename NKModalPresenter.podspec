Pod::Spec.new do |s|
  s.name             = 'NKModalPresenter'
  s.version          = '1.5.1'
  s.summary          = 'Present UIViewController modally'
  s.description      = <<-DESC
Present UIViewController modally easily and beautifully with animation.
                       DESC

  s.homepage         = 'https://github.com/kennic/NKModalPresenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nam Kennic' => 'namkennic@me.com' }
  s.source           = { :git => 'https://github.com/kennic/NKModalPresenter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/namkennic'
  s.platform          = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.source_files = 'NKModalPresenter/*.swift'
  
end
