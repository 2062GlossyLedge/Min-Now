import SwiftUI

// Top structure in heirarchachal strucutre of 3 main views of app to display purpose of page clearly 
struct PageHeaderView: View {
    @Binding var pageTitle: String
    @Binding var checkupActive: Bool
  
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // dynamically changes page title based on in checkup or not
                Text(checkupActive ? "Item Checkup - " + pageTitle: pageTitle)
                    .font(.title)
                    .bold()
                
                Spacer()
                
                // To signify adding new owned items
                // only on keep view to clarify all added items start in the keep view
                if(pageTitle == "Keep" && !checkupActive){
                    NavigationLink {
                        AddOwnedItemView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                // Shows checkup view navigator in two pages that can morph into checkup view
                if((pageTitle == "Keep" || pageTitle == "Give") && (!checkupActive)) {
                    NavigationLink {
                        CheckupView()
                    } label: {
                        BadgedCalendarIcon(pageTitle: $pageTitle)
                    }
                }
                
                // To hold extra info on app
                // need to establish branding on this section
                // first attempt was to change info icon with logo but this made it unclear if it was a button
                    NavigationLink {
                        SettingsView()
                    } label: {
//                        Image("Logo7")
//                            .resizable()
//                            .frame(maxWidth:20, maxHeight: 20)
//                            .clipShape(Circle())
                        Image(systemName: "info.circle")
                    }
                
            }
        }
        .padding()
    }
}
