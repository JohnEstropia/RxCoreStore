//
//  RxDataStack+Observing.swift
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


// MARK: - Reactive

extension Reactive where Base == DataStack {
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorList(
         From<Person>().where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorList<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> Signal<RxListChange<D>> {
        
        return self.monitorList(from, fetchClauses)
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorList(
         From<Person>().where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorList<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> Signal<RxListChange<D>> {
        
        return self.base.monitorList(from, fetchClauses).asSignal(onErrorSignalWith: .never())
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorList(
         From<Person>().where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter clauseChain: a fetch chain created from a `From` clause.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorList<B: FetchChainableBuilderType>(_ clauseChain: B) -> Signal<RxListChange<B.ObjectType>>{
        
        return self.monitorList(clauseChain.from, clauseChain.fetchClauses)
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorSectionedList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorSectionedList(
         From<Person>()
             .sectionBy(\.age)
             .where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorSectionedList<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: FetchClause...) -> Signal<RxListChange<D>> {
        
        return self.monitorSectionedList(from, sectionBy, fetchClauses)
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorSectionedList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorSectionedList(
         From<Person>()
             .sectionBy(\.age)
             .where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorSectionedList<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: [FetchClause]) -> Signal<RxListChange<D>> {
        
        return self.base.monitorSectionedList(from, sectionBy, fetchClauses).asSignal(onErrorSignalWith: .never())
    }
    
    /**
     Reactive extension for `CoreStore.DataStack`'s `monitorSectionedList(...)` API. Creates an observable that wraps a `ListMonitor` that satisfies the specified fetch clauses. Multiple subscriptions be notified when changes are made to the list. The observable element will contain an `RxListChange` value.
     ```
     let listObserver = dataStack.rx.monitorSectionedList(
         From<Person>()
             .sectionBy(\.age),
             .where(\.age >= 30)
     )
     
     listObserver.
         .emit(
             onNext: { (change) in
                 if case .listDidChange = change.changeType {
                     tableView.reloadData()
                 }
             }
         )
         .disposed(by: disposeBag)
     
     listObserver.
         .filterListDidChange()
         .emit(
             onNext: { _ in
                 tableView.reloadData()
             }
         )
         .disposed(by: disposeBag)
     ```
     - parameter clauseChain: a fetch chain created from a `From` clause.
     - returns: A `Signal` for changes in the list.
     */
    public func monitorSectionedList<B: SectionMonitorBuilderType>(_ clauseChain: B) -> Signal<RxListChange<B.ObjectType>> {
        
        return self.monitorSectionedList(
            clauseChain.from,
            clauseChain.sectionBy,
            clauseChain.fetchClauses
        )
    }
}
