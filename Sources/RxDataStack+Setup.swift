//
//  RxDataStack+Setup.swift
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


// MARK: - Reactive

extension Reactive where Base == DataStack {
    
    // MARK: -
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `addStorage(...)` API. Asynchronously adds a `StorageInterface` to the stack.
     ```
     dataStack.rx
         .addStorage(InMemoryStore(configuration: "Config1"))
         .subscribe(
             onError: { (error) in
                 // ...
             },
             onSuccess: { (dataStack, storage) in
                 // ...
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter storage: the storage
     - returns: An `Observable<RxStorageProgressType>` type. Note that the `StorageInterface` element of the observable may not always be the same instance as the parameter argument if a previous `StorageInterface` was already added at the same URL and with the same configuration.
     */
    public func addStorage<T: StorageInterface>(_ storage: T) -> Observable<DataStack.RxStorageProgress<T>> {
        
        return Observable<DataStack.RxStorageProgress<T>>.create(
            { (observable) -> Disposable in
                
                self.base.addStorage(
                    storage,
                    completion: { (result) in
                        
                        switch result {
                            
                        case .success(let storage):
                            observable.onNext(DataStack.RxStorageProgress(storage: storage, progress: nil, isCompleted: true))
                            observable.onCompleted()
                            
                        case .failure(let error):
                            observable.onError(error)
                        }
                    }
                )
                return Disposables.create()
            }
        )
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `addStorage(...)` API. Asynchronously adds a `LocalStorage` to the stack. Migrations are also initiated by default. The observable element will be the `Progress` for migrations will be reported to the `onNext` element.
     ```
     dataStack.rx
         .addStorage(
             SQLiteStore(
                 fileName: "core_data.sqlite", 
                 configuration: "Config1"
             )
         )
         .subscribe(
             onNext: { (progress) in
                 print("\(round(progress.fractionCompleted * 100)) %") // 0.0 ~ 1.0
             },
             onError: { (error) in
                 // ...
             },
             onCompleted: {
                 // ...
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter storage: the local storage
     - returns: An `Observable<RxStorageProgressType>` type. Note that the `LocalStorage` associated to the `RxStorageProgressType` may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
    public func addStorage<T: LocalStorage>(_ storage: T) -> Observable<DataStack.RxStorageProgress<T>> {
        
        return Observable<DataStack.RxStorageProgress<T>>.create(
            { (observable) in
                
                var progress: Progress?
                progress = self.base.addStorage(
                    storage,
                    completion: { (result) in
                        
                        switch result {
                            
                        case .success(let storage):
                            observable.onNext(DataStack.RxStorageProgress(storage: storage, progress: progress, isCompleted: true))
                            observable.onCompleted()
                            
                        case .failure(let error):
                            observable.onError(error)
                        }
                    }
                )
                if let progress = progress {
                    
                    let disposable = progress.rx
                        .observeWeakly(Double.self, #keyPath(Progress.fractionCompleted))
                        .subscribe(
                            onNext: { _ in
                                
                                observable.onNext(DataStack.RxStorageProgress(storage: storage, progress: progress))
                            }
                        )
                    return Disposables.create([disposable])
                }
                else {
                    
                    return Disposables.create()
                }
            }
        )
    }
}


// MARK: - RxStorageProgressType

/**
 An `RxStorageProgressType` contains info on a `StorageInterface`'s setup progress.
 
 - SeeAlso: DataStack.rx.addStorage(_:)
 */
public protocol RxStorageProgressType {
    
    /**
     The `StorageInterface` concrete type
     */
    associatedtype StorageType: StorageInterface
    
    /**
     The `StorageInterface` instance
     */
    var storage: StorageType { get }
    
    /**
     The `Progress` instance associated with a migration. Returns `nil` if no migration is needed.
     */
    var progressObject: Progress? { get }
    
    /**
     Returns `true` if the storage was successfully added to the stack, `false` otherwise.
     */
    var isCompleted: Bool { get }
    
    /**
     The fraction of the overall work completed by the migration. Returns a value between 0.0 and 1.0.
     */
    var fractionCompleted: Double { get }
}


// MARK: - DataStack

extension DataStack {
    
    // MARK: - RxStorageProgress
    
    /**
     An `RxStorageProgress` contains info on a `StorageInterface`'s setup progress.
     
     - SeeAlso: DataStack.rx.addStorage(_:)
     */
    public struct RxStorageProgress<T: StorageInterface>: RxStorageProgressType {
        
        // MARK: RxStorageProgressType
        
        public typealias StorageType = T
        
        public let storage: T
        public let progressObject: Progress?
        public let isCompleted: Bool
        
        public var fractionCompleted: Double {
            
            return self.isCompleted
                ? 1
                : (self.progressObject?.fractionCompleted ?? 0.0)
        }
        
        
        // MARK: Internal
        
        internal init(storage: T, progress: Progress?, isCompleted: Bool = false) {
            
            self.storage = storage
            self.progressObject = progress
            self.isCompleted = isCompleted
        }
    }
}


// MARK: - ObservableType where Element: RxStorageProgressType, Element.StorageType: LocalStorage

extension ObservableType where Element: RxStorageProgressType, Element.StorageType: LocalStorage {
    
    /**
     Filters an `Observable<RxStorageProgressType>` to send events only for `Progress` elements, which is sent only when a migration is required. This observable will not fire `onNext` events if no migration is required.
     */
    public func filterMigrationProgress() -> Observable<Progress> {
        
        return self.flatMap { (progress) -> Observable<Progress> in
            
            if let progressObject = progress.progressObject {
                
                return .just(progressObject)
            }
            return .empty()
        }
    }
    
    /**
     Filters an `Observable<RxStorageProgressType>` to fire only when the storage setup is complete.
     */
    public func filterIsCompleted() -> Observable<Void> {
        
        return self.filter({ $0.isCompleted }).map({ _ in })
    }
    
    /**
     Maps an `Observable<RxStorageProgressType>` to an `Observable` with its `fractionCompleted` value.
     */
    public func mapFractionCompleted() -> Observable<Double> {
        
        return self.map({ $0.fractionCompleted })
    }

}
