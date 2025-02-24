import SwiftUI

// structured list view for all owned items agnostic of item status
struct ItemCardView: View {
    // Regular properties instead of bindings
    let name: String
    let picture: String
    let category: ItemType
    let ownedLength: TimeSpan
    let lastUsedLength: TimeSpan
    let itemStatus: ItemStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // emoji represntation of owned item
                Text(picture)
                
                //name of owned item
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                }
                Spacer()
            }
            // shows item owned duration for keep items to encourage taking care of these items. Shows item last used duration for give items to encourage donating these items.
            if (itemStatus.rawValue == "Keep") {
                VStack(alignment: .leading) {
                    Text("Ownership Duration: ")
                        .font(.caption)
                    // Progess bar more easily glancable but what would the bounds be?
                    //                ProgressView(value: 0.6)
                    //                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    Text(ownedLength.description)
                    
                }
            }
            if (itemStatus.rawValue == "Give"){
                VStack(alignment: .leading) {
                    Text("Last Used Duration: ")
                        .font(.caption)

                    Text(lastUsedLength.description)
                    
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 6.5)
    }
}

