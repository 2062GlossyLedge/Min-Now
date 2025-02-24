
import SwiftUI

//Ability to add an OwnedItem 
struct AddOwnedItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var itemsManager: ItemsManager
    
    @State private var name: String = ""
    @State private var pictureEmoji: String = ""
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedType: ItemType = .clothing
    
    // Month and year ranges user can select from when choosing recieved date of an item they own
    let months = Array(1...12)
    let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-100)...currentYear)
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                    
                    //limits 1 emoji to resemble item name
                    TextField("Item Emoji", text: $pictureEmoji)
                        .onChange(of: pictureEmoji, initial: false){
                            if pictureEmoji.count > 1 {
                                pictureEmoji = String(pictureEmoji.prefix(1))
                            }
                        }
                }
                
                Section("Date Received") {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text(monthName(month))
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Category") {
                    let types = ItemType.allCases

                    
                    Picker("Item Type", selection: $selectedType) {
                        //Fixed - item picker selection changes on press. Needed to loop through unqiue item types
                        ForEach(types, id: \.self) { type in
                            
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                
                }
            }
            .navigationTitle("Add New __Keep__ Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty || pictureEmoji.isEmpty)
                }
            }
        }
    }
    
    // Find month name given month number
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        guard let date = Calendar.current.date(from: DateComponents(month: month)) else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
    
    // add new item to model
    private func addItem() {
        // Create date components for the received date
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1  // Default to first of the month
        
        guard let receivedDate = Calendar.current.date(from: components) else { return }
        
        let newItem = OwnedItem(
            id: UUID(),
            name: name,
            pictureURL: pictureEmoji,
            itemReceivedDate: receivedDate,
            status: .keep,  // Default to keep
            lastUsed: Date(), // Default to today
            itemType: selectedType
        )
        
        itemsManager.addItem(newItem)
        dismiss()
    }
}

struct AddOwnedItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddOwnedItemView()
            .environmentObject(ItemsManager())
    }
}
