//
//  RxCoreStoreTests.swift
//  RxCoreStoreTests
//
//  Created by John Estropia on 2017/04/03.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import XCTest

@testable import CoreStore
@testable import RxCoreStore


class Animal: CoreStoreObject {
    
    let species = Value.Required<String>("species", initial: "Swift")
    let master = Relationship.ToOne<Person>("master")
}

class Dog: Animal {
    
    let nickname = Value.Optional<String>("nickname")
    let age = Value.Required<Int>("age", initial: 1)
    let friends = Relationship.ToManyOrdered<Dog>("friends")
    let friendedBy = Relationship.ToManyUnordered<Dog>("friendedBy", inverse: { $0.friends })
}

class Person: CoreStoreObject, ImportableUniqueObject {
    
    let name = Value.Required<String>("name", initial: "")
    let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
    
    typealias ImportSource = [String: String]
    typealias UniqueIDType = String
    
    static let uniqueIDKeyPath = String(keyPath: \Person.name)
    
    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType? {
        
        return source["name"]
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        
        // ...
    }
}


class RxCoreStoreTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    func testExample() {
        
        CoreStoreDefaults.dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<Animal>("Animal"),
                    Entity<Dog>("Dog"),
                    Entity<Person>("Person")
                ],
                versionLock: [
                    "Animal": [0x2698c812ebbc3b97, 0x751e3fa3f04cf9, 0x51fd460d3babc82, 0x92b4ba735b5a3053],
                    "Dog": [0x312e29f63a693638, 0x67b48196ec0cbce3, 0x755e1eb00c29e723, 0xd86e2481e3d56bc1],
                    "Person": [0xae4060a59f990ef0, 0x8ac83a6e1411c130, 0xa29fea58e2e38ab6, 0x2071bb7e33d77887]
                ]
            )
        )
        let setupExpectation = self.expectation(description: "setup")
        CoreStoreDefaults.dataStack.rx
            .addStorage(
                SQLiteStore(
                    fileURL: SQLiteStore.defaultRootDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathComponent("\(type(of: self))_(-null-).sqlite"),
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            .subscribe(
                onNext: { (progress) in
                    
                    print("======= Progress: \(progress.fractionCompleted * 100) %")
                    setupExpectation.fulfill()
                },
                onError: { (error) in
                    
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
        
        let monitorChangeExpectation = self.expectation(description: "monitorChange")
        let monitor = CoreStoreDefaults.dataStack.rx.monitorList(
            From<Dog>()
                .orderBy(.ascending(\.nickname))
        )
        monitor
            .emit(
                onNext: { (change) in
                    
                    switch change.tuple {
                        
                    case (let monitor, .listDidChange):
                        XCTAssertEqual(monitor.numberOfObjects(), 1)
                        monitorChangeExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            .disposed(by: self.disposeBag)

        let publisherChangeExpectation = self.expectation(description: "publisherChange")
        let publisher = CoreStoreDefaults.dataStack.publishList(
            From<Dog>()
                .orderBy(.ascending(\.nickname))
        )
        publisher.rx.snapshotSignal()
            .emit(
                onNext: { (snapshot) in

                    XCTAssertEqual(snapshot.numberOfItems, 1)
                    publisherChangeExpectation.fulfill()
                }
            )
            .disposed(by: self.disposeBag)
        
        let transactionExpectation = self.expectation(description: "transaction")
        CoreStoreDefaults.dataStack.rx
            .perform(
                asynchronous: { (transaction) -> Person in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species.value, "Swift")
                    XCTAssertTrue(type(of: animal.species.value) == String.self)
                    
                    animal.species .= "Sparrow"
                    XCTAssertEqual(animal.species.value, "Sparrow")
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species.value, "Swift")
                    XCTAssertEqual(dog.nickname.value, nil)
                    XCTAssertEqual(dog.age.value, 1)
                    
                    dog.species .= "Dog"
                    XCTAssertEqual(dog.species.value, "Dog")
                    
                    dog.nickname .= "Spot"
                    XCTAssertEqual(dog.nickname.value, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertNil(person.pet.value)
                    
                    person.pet .= dog
                    XCTAssertEqual(person.pet.value, dog)
                    XCTAssertEqual(person.pet.value?.master.value, person)
                    XCTAssertEqual(dog.master.value, person)
                    XCTAssertEqual(dog.master.value?.pet.value, dog)
                    return person
                }
            )
            .subscribe(
                onSuccess: { (person) in
                    
                    let validPerson = CoreStoreDefaults.dataStack.fetchExisting(person)
                    XCTAssertNotNil(validPerson)
                    XCTAssertNotNil(validPerson?.pet.value)
                    
                    transactionExpectation.fulfill()
                },
                onError: { (error) in
                    
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
        
        let importExpectation = self.expectation(description: "import")
        CoreStoreDefaults.dataStack.rx
            .importUniqueObjects(
                Into<Person>(),
                sourceArray: [
                    ["name": "John"],
                    ["name": "Bob"],
                    ["name": "Joe"]
                ]
            )
            .subscribe(
                onSuccess: { (people) in
                    
                    XCTAssertEqual(people.count, 3)
                    XCTAssertEqual(Set(people.map({ $0.name.value })), Set(["John", "Bob", "Joe"]))
                    importExpectation.fulfill()
                },
                onError: { (error) in
                    
                    XCTFail(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
