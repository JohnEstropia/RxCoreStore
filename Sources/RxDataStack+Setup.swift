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

import CoreStore
import RxCocoa
import RxSwift


// MARK: - DataStack

public extension DataStack {
    
    // MARK: - RxStorageProgress
    
    public struct RxStorageProgress<T: StorageInterface> {
        
        public let storage: T
        public let progressObject: Progress?
        public let completed: Bool
        
        public var progress: Double {
            
            return self.completed
                ? 1
                : (self.progressObject?.fractionCompleted ?? 0.0)
        }
        
        
        // MARK: Internal
        
        internal init(storage: T, progress: Progress?, completed: Bool = false) {
            
            self.storage = storage
            self.progressObject = progress
            self.completed = completed
        }
    }
}


// MARK: - Reactive

extension Reactive where Base == DataStack {
    
    // MARK: -
    
    public func addStorage<T: StorageInterface>(_ storage: T) -> Observable<T> {
        
        return Observable.create(
            { (observable) -> Disposable in
                
                self.base.addStorage(
                    storage,
                    completion: { (result) in
                        
                        switch result {
                            
                        case .success(let storage):
                            observable.onNext(storage)
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
    
    public func addStorage<T: LocalStorage>(_ storage: T) -> Observable<DataStack.RxStorageProgress<T>> {
        
        return Observable<DataStack.RxStorageProgress<T>>.create(
            { (observable) in
                
                var progress: Progress?
                progress = self.base.addStorage(
                    storage,
                    completion: { (result) in
                        
                        switch result {
                            
                        case .success(let storage):
                            observable.onNext(DataStack.RxStorageProgress(storage: storage, progress: progress, completed: true))
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


// MARK: - ObservableType

extension ObservableType {
    
    public func filterCompleted<T: LocalStorage>() -> Observable<E> where E == DataStack.RxStorageProgress<T> {
        
        return self.filter({ $0.completed })
    }
    
    public func filterProgress<T: LocalStorage>() -> Observable<Double> where E == DataStack.RxStorageProgress<T> {
        
        return self
            .filter({ !$0.completed })
            .map({ $0.progress })
    }
}
