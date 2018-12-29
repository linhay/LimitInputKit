
Pod::Spec.new do |s|
  s.name             = 'LimitInputKit'
  s.version          = '0.0.5'
  s.summary          = 'iOS - 输入内容控制控件'
  
  s.homepage = 'https://github.com/linhay/LimitInputKit'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = { 'linhay' => 'is.linhay@outlook.com' }
  s.source   = { :git => 'https://github.com/linhay/LimitInputKit.git', :tag => s.version.to_s }
  
  s.swift_version = '4.2'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files = 'Sources/*/**'
end


