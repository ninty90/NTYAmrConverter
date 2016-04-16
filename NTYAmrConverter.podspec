Pod::Spec.new do |s|
  s.name         = "NTYAmrConverter"
  s.version      = "0.1.0"
  s.summary      = "Converter between .amr and .wav file"
  s.homepage     = "https://github.com/ninty90/NTYAmrConverter"
  s.license      = "MIT"
  s.author       = { "Yinglun Duan" => "duanyinglun@ninty.cc" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/ninty90/NTYAmrConverter.git", :tag => s.version }
  s.source_files  = "Source/**/*.{h,m}"
  s.vendored_libraries = "Source/**/*.a"
end
