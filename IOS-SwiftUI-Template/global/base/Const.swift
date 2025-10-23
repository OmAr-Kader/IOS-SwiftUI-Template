import Foundation


struct Const : Sendable {
    
    nonisolated static let SCHEMA_VERSION: UInt64 = 0
    
    nonisolated static let PREF_USER_ID: String = "userId"
    nonisolated static let PREF_USER_NAME: String = "userName"
    nonisolated static let PREF_USER_EMAIL: String = "userEmail"
    nonisolated static let PREF_USER_TYPE: String = "userType"

    nonisolated static let CLOUD_SUCCESS = 1
    nonisolated static let CLOUD_FAILED = 0
}

