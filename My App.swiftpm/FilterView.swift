import SwiftUI

// Enables filtering by item type 
struct FilterView: View {
    @Binding var selectedType: ItemType?
    
    var body: some View {
        
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ItemType.allCases) { type in
                        
                        FilterButton(
                            title: type.rawValue,
                            //no filters selected by default
                            isSelected: selectedType == type,
                            action: {
                                // Toggle selection
                                if selectedType == type {
                                    selectedType = nil  // Deselect if already selected
                                } else {
                                    selectedType = type // Select new type
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
        
    
            
        }
    
}

// allows selection behvaior to filter
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        // highlights selected filter with apps default highlighting color teal, and maintains apps default text color of white if not selected
        // decided against maintaining app button color of teal as it underpowers the color if used here
        Button(action: action) {
            Text(title)
                .foregroundStyle(isSelected ? Color.teal : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        
        
        
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(selectedType: .constant(nil))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
