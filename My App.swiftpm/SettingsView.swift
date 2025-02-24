import SwiftUI

// Holds extra info about app and help section
// Keep settingsView as name to allow smooth transition to know where to add profile config in future updates
struct SettingsView: View {
    @State var hasCompletedOnboarding = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("Info")
                .font(.title)
                .padding(.leading, 16)
                .bold()
            
            List {
                Section("Help"){
                    // Quick list view of onboarding info
                    NavigationLink("Onboarding Notes"){
                        ReplayOnboarding()
                    }
                }
                // move to be more visible on donated page
                Section("Resources") {
                    NavigationLink("Find a Local Giving Center") {
                        VStack() {
                            Text("Find your nearest Salvation Army drop-off location:")
                                .font(.headline)
                                .padding(.top)
                                .multilineTextAlignment(.center)
                            
                            
                            // internet required feature but not critical to app function for student challenge
                            Button("Open Salvation Army Locator Website") {
                                if let url = URL(string: "https://www.satruck.org/dropoff") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                // About this app
                Section("About") {
                    NavigationLink("The Story Behind Min-Now") {
                        VStack() {
                            Text("The Story Behind Min-Now")
                                .font(.headline)
                                .padding(.bottom, 4)
                                .multilineTextAlignment(.center)
                            
                            Text("Min-Now was inspired by a simple yet effective decluttering experiment: Someone decided to place all their belongings in cardboard boxes. The rule was simple: if they needed an item, they would take it out, use it, and store it properly outside the boxes. After a month, anything that remained untouched in the boxes was donated.")
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.leading)
                            
                            Text("My hope is this app serves as your virtual 'cardboard box,' helping you embrace a more minimalist lifestyle by identifying items you can live without.")
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 8)
                            
                            Text("- Ayden Smith")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
