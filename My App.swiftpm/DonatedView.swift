import SwiftUI

// shows items marked as donated from the give checkup 
struct DonatedView: View {
    @State var dynamicTitle = "Donated"
    @EnvironmentObject var itemsManager: ItemsManager
    @State private var selectedType: ItemType?
    @State private var checkupActive = false

    // only shows Owned item with item type "donated"
    // all donated items viewed by default
    var filteredItems: [OwnedItem] {
        guard let type = selectedType else {
            return itemsManager.getDonatedItems()
        }
        return itemsManager.getDonatedItems().filter { $0.itemType == type }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PageHeaderView(pageTitle: $dynamicTitle, checkupActive: $checkupActive)
                
                FilterView(selectedType: $selectedType)
                    .padding(.vertical)
                
                List {
                    ForEach(filteredItems) { item in
                        ItemCardView(
                            name: item.name,
                            picture: item.pictureURL,
                            category: item.itemType,
                            ownedLength: item.ownershipDuration,
                            lastUsedLength: item.lastUsedDuration,
                            itemStatus: item.status
                        )
                        .padding(.vertical, 3)
                        
                    }
                    .onDelete(perform: deleteItems)
                    
                }
                .listStyle(.plain)
                
                
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        itemsManager.deleteItems(at: offsets, from: filteredItems)
    }
}
