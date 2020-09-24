Pod::Spec.new do |s|
    s.name = "RxCoreStore"
    s.version = "2.2.0"
    s.license = "MIT"
    s.summary = "RxSwift extensions for CoreStore"
    s.homepage = "https://github.com/JohnEstropia/RxCoreStore"
    s.author = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
    s.source = { :git => "https://github.com/JohnEstropia/RxCoreStore.git", :tag => s.version.to_s }

    s.ios.deployment_target = "10.0"
    s.swift_versions = "5.3"

    s.source_files = "Sources", "Sources/**/*.{swift,h,m}"
    s.public_header_files = "Sources/**/*.h"
    s.frameworks = "Foundation", "CoreData"
    s.requires_arc = true
    s.dependency "CoreStore", ">=7.3.0"
    s.dependency "RxCocoa", ">=5.1.1"
    s.dependency "RxSwift", ">=5.1.1"
end
