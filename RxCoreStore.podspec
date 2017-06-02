Pod::Spec.new do |s|
    s.name = "RxCoreStore"
    s.version = "0.0.1-alpha4"
    s.license = "MIT"
    s.summary = "RxSwift extensions for CoreStore"
    s.homepage = "https://github.com/JohnEstropia/RxCoreStore"
    s.author = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
    s.source = { :git => "https://github.com/JohnEstropia/RxCoreStore.git", :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"
#s.osx.deployment_target = "10.10"
#s.watchos.deployment_target = "2.0"
#s.tvos.deployment_target = "9.0"

    s.source_files = "Sources", "Sources/**/*.{swift,h,m}"
    s.public_header_files = "Sources/**/*.h"
    s.frameworks = "Foundation", "CoreData"
    s.requires_arc = true
    s.dependency "CoreStore", "~> 4.0"
    s.dependency "RxCocoa", "~> 3.4"
    s.dependency "RxSwift", "~> 3.4"
end
