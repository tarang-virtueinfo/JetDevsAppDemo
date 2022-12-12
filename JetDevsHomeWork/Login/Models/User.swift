import Foundation

// MARK: - DataClass
struct UserInformation: Codable {
    let user: User?
}

// MARK: - User
struct User: Codable {
    let userID: Int
    let userName: String
    let userProfileURL: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case userName = "user_name"
        case userProfileURL = "user_profile_url"
        case createdAt = "created_at"
    }
}

extension User {
    
    var createdAtDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        let date = dateFormatter.date(from: createdAt)
        return date
    }
    var createDayAgo: Int {
        guard let createdAtDate = createdAtDate else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: createdAtDate, to: Date()).day!
    }
}
