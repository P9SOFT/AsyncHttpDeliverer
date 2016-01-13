Pod::Spec.new do |s|

  s.name         = "HJAsyncHttpDeliverer"
  s.version      = "1.0.0"
  s.summary      = "Asynchronous HTTP communication module based on Hydra framework."
  s.homepage     = "https://github.com/P9SOFT/HJAsyncHttpDeliverer"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/P9SOFT/HJAsyncHttpDeliverer.git", :tag => "1.0.0" }
  s.source_files  = "HJAsyncHttpDeliverer/Sources/*.{h,m}"
  s.public_header_files = "HJAsyncHttpDeliverer/Sources/*.h"

  s.dependency 'Hydra'

end