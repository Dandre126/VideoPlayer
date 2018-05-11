Pod::Spec.new do |s|

s.name             = 'VideoPlayer'
s.version          = '0.1.0'
s.summary          = 'Wraps AVPlayer.'

s.homepage         = 'https://github.com/Nominalista/VideoPlayer'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Nominalista' => 'the.nominalista@gmail.com' }
s.source           = { :git => 'https://github.com/Nominalista/VideoPlayer.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'
s.source_files = 'VideoPlayer/*'
s.dependency "RxSwift",  '~> 4.1.2'
s.dependency "RxCocoa",  '~> 4.1.2'

end