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

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  
  s.swift_versions = ['5']

  s.module_name = 'JsonRPC'
  
  s.dependency 'WebSocket.swift', '~> 0.1.0'

  s.source_files = 'Sources/*.swift'
 
  s.test_spec 'Tests' do |test_spec|
    test_spec.platforms = {:ios => '9.0', :osx => '10.10', :tvos => '9.0'}
    test_spec.source_files = 'Tests/JsonRPCTests/*.swift'
    test_scpec.dependency 'Serializable.swift', '~> 0.2.3'
  end
end
