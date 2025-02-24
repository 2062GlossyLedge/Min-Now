import SwiftUI

// Give view shows all items marked as unused in keep item checkup
struct GiveView: View {
    @State var dynamicTitle = "Give"
    @EnvironmentObject var itemsManager: ItemsManager
    @State private var selectedType: ItemType?
    @State var checkupActive = false
    
    //filter to only show "give" items. Further filter by item type
    var filteredItems: [OwnedItem] {
        //guard from showing all give items when a type is selected in horzontal bar
        guard let type = selectedType else {
            return itemsManager.getGiveItems() // Show all kept items when no filter
        }
        return itemsManager.getGiveItems().filter { $0.itemType == type }
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
                        .padding(.vertical, 5)
                        // allows two more swipe actions during item checkup. maintains delete swipe from give view without checkup on
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            if checkupActive {
                                Button {
                                    itemsManager.updateItemStatus(id: item.id, to: .keep)
                                } label: {
                                    Text("Used")
                                }
                                .tint(.green)
                                Button {
                                    itemsManager
                                        .updateItemStatus(id: item.id, to: .donate)
                                } label: {
                                    Text("Donated")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    
                    // bugged the app preview
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                // marks as item checkup being completed
                // TODO: warn of not submitting checkup if page is left behind before submitting
                if checkupActive {
                    Button(action: {
                        itemsManager.completeGiveCheckup()
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
                        //match item card value
                        .cornerRadius(10)
                    }
                    .padding()
                    
                }
                
                
                
            }
        }
    }

    // delete items after swiping right gesture 
    func deleteItems(at offsets: IndexSet) {
        itemsManager.deleteItems(at: offsets, from: filteredItems)
        
    }
}


struct GiveView_Previews: PreviewProvider {
    static var previews: some View {
        GiveView()
    }
}
