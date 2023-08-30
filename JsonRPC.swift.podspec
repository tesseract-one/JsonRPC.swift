Pod::Spec.new do |s|
  s.name             = 'JsonRPC.swift'
  s.version          = '999.99.9'
  s.summary          = 'Cross-plaform Json RPC library for Swift with WebSocket support'

  s.description      = <<-DESC
  Cross-plaform Json RPC library for Swift with WebSocket support. Supports all Apple platforms and Linux.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/JsonRPC.swift'

  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/JsonRPC.swift.git', :tag => s.version.to_s }

  s.swift_version    = '5.4'
  s.module_name      = 'JsonRPC'

  base_platforms     = { :ios => '13.0', :osx => '10.15', :tvos => '13.0' }
  s.platforms        = base_platforms.merge({ :watchos => '6.0' })
  
  s.source_files     = 'Sources/JsonRPC/**/*.swift'
  
  s.dependency 'ContextCodable.swift', '~> 0.1.0'
  s.dependency 'Tuples', '~> 0.1.0'
  
  s.test_spec 'Tests' do |ts|
    ts.platforms = base_platforms
    ts.source_files = 'Tests/JsonRPCTests/*.swift'
    ts.dependency 'Serializable.swift', '~> 0.3.1'
  end
end
