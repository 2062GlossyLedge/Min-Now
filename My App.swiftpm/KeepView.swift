import SwiftUI

// Shows owned items marked as keep for item status. All owned items entered into this app starts on this page
struct KeepView: View {
    @State var dynamicTitle = "Keep"
    @EnvironmentObject var itemsManager: ItemsManager
    @State private var selectedType: ItemType?
    @State var checkupActive = false
    
    
    // show only keep for item status. further filter based on item type
    var filteredItems: [OwnedItem] {
        guard let type = selectedType else {
            return itemsManager.getKeptItems()
        }
        return itemsManager.getKeptItems().filter { $0.itemType == type }
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
                        //additional swiping action when in checkup view. keeps delete gesture
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            if checkupActive {
                                Button {
                                    itemsManager.updateItemStatus(id: item.id, to: .give)
                                } label: {
                                    Text("Unused")
                                }
                            
                                .tint(.blue)
                                
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                   
                }
                 .listStyle(.plain)
                
                //To submit item checkup. 
                //TODO: warn before leaving page if not submitted and actions have been made
                if checkupActive {
                    Button(action: {
                        itemsManager.completeKeepCheckup()
                        checkupActive = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit Checkup")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        itemsManager.deleteItems(at: offsets, from: filteredItems)
    }
}
