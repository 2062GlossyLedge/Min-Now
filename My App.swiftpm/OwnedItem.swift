// Represents the OwnedItem Model with the logic and variations of this model's attributes
import Foundation
import SwiftUI

// Make models Codable for UserDefaults storage
// What category their owned item falls under
enum ItemType: String, CaseIterable, Identifiable, Codable {
    
    case clothing = "Clothing"
    case technology = "Technology"
    case householdItem = "Household Item"
    case vehicle = "Vehicle"
    case other = "Other"
    
    
    var id: String { self.rawValue }
}

// an item can be kept, ready to give, or donated
enum ItemStatus: String, Identifiable, Codable {
    case keep = "Keep"
    case give = "Give"
    case donate = "Donate"
    
    var id: String { self.rawValue }
}

// gets first day of month of the current month
var firstDayOfMonth: Date {
    let calendar = Calendar.current
    // hack: leave out day and it defaults to the first day of month
    let components = calendar.dateComponents([.year, .month], from: Date())
    return calendar.date(from: components)!
}

// Represents the time span between two set dates
struct TimeSpan: Codable {
    var years: Int
    var months: Int
    var days: Int
    
    var description: String {
        let yearText = years > 0 ? "\(years)y " : "0y "
        let monthText = months > 0 ? "\(months)m " : "0m "
        //granularity would be justified if checkupInterval was more granular
       // let dayText = days > 0 ? "\(days)d" : "0d"
        
        return "\(yearText)\(monthText)".trimmingCharacters(in: .whitespaces)
    }
    
    // calculate years and months passed of time span
    static func from(start: Date, end: Date) -> TimeSpan {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: start, to: end)
        
        return TimeSpan(
            years: components.year ?? 0,
            months: components.month ?? 0,
            days: components.day ?? 0
        )
    }
}

// Time representation of a checkup
struct Checkup: Codable {
    //last time user submitted a checkup
    var lastCheckupDate: Date
    // user set months between checkups. 
    var checkupIntervalMonths: Int = 1
    
    var isCheckupDue: Bool {
        let calendar = Calendar.current
        let now = Date()
        // For testing item checkup icon triggering
//        guard let now = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 28))
//                else{
//            return false
//              }
        
        //get time since last checkup
        let components = calendar.dateComponents([.month], from: lastCheckupDate, to: now)
        let monthsSinceLastCheckup = components.month ?? 0
        
        return monthsSinceLastCheckup >= checkupIntervalMonths
    }
    
    // sets last checkup on date it was completed
    mutating func completeCheckup() {
        lastCheckupDate = Date()
    }
    
    // change months of interval
    mutating func changeCheckupInterval(months: Int) {
        checkupIntervalMonths = months
    }
}

// Represents the base model underlying user inputted data
struct OwnedItem: Identifiable, Codable {
    let id: UUID
    // name of the item
    var name: String
    // emoji representation instead - needs a name change
    var pictureURL: String
    // the date they recieved they item they now own
    var itemReceivedDate: Date
    // an item can be kept, ready to give, or donated
    var status: ItemStatus
    // The date they last used the object they own. Currently, the date goes to today if they mark an item as unused in keep checkup view
    var lastUsed: Date
    //category of owned item
    var itemType: ItemType
    
    // how long it's been since they recieved the item
    var ownershipDuration: TimeSpan {
        TimeSpan.from(start: itemReceivedDate, end: Date())
    }
    
//    The time span since they last used the object they own. Currently, the date goes to today if they mark an item as unused in keep checkup view
    var lastUsedDuration: TimeSpan {
        TimeSpan.from(start: lastUsed, end: Date())
    }
}

// dummy items for testing 
let dummyItems: [OwnedItem] = [
    OwnedItem(
        id: UUID(),
        name: "iPhone 7",
        pictureURL: "📱",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -86, to: Date())!,
        status: .keep,
        lastUsed: Date(), // Used today
        itemType: .technology
    ),
    OwnedItem(
        id: UUID(),
        name: "Leather Winter Coat",
        pictureURL: "🧥",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -38, to: Date())!,
        status: .donate,
        lastUsed: Calendar.current.date(byAdding: .month, value: -26, to: Date())!, // Last used 26 months ago
        itemType: .clothing
    ),
    OwnedItem(
        id: UUID(),
        name: "Chair from downstairs",
        pictureURL: "🪑",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -84, to: Date())!,
        status: .donate,
        lastUsed: Calendar.current.date(byAdding: .month, value: -6, to: Date())!, // Last used 6 months ago
        itemType: .householdItem
    ),
    OwnedItem(
        id: UUID(),
        name: "Trek Mountain Bike",
        pictureURL: "🚲",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -25, to: Date())!,
        status: .keep,
        lastUsed: Calendar.current.date(byAdding: .month, value: -6, to: Date())!, // Last used 6 months ago
        itemType: .vehicle
    ),
    OwnedItem(
        id: UUID(),
        name: "K2 Keyboard",
        pictureURL: "⌨️",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -26, to: Date())!,
        status: .give,
        lastUsed: Calendar.current.date(byAdding: .month, value: -14, to: Date())!, // Last used 2 months ago
        itemType: .technology
    ),
    OwnedItem(
        id: UUID(),
        name: "Guitar",
        pictureURL: "🎸",
        itemReceivedDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
        status: .keep,
        lastUsed: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, // Last used 5 days ago
        itemType: .other
    )
]

//manages owned items and actions done to them
@MainActor
class ItemsManager: ObservableObject {
    @Published var items: [OwnedItem] = []
    @Published var keepCheckup: Checkup
    @Published var giveCheckup: Checkup
    
    private let itemsKey = "savedItems"
    private let keepCheckupKey = "keepCheckup"
    private let giveCheckupKey = "giveCheckup"
    
    //Loading part of Persistance implementation
    init() {
        
        // Load items from UserDefaults
        if let savedItems = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([OwnedItem].self, from: savedItems) {
            self.items = decodedItems
        }
        
        // Load checkups from UserDefaults
        if let savedKeepCheckup = UserDefaults.standard.data(forKey: keepCheckupKey),
           let decodedKeepCheckup = try? JSONDecoder().decode(Checkup.self, from: savedKeepCheckup) {
            self.keepCheckup = decodedKeepCheckup
        } else {
            // Default keepCheckup if none saved
            self.keepCheckup = Checkup(
                lastCheckupDate: firstDayOfMonth,
                checkupIntervalMonths: 1
            )
        }
        
        if let savedGiveCheckup = UserDefaults.standard.data(forKey: giveCheckupKey),
           let decodedGiveCheckup = try? JSONDecoder().decode(Checkup.self, from: savedGiveCheckup) {
            self.giveCheckup = decodedGiveCheckup
        } else {
            // Default giveCheckup if none saved
            self.giveCheckup = Checkup(
                lastCheckupDate: firstDayOfMonth,
                checkupIntervalMonths: 1
            )
        }
    }
    
    //Saving part of persistance implementation
    //saves locally
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func saveCheckups() {
        if let encodedKeep = try? JSONEncoder().encode(keepCheckup) {
            UserDefaults.standard.set(encodedKeep, forKey: keepCheckupKey)
        }
        if let encodedGive = try? JSONEncoder().encode(giveCheckup) {
            UserDefaults.standard.set(encodedGive, forKey: giveCheckupKey)
        }
    }
    

    //add item to list of OwnedItems
    func addItem(_ item: OwnedItem) {
        items.append(item)
        saveItems()
    }
    
    // To delete an OwnedItem
    func deleteItems(at offsets: IndexSet, from filteredItems: [OwnedItem]) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        //delete id matching swiped owned item id
        items.removeAll(where: { item in
            itemsToDelete.contains(where: { $0.id == item.id })
        })
        saveItems()
    }
    
    // getters and setters
    
    //switch item status - for use in checkup, paired with swiping actions
    func updateItemStatus(id: UUID, to status: ItemStatus) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].status = status
            saveItems()
        }
    }
    
    //edits keep checkup global state
    func completeKeepCheckup() {
        keepCheckup.completeCheckup()
        saveCheckups()
    }
    
    //edits give checkup global state
    func completeGiveCheckup() {
        giveCheckup.completeCheckup()
        saveCheckups()
    }
    
    
    
    //Pass in amount of months to apass between intervals
    func changeKeepCheckupInterval(months: Int) {
        keepCheckup.changeCheckupInterval(months: months)
        saveCheckups()
    }
    
    // interval in months to pass until next checkup
    var getKeepCheckupInterval: Int {
        keepCheckup.checkupIntervalMonths
    }
    
    //get date of when user completed last checkup for keep view
    var getLastKeepCheckup: Date {
        keepCheckup.lastCheckupDate
    }
    
    // keep checkup interval has passed so it's due
    var isKeepCheckupDue: Bool {
        keepCheckup.isCheckupDue
    }
    
    //Pass in amount of months to apass between intervals
    func changeGiveCheckupInterval(months: Int) {
        giveCheckup.changeCheckupInterval(months: months)
        saveCheckups()
    }
    
    // interval in months to pass until next checkup
    var getGiveCheckupInterval: Int {
        giveCheckup.checkupIntervalMonths
    }
    
   //get date of when user completed last checkup for give view
    var getLastGiveCheckup: Date {
        giveCheckup.lastCheckupDate
    }
    
    // give checkup interval has passed so it's due
    var isGiveCheckupDue: Bool {
        giveCheckup.isCheckupDue
    }
    
    
    //getters for each item type
    
    func getKeptItems() -> [OwnedItem] {
        items.filter { $0.status == .keep }
    }
    
    func getGiveItems() -> [OwnedItem] {
        items.filter { $0.status == .give }
    }
    func getDonatedItems() -> [OwnedItem] {
        items.filter { $0.status == .donate }
    }
    
    func getItems(of type: ItemType) -> [OwnedItem] {
        items.filter { $0.itemType == type }
        
    }
    //for testing
    func loadDummyData() {
        // Clear existing items
       // items.removeAll()
        
        //prevents dummy data from duplication during persistance methods
        
        if items.isEmpty{
            dummyItems.forEach { item in
                self.addItem(item)
            }
        }
        
        // Force save to UserDefaults
        //saveItems()
    }
    
    
}

