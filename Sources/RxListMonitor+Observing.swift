//
//  RxListMonitor+Observing.swift
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
import CoreData
import CoreStore
import RxCocoa
import RxSwift


// MARK: - RxListMonitorType

public protocol RxListMonitorType {

    associatedtype ObjectType: DynamicObject
}

extension ListMonitor: RxListMonitorType {}


// MARK: - ListMonitor

extension ListMonitor: ObservableConvertibleType {
    
    // MARK: ObservableConvertibleType
    
    public typealias E = RxListChange<O>
    
    public func asObservable() -> Observable<RxListChange<O>> {
        
        return Observable<RxListChange<O>>
            .create(
                { (observable) in
                    
                    let observer = RxAnonymousObserver(observable)
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


// MARK: - RxListChangeType

public protocol RxListChangeType {
    
    associatedtype ObjectType: DynamicObject
    
    var monitor: ListMonitor<ObjectType> { get }
    var changeType: RxListChange<ObjectType>.ChangeType { get }
}


// MARK: - RxAnyListChange

public protocol RxAnyListChange {}


// MARK: - RxListChange

public struct RxListChange<D: DynamicObject>: RxListChangeType {
    
    // MARK: - ChangeType
    
    public enum ChangeType {
        
        case listWillChange
        case listDidChange
        case listWillRefetch
        case listDidRefetch
        
        case objectInserted(object: D, toIndexPath: IndexPath)
        case objectDeleted(object: D, fromIndexPath: IndexPath)
        case objectUpdated(object: D, atIndexPath: IndexPath)
        case objectMoved(object: D, fromIndexPath: IndexPath, toIndexPath: IndexPath)
        
        case sectionInserted(section: NSFetchedResultsSectionInfo, toSectionIndex: Int)
        case sectionDeleted(section: NSFetchedResultsSectionInfo, fromSectionIndex: Int)
    }
    
    
    // MARK: - 
    
    public let monitor: ListMonitor<D>
    public let changeType: ChangeType
    
    public var tuple: (monitor: ListMonitor<D>, changeType: ChangeType) {
        
        return (self.monitor, self.changeType)
    }
    
    
    // MARK: RxListChangeType
    
    public typealias ObjectType = D
    
    
    // MARK: FilePrivate
    
    fileprivate init(_ monitor: ListMonitor<D>, _ changeType: ChangeType) {
        
        self.monitor = monitor
        self.changeType = changeType
    }
}


// MARK: - SharedSequence where SharingStrategy == SignalSharingStrategy, Element: RxListChangeType

extension SharedSequence where SharingStrategy == SignalSharingStrategy, Element: RxListChangeType {
    
    public typealias ListMonitorType = ListMonitor<Element.ObjectType>
    public typealias ListChangeType = RxListChange<Element.ObjectType>.ChangeType
    
    public func filterListWillChange() -> Signal<ListMonitorType> {
        
        return self.flatMap { (listChange) -> Signal<ListMonitorType> in
            
            if case .listWillChange = listChange.changeType {
                
                return .just(listChange.monitor)
            }
            return .never()
        }
    }
    
    public func filterListDidChange() -> Signal<ListMonitorType> {
        
        return self.flatMap { (listChange) -> Signal<ListMonitorType> in
            
            if case .listDidChange = listChange.changeType {
                
                return .just(listChange.monitor)
            }
            return .never()
        }
    }
    
    public func filterListWillRefetch() -> Signal<ListMonitorType> {
        
        return self.flatMap { (listChange) -> Signal<ListMonitorType> in
            
            if case .listWillRefetch = listChange.changeType {
                
                return .just(listChange.monitor)
            }
            return .never()
        }
    }
    
    public func filterListDidRefetch() -> Signal<ListMonitorType> {
        
        return self.flatMap { (listChange) -> Signal<ListMonitorType> in
            
            if case .listDidRefetch = listChange.changeType {
                
                return .just(listChange.monitor)
            }
            return .never()
        }
    }
    
    public func filterObjectInserted() -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, toIndexPath: IndexPath)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, toIndexPath: IndexPath)> in
            
            if case .objectInserted(let object, let indexPath) = listChange.changeType {
                
                return .just((listChange.monitor, object, indexPath))
            }
            return .never()
        }
    }
    
    public func filterObjectDeleted() -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, fromIndexPath: IndexPath)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, fromIndexPath: IndexPath)> in
            
            if case .objectDeleted(let object, let indexPath) = listChange.changeType {
                
                return .just((listChange.monitor, object, indexPath))
            }
            return .never()
        }
    }
    
    public func filterObjectUpdated() -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, atIndexPath: IndexPath)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, atIndexPath: IndexPath)> in
            
            if case .objectUpdated(let object, let indexPath) = listChange.changeType {
                
                return .just((listChange.monitor, object, indexPath))
            }
            return .never()
        }
    }
    
    public func filterObjectMoved() -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, fromIndexPath: IndexPath, toIndexPath: IndexPath)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, object: Element.ObjectType, fromIndexPath: IndexPath, toIndexPath: IndexPath)> in
            
            if case .objectMoved(let object, let fromIndexPath, let toIndexPath) = listChange.changeType {
                
                return .just((listChange.monitor, object, fromIndexPath, toIndexPath))
            }
            return .never()
        }
    }
    
    public func filterSectionInserted() -> Signal<(monitor: ListMonitorType, section: NSFetchedResultsSectionInfo, toSectionIndex: Int)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, section: NSFetchedResultsSectionInfo, toSectionIndex: Int)> in
            
            if case .sectionInserted(let section, let sectionIndex) = listChange.changeType {
                
                return .just((listChange.monitor, section, sectionIndex))
            }
            return .never()
        }
    }
    
    public func filterSectionDeleted() -> Signal<(monitor: ListMonitorType, section: NSFetchedResultsSectionInfo, fromSectionIndex: Int)> {
        
        return self.flatMap { (listChange) -> Signal<(monitor: ListMonitorType, section: NSFetchedResultsSectionInfo, fromSectionIndex: Int)> in
            
            if case .sectionDeleted(let section, let sectionIndex) = listChange.changeType {
                
                return .just((listChange.monitor, section, sectionIndex))
            }
            return .never()
        }
    }
}


// MARK: - RxAnonymousObserver

internal final class RxAnonymousObserver<D: DynamicObject>: ListSectionObserver {
    
    internal typealias ListChangeType = RxListChange<D>
    
    internal init(_ observable: AnyObserver<ListChangeType>) {
        
        self.observable = observable
    }
    
    
    // MARK: ListObserver
    
    internal typealias ListEntityType = D
    
    internal func listMonitorWillChange(_ monitor: ListMonitor<ListEntityType>) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.listWillChange)
        )
    }
    
    internal func listMonitorDidChange(_ monitor: ListMonitor<ListEntityType>) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.listDidChange)
        )
    }
    
    internal func listMonitorWillRefetch(_ monitor: ListMonitor<ListEntityType>) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.listWillRefetch)
        )
    }
    
    internal func listMonitorDidRefetch(_ monitor: ListMonitor<ListEntityType>) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.listDidRefetch)
        )
    }
    
    
    // MARK: ListObjectObserver
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didInsertObject object: ListEntityType, toIndexPath indexPath: IndexPath) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.objectInserted(object: object, toIndexPath: indexPath))
        )
    }
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didDeleteObject object: ListEntityType, fromIndexPath indexPath: IndexPath) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.objectDeleted(object: object, fromIndexPath: indexPath))
        )
    }
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didUpdateObject object: ListEntityType, atIndexPath indexPath: IndexPath) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.objectUpdated(object: object, atIndexPath: indexPath))
        )
    }
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didMoveObject object: ListEntityType, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.objectMoved(object: object, fromIndexPath: fromIndexPath, toIndexPath: toIndexPath))
        )
    }
    
    
    // MARK: ListSectionObserver
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.sectionInserted(section: sectionInfo, toSectionIndex: sectionIndex))
        )
    }
    
    internal func listMonitor(_ monitor: ListMonitor<ListEntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.observable.onNext(
            ListChangeType(monitor, ListChangeType.ChangeType.sectionDeleted(section: sectionInfo, fromSectionIndex: sectionIndex))
        )
    }
    
    
    // MARK: Private
    
    fileprivate let observable: AnyObserver<ListChangeType>
}
