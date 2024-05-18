import Foundation
import RealmSwift


extension List {
    
    func toList() -> [Element] {
        var list: [Element] = [Element]()
        self.forEach { it in
            list.append(it)
        }
        return list
    }

}

extension Array<String> {
    
    func toRealmList() -> List<String> {
        let realmList: List<String> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : EmbeddedObject {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : Object {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }
}

