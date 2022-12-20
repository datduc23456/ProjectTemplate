//
//  RealmUtils.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 22/11/2022.
//

import Foundation
import RealmSwift

public var realmSchemaVersion = 1

class RealmUtils {
    public var realm: Realm

    public convenience init(dbName: String) {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(dbName).realm")
        print("init DB at path\(config.fileURL?.absoluteString)")
        config.schemaVersion = UInt64(realmSchemaVersion)
        config.migrationBlock = { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            
        }
        let realm = try! Realm.init(configuration: config)
        self.init(realm: realm)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    internal init(realm: Realm){
        self.realm = realm
    }
    
    func insert(_ object: Object){
        try! realm.write {
            realm.add(object)
        }
    }
    
    func insertOrUpdate(_ object: Object){
        try! realm.write {
            realm.add(object, update: .all)
        }
    }
    
    func insertOrUpdate(_ objects: [Object]) {
        try! realm.write {
            realm.add(objects, update: .all)
        }
    }
    
    func insertOrUpdate<T: Object>(type: T.Type, value: Any){
        try! realm.write {
            realm.create(type, value: value, update: .all)
        }
    }
    
    func deleteAllObject(){
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func deleteObject<T: Object>(object: T){
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func maxId<T: Object>(type: T.Type) -> Int {
        let data = realm.objects(type)
        return data.max(ofProperty: "id") ?? 0
    }

    func getListObjects<T: Object>(type: T.Type)-> [T] {
        let realmResults = realm.objects(T.self)
        return Array(realmResults)
    }

    func dataQuery<T: Object>(type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func dataQueryByPredicate<T: Object>(type: T.Type, predicate: NSPredicate) -> Results<T>{
        return realm.objects(type).filter(predicate)
    }
    
    
    func quantityDataByPredicate<T: Object>(type: T.Type, predicate: NSPredicate) -> Int {
        return realm.objects(type).filter(predicate).count
    }
}

class RealmUtilsProvider {
    static var defaultStorage = RealmUtils(dbName: "DTPRealm")
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
