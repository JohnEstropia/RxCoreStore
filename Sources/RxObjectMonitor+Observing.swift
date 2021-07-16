//
//  RxObjectMonitor+Observing.swift
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


// MARK: - RxObjectMonitorType

public protocol RxObjectMonitorType {
    
    associatedtype ObjectType: DynamicObject
}

extension ObjectMonitor: RxObjectMonitorType {}


// MARK: - ObjectMonitor

extension ObjectMonitor: ObservableConvertibleType {
    
    // MARK: ObservableConvertibleType
    
    public typealias E = RxObjectChange<O>
    
    public func asObservable() -> Observable<RxObjectChange<O>> {
        
        return Observable<RxObjectChange<O>>
            .create(
                { (observable) in
                    
                    let observer = RxAnonymousObjectObserver(observable)
                    self.addObserver(observer)
                    return Disposables.create {

                        DispatchQueue.main.async {

                            self.removeObserver(observer)
                        }
                    }
                }
        )
    }
}


// MARK: - RxObjectChangeType

public protocol RxObjectChangeType {
    
    associatedtype ObjectType: DynamicObject
    
    var monitor: ObjectMonitor<ObjectType> { get }
    var changeType: RxObjectChange<ObjectType>.ChangeType { get }
}


// MARK: - RxAnyObjectChange

public protocol RxAnyObjectChange {}


// MARK: - RxObjectChange

public struct RxObjectChange<D: DynamicObject>: RxObjectChangeType {
    
    // MARK: - ChangeType
    
    public enum ChangeType {
        
        case objectWillUpdate(object: D)
        case objectDidUpdate(object: D, changedPersistentKeys: Set<KeyPathString>)
        case objectDeleted
    }
    
    
    // MARK: -
    
    public let monitor: ObjectMonitor<D>
    public let changeType: ChangeType
    
    public var tuple: (monitor: ObjectMonitor<D>, changeType: ChangeType) {
        
        return (self.monitor, self.changeType)
    }
    
    
    // MARK: RxObjectChangeType
    
    public typealias ObjectType = D
    
    
    // MARK: FilePrivate
    
    fileprivate init(_ monitor: ObjectMonitor<D>, _ changeType: ChangeType) {
        
        self.monitor = monitor
        self.changeType = changeType
    }
}


// MARK: - SharedSequence where SharingStrategy == SignalSharingStrategy, Element: RxObjectChangeType

extension SharedSequence where SharingStrategy == SignalSharingStrategy, Element: RxObjectChangeType {
    
    public typealias ObjectMonitorType = ObjectMonitor<Element.ObjectType>
    public typealias ObjectChangeType = RxObjectChange<Element.ObjectType>.ChangeType
    
    public func filterObjectWillUpdate() -> Signal<Element.ObjectType> {
        
        return self.flatMap { (objectChange) -> Signal<Element.ObjectType> in
            
            if case .objectWillUpdate(let object) = objectChange.changeType {
                
                return .just(object)
            }
            return .never()
        }
    }
    
    public func filterObjectDidUpdate() -> Signal<(object: Element.ObjectType, changedPersistentKeys: Set<KeyPathString>)> {
        
        return self.flatMap { (objectChange) -> Signal<(object: Element.ObjectType, changedPersistentKeys: Set<KeyPathString>)> in
            
            if case .objectDidUpdate(let object, let changedPersistentKeys) = objectChange.changeType {
                
                return .just((object, changedPersistentKeys))
            }
            return .never()
        }
    }
    
    public func filterObjectDeleted() -> Signal<Void> {
        
        return self.flatMap { (objectChange) -> Signal<Void> in
            
            if case .objectDeleted = objectChange.changeType {
                
                return .just(())
            }
            return .never()
        }
    }
}


// MARK: - RxAnonymousObjectObserver

internal final class RxAnonymousObjectObserver<D: DynamicObject>: ObjectObserver {
    
    internal typealias ObjectChangeType = RxObjectChange<D>
    
    internal init(_ observable: AnyObserver<ObjectChangeType>) {
        
        self.observable = observable
    }
    
    
    // MARK: ListObserver
    
    internal typealias ObjectEntityType = D
    
    internal func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, willUpdateObject object: ObjectEntityType) {
        
        self.observable.onNext(
            ObjectChangeType(monitor, ObjectChangeType.ChangeType.objectWillUpdate(object: object))
        )
    }
    
    internal func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didUpdateObject object: ObjectEntityType, changedPersistentKeys: Set<KeyPathString>) {
        
        self.observable.onNext(
            ObjectChangeType(
                monitor,
                ObjectChangeType.ChangeType.objectDidUpdate(
                    object: object,
                    changedPersistentKeys: changedPersistentKeys
                )
            )
        )
    }
    
    internal func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didDeleteObject object: ObjectEntityType) {
        
        self.observable.onNext(
            ObjectChangeType(monitor, ObjectChangeType.ChangeType.objectDeleted)
        )
    }
    
    
    // MARK: Private
    
    fileprivate let observable: AnyObserver<ObjectChangeType>
}
