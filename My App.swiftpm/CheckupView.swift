import SwiftUI

// View allow starting checkups and changing checkup intervals
struct CheckupView: View {
    @State var checkupActive = true
    @EnvironmentObject var itemsManager: ItemsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            
                Text("Checkup")
                    .font(.title)
                    .bold()
                    .padding(.leading, 16)
            
            List {
                Section("Items Checkup") {
                    NavigationLink("Item Checkup - __Keep__") {
                        KeepView(checkupActive: checkupActive)
                    }
                    
                    NavigationLink("Item Checkup - __Give__") {
                        GiveView(checkupActive: checkupActive)
                    }
                }
                
                Section("Configurations") {
                    NavigationLink("Change Checkup Interval - __Keep__") {
                        KeepIntervalView(dismiss: dismiss)
                    }
                    
                    NavigationLink("Change Checkup Interval - __Give__ ") {
                        GiveIntervalView(dismiss: dismiss)
                        
                    }
                }
            }
        }
    }
}

// Changes interval of keep checkup
struct KeepIntervalView: View {
    @EnvironmentObject var itemsManager: ItemsManager
    var dismiss: DismissAction
    
    var monthText: String {
        itemsManager.getKeepCheckupInterval <= 1 ? "month" : "months"
    }
    
    // calculates next checkup given user's desired checkup interval
    var nextCheckupDate: String {
        let lastDate = itemsManager.getLastKeepCheckup
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .month, value: itemsManager.getKeepCheckupInterval, to: lastDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: nextDate)
        }
        return "Unknown"
    }
    
    var body: some View {
        Form {
            Section("Enter interval in months") {
                //increses or decreases interval by giving or taking a month - with bounds
                Stepper {
                    HStack {
                        Text("Interval:")
                        Text("\(itemsManager.getKeepCheckupInterval) \(monthText)")
                    }
                } onIncrement: {
                    let newValue = itemsManager.getKeepCheckupInterval + 1
                    if newValue >= 1 && newValue <= 12 {
                        itemsManager.changeKeepCheckupInterval(months: newValue)
                    }
                } onDecrement: {
                    let newValue = itemsManager.getKeepCheckupInterval - 1
                    if newValue >= 1 {
                        itemsManager.changeKeepCheckupInterval(months: newValue)
                    }
                }
            }
            
            Section {
                Text("Next checkup: \(nextCheckupDate)")
            }
        }
    }
}

// Changes interval of give checkup
struct GiveIntervalView: View {
    @EnvironmentObject var itemsManager: ItemsManager
    var dismiss: DismissAction
    
    var monthText: String {
        itemsManager.getGiveCheckupInterval <= 1 ? "month" : "months"
    }
    
    //same calclucation of next keep checkup
    var nextCheckupDate: String {
        let lastDate = itemsManager.getLastGiveCheckup
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .month, value: itemsManager.getGiveCheckupInterval, to: lastDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: nextDate)
        }
        return "Unknown"
    }
    
    var body: some View {
        Form {
            Section("Enter interval in months") {
                //same stepper functionality as keep - see keep docs
                Stepper {
                    HStack {
                        Text("Interval:")
                        Text("\(itemsManager.getGiveCheckupInterval) \(monthText)")
                    }
                } onIncrement: {
                    let newValue = itemsManager.getGiveCheckupInterval + 1
                    if newValue >= 1 && newValue <= 12 {
                        itemsManager.changeGiveCheckupInterval(months: newValue)
                    }
                } onDecrement: {
                    let newValue = itemsManager.getGiveCheckupInterval - 1
                    if newValue >= 1 {
                        itemsManager.changeGiveCheckupInterval(months: newValue)
                    }
                }
            }
            
            Section {
                Text("Next checkup: \(nextCheckupDate)")
            }
        }
    }
}
