//
//  RxObjectPublisher+DataSources.swift
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

import Foundation
import CoreStore
import RxCocoa
import RxSwift


// MARK: - RxObjectPublisherType

public protocol RxObjectPublisherType {

    associatedtype ObjectType: DynamicObject

    var snapshot: ObjectSnapshot<ObjectType>? { get }

    func addObserver<T: AnyObject>(
        _ observer: T,
        notifyInitial: Bool,
        _ callback: @escaping (ObjectPublisher<ObjectType>) -> Void
    )
    func removeObserver<T: AnyObject>(_ observer: T)
}

extension ObjectPublisher: RxObjectPublisherType {}


// MARK: - Reactive

extension Reactive where Base: RxObjectPublisherType {

    public func snapshotDriver() -> Driver<ObjectSnapshot<Base.ObjectType>?> {

        return Observable<ObjectSnapshot<Base.ObjectType>?>
            .create(
                { observer in

                    let token = NSObject()
                    self.base.addObserver(token, notifyInitial: true) { (objectPublisher) in

                        observer.onNext(objectPublisher.snapshot)
                    }
                    return Disposables.create {

                        DispatchQueue.main.async {

                            self.base.removeObserver(token)
                        }
                    }
                }
            )
            .asDriver(onErrorDriveWith: .never())
    }

    public func snapshotSignal() -> Signal<ObjectSnapshot<Base.ObjectType>?> {

        return Observable<ObjectSnapshot<Base.ObjectType>?>
            .create(
                { observer in

                    let token = NSObject()
                    self.base.addObserver(token, notifyInitial: false) { (objectPublisher) in

                        observer.onNext(objectPublisher.snapshot)
                    }
                    return Disposables.create {

                        DispatchQueue.main.async {

                            self.base.removeObserver(token)
                        }
                    }
                }
            )
            .asSignal(onErrorSignalWith: .never())
    }
}
