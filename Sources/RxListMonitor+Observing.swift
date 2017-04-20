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

import CoreStore
import RxSwift


public protocol RxListMonitorType {

    associatedtype ObjectType: DynamicObject
}


extension ListMonitor: RxListMonitorType {
    
}

public protocol _RxListChangeType {
    
    associatedtype ObjectType: DynamicObject
    
    var monitor: ListMonitor<ObjectType> { get }
    var changeType: RxListChange<ObjectType>.ChangeType { get }
}

extension _RxListChangeType {
    
//    public typealias ListChangeType = RxListChangeType<ListMonitorType.ObjectType>
//    
//    public func map<T>(
//        listChange: (_ monitor: ListMonitorType, _ change: ListChangeType.ListChange) -> T,
//        objectChange: (_ monitor: ListMonitorType, _ change: ListChangeType.ObjectChange) -> T,
//        sectionChange: (_ monitor: ListMonitorType, _ change: ListChangeType.SectionChange) -> T) -> T {
//        
//        let monitor = self.monitor
//        switch self.change {
//            
//        case let change as ListChangeType.ListChange:
//            return listChange(monitor, change)
//            
//        case let change as ListChangeType.ObjectChange:
//            return objectChange(monitor, change)
//            
//        case let change as ListChangeType.SectionChange:
//            return sectionChange(monitor, change)
//            
//        default:
//            fatalError()
//        }
//    }
}


// MARK: - RxAnyListChange

public protocol RxAnyListChange {}


// MARK: - RxListChange

public struct RxListChange<D: DynamicObject>: _RxListChangeType {
    
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
    
    
    // MARK: _RxListChangeType
    
    public typealias ObjectType = D
    
    
    // MARK: FilePrivate
    
    fileprivate init(_ monitor: ListMonitor<D>, _ changeType: ChangeType) {
        
        self.monitor = monitor
        self.changeType = changeType
    }
}


// MARK: - Reactive

extension Reactive where Base: _RxListChangeType {
    
}


// MARK: - ObservableType

extension ObservableType where E: _RxListChangeType {
    
//    public typealias ListMonitorType = ListMonitor<E.ObjectType>
//    public typealias ListChangeType = RxListChange<E.ObjectType>.ChangeType
//    
//    public func filterListChanges() -> Observable<(monitor: ListMonitorType, change: ListChangeType)> {
//        
//        return self.flatMap { (listChange) -> Observable<(monitor: ListMonitorType, change: ListChangeType.ListChange)> in
//            
//            switch listChange.change {
//                
//            case let change as ListChangeType.ListChange:
//                return .just((monitor: listChange.monitor, change: change))
//                
//            default:
//                return .empty()
//            }
//        }
//    }
}



// MARK: - RxAnonymousObserver


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
