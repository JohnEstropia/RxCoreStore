//
//  RxCoreStore.swift
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


// MARK: - CoreStore

@available(*, deprecated, message: "Call methods directly from the DataStack instead")
extension CoreStore {
    
    /**
     Reactive extensions for the `defaultStack`. 
     */
    public static var rx: Reactive<DataStack> {
        
        get { return Shared.defaultStack.rx }
        set { Shared.defaultStack.rx = newValue }
    }
}


// MARK: - DataStack

extension DataStack: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = DataStack
}


// MARK: - ListMonitor

extension ListMonitor: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = ListMonitor
}


// MARK: - ObjectMonitor

extension ObjectMonitor: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = ObjectMonitor
}


// MARK: - LiveList

extension LiveList: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = LiveList
}


// MARK: - LiveObject

extension LiveObject: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = LiveObject
}


// MARK: - CoreStoreObject

extension CoreStoreObject: ReactiveCompatible {
    
    // MARK: ReactiveCompatible
    
    public typealias ReactiveBase = CoreStoreObject
}
