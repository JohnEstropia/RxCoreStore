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
    
    let species = Value.Required<String>("species", default: "Swift")
    let master = Relationship.ToOne<Person>("master")
}

class Dog: Animal {
    
    let nickname = Value.Optional<String>("nickname")
    let age = Value.Required<Int>("age", default: 1)
    let friends = Relationship.ToManyOrdered<Dog>("friends")
    let friends2 = Relationship.ToManyUnordered<Dog>("friends2", inverse: { $0.friends })
}

class Person: CoreStoreObject {
    
    let name = Value.Required<String>("name")
    let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
}


class RxCoreStoreTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        CoreStore.defaultStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<Animal>("Animal"),
                    Entity<Dog>("Dog"),
                    Entity<Person>("Person")
                ],
                versionLock: [
                    "Animal": [0x2698c812ebbc3b97, 0x751e3fa3f04cf9, 0x51fd460d3babc82, 0x92b4ba735b5a3053],
                    "Dog": [0x5285f8e3aff69199, 0x62c3291b59f2ec7c, 0xbe5a571397a4117b, 0x97fb40f5b79ffbdc],
                    "Person": [0xae4060a59f990ef0, 0x8ac83a6e1411c130, 0xa29fea58e2e38ab6, 0x2071bb7e33d77887]
                ]
            )
        )
        let setupExpectation = self.expectation(description: "setup")
        CoreStore.rx
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
                    
                    print("======= Progress: \(progress.progress)")
                },
                onError: { (error) in
                    
                    XCTFail(error.localizedDescription)
                },
                onCompleted: { 
                    
                    setupExpectation.fulfill()
                }
            )
            .addDisposableTo(self.disposeBag)
        
        let changeExpectation = self.expectation(description: "change")
        let monitor = CoreStore.rx
            .monitorList(
                From<Dog>(),
                OrderBy(.ascending(Dog.keyPath({ $0.nickname })))
            )
            .share()
        monitor
            .subscribe(
                onNext: { (change) in
                    
                    switch change.changeType {
                        
                    case .listDidChange:
                        print("didChange")
                        changeExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            .addDisposableTo(self.disposeBag)
        
        let transactionExpectation = self.expectation(description: "transaction")
        CoreStore.rx
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
                onNext: { (person) in
                    
                    let validPerson = CoreStore.fetchExisting(person)
                    XCTAssertNotNil(validPerson)
                    XCTAssertNotNil(validPerson?.pet.value)
                    
                    transactionExpectation.fulfill()
                }
            )
            .addDisposableTo(self.disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
