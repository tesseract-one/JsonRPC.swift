Pod::Spec.new do |s|
  s.name             = 'JsonRPC.swift'
  s.version          = '0.0.1'
  s.summary          = 'Cross-plaform Json RPC library for Swift with WebSocket support'

  s.description      = <<-DESC
  Cross-plaform Json RPC library for Swift with WebSocket support. Supports all Apple platforms and Linux.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/JsonRPC.swift'

  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/JsonRPC.swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '6.0'
  
  s.swift_version = '5.4'

  s.module_name = 'JsonRPC'
  
  s.dependency 'TesseractWebSocket', '~> 0.2.0'

  s.source_files = 'Sources/**/*.swift'
 
  s.test_spec 'Tests' do |test_spec|
    test_spec.platforms = {:ios => '10.0', :osx => '10.12', :tvos => '10.0'}
    test_spec.source_files = 'Tests/JsonRPCTests/*.swift'
    test_spec.dependency 'Serializable.swift', '~> 0.2.3'
  end
end
