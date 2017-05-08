//
//  RxDataStack+Transaction.swift
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


// MARK: - Reactive

extension Reactive where Base == DataStack {
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `importObject(...)` API. Creates an `ImportableObject` by importing from the specified import source. The observable element will be the object instance correctly associated for the `DataStack`.
     ```
     dataStack.rx
         .importObject(
             Into<Person>(),
             source: ["name": "John"]
         )
         .subscribe(
             onNext: { (person) in
                 XCTAssertNotNil(person)
                 // ...
             },
             onError: { (error) in
                 // ...
             }
         )
         .addDisposableTo(disposeBag)
     ```
     - parameter into: an `Into` clause specifying the entity type
     - parameter source: the object to import values from
     - returns: An `Observable` for the imported object. The observable element, if not `nil`, will be the object instance correctly associated for the `DataStack`.
     */
    public func importObject<T: DynamicObject & ImportableObject>(_ into: Into<T>, source: T.ImportSource) -> Observable<T?> {
        
        return Observable<T?>.create(
            { (observable) -> Disposable in
                
                self.base.perform(
                    asynchronous: { (transaction) -> T? in
                        
                        return try transaction.importObject(
                            into,
                            source: source
                        )
                    },
                    success: { (object) in
                        
                        observable.onNext(object.flatMap(self.base.fetchExisting))
                        observable.onCompleted()
                    },
                    failure: { (error) in
                        
                        observable.onError(error)
                    }
                )
                return Disposables.create()
            }
        )
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `importObject(...)` API. Updates an existing `ImportableObject` by importing values from the specified import source. The observable element will be the object instance correctly associated for the `DataStack`.
     ```
     let existingPerson: Person = // ...
     dataStack.rx
         .importObject(
             existingPerson,
             source: ["name": "John", "age": 30]
         )
         .subscribe(
             onNext: { (person) in
                 XCTAssertEqual(person?.age, 30)
                 // ...
             },
             onError: { (error) in
                 // ...
             }
         )
         .addDisposableTo(disposeBag)
     ```
     - parameter object: the object to update
     - parameter source: the object to import values from
     - returns: An `Observable` for the imported object. The observable element, if not `nil`, will be the object instance correctly associated for the `DataStack`.
     */
    public func importObject<T: DynamicObject & ImportableObject>(_ object: T, source: T.ImportSource) -> Observable<T?> {
        
        return Observable<T?>.create(
            { (observable) -> Disposable in
                
                self.base.perform(
                    asynchronous: { (transaction) -> T? in
                        
                        guard let object = transaction.edit(object) else {
                            
                            try transaction.cancel()
                        }
                        try transaction.importObject(
                            object,
                            source: source
                        )
                        return object
                    },
                    success: { (object) in
                        
                        observable.onNext(object.flatMap(self.base.fetchExisting))
                        observable.onCompleted()
                    },
                    failure: { (error) in
                        
                        observable.onError(error)
                    }
                )
                return Disposables.create()
            }
        )
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `importUniqueObject(...)` API. Updates an existing `ImportableUniqueObject` or creates a new instance by importing from the specified import source. The observable element will be the object instance correctly associated for the `DataStack`.
     ```
     dataStack.rx
         .importUniqueObject(
             Into<Person>(),
             source: ["name": "John", "age": 30]
         )
         .subscribe(
             onNext: { (person) in
                 XCTAssertEqual(person?.age, 30)
                  ...
             },
                 onError: { (error) in
                 // ...
             }
         )
         .addDisposableTo(disposeBag)
     ```
     - parameter into: an `Into` clause specifying the entity type
     - parameter source: the object to import values from
     - returns: An `Observable` for the imported object. The observable element, if not `nil`, will be the object instance correctly associated for the `DataStack`.
     */
    public func importUniqueObject<T: DynamicObject & ImportableUniqueObject>(_ into: Into<T>, source: T.ImportSource) -> Observable<T?> {
        
        return Observable<T?>.create(
            { (observable) -> Disposable in
                
                self.base.perform(
                    asynchronous: { (transaction) -> T? in
                        
                        return try transaction.importUniqueObject(
                            into,
                            source: source
                        )
                    },
                    success: { (object) in
                        
                        observable.onNext(object.flatMap(self.base.fetchExisting))
                        observable.onCompleted()
                    },
                    failure: { (error) in
                        
                        observable.onError(error)
                    }
                )
                return Disposables.create()
            }
        )
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `importUniqueObjects(...)` API. Updates existing `ImportableUniqueObject`s or creates them by importing from the specified array of import sources. `ImportableUniqueObject` methods are called on the objects in the same order as they are in the sourceArray, and are returned in an array with that same order. The observable elements will be object instances correctly associated for the `DataStack`.
     ```
     dataStack.rx
         .importUniqueObjects(
             Into<Person>(),
             sourceArray: [
                 ["name": "John"],
                 ["name": "Bob"],
                 ["name": "Joe"]
             ]
         )
         .subscribe(
             onNext: { (people) in
                 XCTAssertEqual(people.count, 3)
                 // ...
             },
             onError: { (error) in
                 // ...
             }
         )
         .addDisposableTo(disposeBag)
     ```
     - Warning: If `sourceArray` contains multiple import sources with same ID, no merging will occur and ONLY THE LAST duplicate will be imported.
     - parameter into: an `Into` clause specifying the entity type
     - parameter sourceArray: the array of objects to import values from
     - parameter preProcess: a closure that lets the caller tweak the internal `UniqueIDType`-to-`ImportSource` mapping to be used for importing. Callers can remove from/add to/update `mapping` and return the updated array from the closure.
     - returns: An `Observable` for the imported objects. The observable element will be the object instances correctly associated for the `DataStack`.
     */
    public func importUniqueObjects<T: DynamicObject & ImportableUniqueObject, S: Sequence>(
        _ into: Into<T>,
        sourceArray: S,
        preProcess: @escaping (_ mapping: [T.UniqueIDType: T.ImportSource]) throws -> [T.UniqueIDType: T.ImportSource] = { $0 }) -> Observable<[T]> where S.Iterator.Element == T.ImportSource {
        
        return Observable<[T]>.create(
            { (observable) -> Disposable in
                
                self.base.perform(
                    asynchronous: { (transaction) -> [T] in
                        
                        return try transaction.importUniqueObjects(
                            into,
                            sourceArray: sourceArray,
                            preProcess: preProcess
                        )
                    },
                    success: { (objects) in
                        
                        observable.onNext(self.base.fetchExisting(objects))
                        observable.onCompleted()
                    },
                    failure: { (error) in
                        
                        observable.onError(error)
                    }
                )
                return Disposables.create()
            }
        )
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `perform(asynchronous:...)` API. Performs a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made. The changes are commited automatically after the `task` closure returns. The observable element will be the value returned from the `task` closure. Any errors thrown from inside the `task` will be wrapped in a `CoreStoreError` and reported to `Observable.onError`. To cancel/rollback changes, call `transaction.cancel()`, which throws a `CoreStoreError.userCancelled`.
     ```
     dataStack.rx
         .perform(
             asynchronous: { (transaction) -> (inserted: Set<NSManagedObject>, deleted: Set<NSManagedObject>) in
     
                 // ...
                 return (transaction.insertedObjects(), transaction.deletedObjects())
             }
         )
         .subscribe(
             onNext: {
                 let inserted = dataStack.fetchExisting($0.inserted)
                 let deleted = dataStack.fetchExisting($0.deleted)
                 // ...
             },
             onError: { (error) in
                 // ...
             }
         )
         .addDisposableTo(disposeBag)
     ```
     - parameter task: the asynchronous closure where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - returns: An `Observable` whose element will be the value returned from the `task` closure.
     */
    public func perform<T>(asynchronous: @escaping (AsynchronousDataTransaction) throws -> T) -> Observable<T> {
        
        return Observable<T>.create(
            { (observable) -> Disposable in
                
                self.base.perform(
                    asynchronous: asynchronous,
                    success: { (output) in
                        
                        observable.onNext(output)
                        observable.onCompleted()
                    },
                    failure: { (error) in
                        
                        observable.onError(error)
                    }
                )
                return Disposables.create()
            }
        )
    }
}
