//
//  RxDynamicObject.swift
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

import CoreData
import CoreStore
import RxCocoa
import RxSwift


// MARK: - Reactive where Base: NSManagedObject

extension Reactive where Base: NSManagedObject {
    
    public func monitorObject() -> Signal<RxObjectChange<Base>> {
        
        switch self.base.fetchSource() {
            
        case let dataStack as DataStack:
            return dataStack.monitorObject(self.base).asSignal(onErrorSignalWith: .never())
            
        case let transaction as UnsafeDataTransaction:
            return transaction.monitorObject(self.base).asSignal(onErrorSignalWith: .never())
            
        default:
            return .empty()
        }
    }
}


// MARK: - Reactive where Base: CoreStoreObject

extension Reactive where Base: CoreStoreObject {
    
    public func monitorObject() -> Signal<RxObjectChange<Base>> {
        
        switch self.base.fetchSource() {
            
        case let dataStack as DataStack:
            return dataStack.monitorObject(self.base).asSignal(onErrorSignalWith: .never())
            
        case let transaction as UnsafeDataTransaction:
            return transaction.monitorObject(self.base).asSignal(onErrorSignalWith: .never())
            
        default:
            return .empty()
        }
    }
}
