//
//  Package.swift
//  RxCoreStore
//
//  Copyright © 2017 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import PackageDescription

let targets: [Target]
#if os(iOS)
targets = [Target(name: "RxCoreStore iOS")]
#elseif os(OSX)
targets = [Target(name: "RxCoreStore OSX")]
#elseif os(watchOS)
targets = [Target(name: "RxCoreStore watchOS")]
#elseif os(tvOS)
targets = [Target(name: "RxCoreStore tvOS")]
#else
targets = []
#endif

let package = Package(
    name: "RxCoreStore",
    targets: targets,
    dependencies: [
        .Package(
            url: "https://github.com/JohnEstropia/CoreStore.git",
            "8.0.0"
        ),
        .Package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            "6.1.0"
        )
    ],
    exclude: ["Carthage", "RxCoreStoreDemo", "Sources/libA/images"]
)
