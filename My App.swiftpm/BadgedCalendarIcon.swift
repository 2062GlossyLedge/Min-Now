import SwiftUI

// Represents calendar icon and its two states
struct BadgedCalendarIcon: View {
    @Binding var pageTitle: String
    @EnvironmentObject var itemsManager: ItemsManager
    
    var isCheckupDue: Bool {
        if pageTitle == "Keep" {
            return itemsManager.isKeepCheckupDue
        } else if pageTitle == "Give" {
            return itemsManager.isGiveCheckupDue
        }
        return false
    }
    
    
    var body: some View {
        ZStack {
            Image(systemName: "calendar")
            
            //Shows red badge on calendar icon if either keep or give checkup is due
            if isCheckupDue {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                    .offset(x: 8, y: -8)
            }
        }
    }
}
