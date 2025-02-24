// Main view directory
import SwiftUI

// View for all main pages and onboarding 
struct ContentView: View {
    // checkup status is on at user set intervals but not at first app launch, if true,  shows slight variations in the view for Keep and Give view. 
    @State var checkupStatus = false
    @State var hasCompletedOnboarding = false
    @StateObject var manger = ItemsManager()
    
    var body: some View {
        // Show onboarding if haven't already
        if(!hasCompletedOnboarding) {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            //Main 3 sections of app to be visible at all times after onboarding
            //pass manger to give pages dummy data
            TabView {
                KeepView(checkupActive: checkupStatus)
                    .tabItem {
                        Label("Keep", systemImage: "arrow.down")
                    }
                    .environmentObject(manger)  
                
                GiveView(checkupActive: checkupStatus)
                    .tabItem{
                        Label("Give", systemImage: "arrow.up")
                    }
                    .environmentObject(manger)  
                DonatedView()
                    .tabItem{
                        Label("Donated", systemImage: "gift")
                    }
                    .environmentObject(manger)  
            }
            // for testing pre set data
            // Fixed - needed action closure around it 
            .onAppear {
                manger.loadDummyData()
            }
        }
    }
}
