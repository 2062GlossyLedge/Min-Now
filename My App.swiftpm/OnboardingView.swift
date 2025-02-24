import SwiftUI

// credit for giving ideas to implement onboarding feature:
// https://medium.com/@kebojok768/create-beautiful-sliding-onboarding-flow-in-swiftui-using-pagetabviewstyle-02c6292c30c4

// Model for onboarding slides
struct OnboardingSlide: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let headline: String
}

// UserDefaults key for onboarding status
// User default enables global view of this var's state
private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

// Represents gallery slides and their content 
class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    let slides = [
        OnboardingSlide(image: "Logo", 
                        title: "Min-Now", 
                        headline: "Live minimally by knowing what belongings you do and do not use"),
        OnboardingSlide(image: "arrow.down", 
                        title: "Keep", 
                        headline: "Add your owned items to this section. Items you use often should stay here"),
        OnboardingSlide(image: "calendar", 
                        title: "Item Checkup - Keep", 
                        headline: "Review your owned items here each month. Swipe left on the items you haven't used"),
        OnboardingSlide(image: "arrow.up", 
                        title: "Give", 
                        headline: "Unused items from the item checkup will be here"),
        OnboardingSlide(image: "calendar", 
                        title: "Item Checkup - Give", 
                        headline: "Review your unused items here each month. Swipe left on on items you have used or donated"),
        OnboardingSlide(image: "gift", 
                        title: "Donated", 
                        headline: "The items you donated will be here"),
    ]
    
    //to use after onboarding is done
    // onboarding info after this gallery closed can still be found - see SettingsView
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
    }
}

// Encapsulates navigating onboarding and the logic behind it
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0, green: 0.5, blue: 0.5),
                    Color(red: 0, green: 0.7, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Page TabView
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.slides.count, id: \.self) { index in
                        SlideView(slide: viewModel.slides[index])
                    }
                }
                .tabViewStyle(.page)
                
                // Navigation buttons
                VStack(spacing: 20) {
                    Button(action: {
                        if viewModel.currentPage < viewModel.slides.count - 1 {
                            withAnimation {
                                viewModel.currentPage += 1
                            }
                        } else {
                            viewModel.completeOnboarding()
                            hasCompletedOnboarding = true
                        }
                    }) {
                        //Change button text to signal end of onboarding on last slide
                        Text(viewModel.currentPage < viewModel.slides.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    //skips thru onboarding slides
                    Button(action: {
                        viewModel.completeOnboarding()
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// Represents the view of a slide
struct SlideView: View {
    let slide: OnboardingSlide
    
    var body: some View {
        VStack(spacing: 20) {
            // Image section with fixed height
            ZStack {
                if(slide.image == "Logo") {
                    Image(slide.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                } else {
                    Image(systemName: slide.image)
                        .resizable()
                        .foregroundStyle(Color.black)
                        .frame(width: 130, height: 130)
                    //mimic item checkup icon being due
                    if(slide.image == "calendar") {
                        Circle()
                            .fill(.red)
                            .frame(width: 45, height: 45)
                            .offset(x: 47, y: -55)
                    }
                }
            }
            .padding()
            
            // Title with fixed height
            // Fixed - SF and asset with same frame dimensions resulted in text below it not at the same location
            Text(slide.title)
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .frame(height: 40) 
            
            // Headline with fixed height
            Text(slide.headline)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
                .frame(height: 60) 
                .minimumScaleFactor(0.8) // Allows text to scale down if needed
        }
    }
}

// Shows all content from onboarding, even after inital onboarding is completed. Compacted into a qucik digestable list
struct ReplayOnboarding: View {
    let viewModel = OnboardingViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.slides) { slide in
                HStack(spacing: 15) {
    
                    ZStack {
                        if slide.image == "Logo" {
                            Image(slide.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: slide.image)
                                .resizable()
                                .scaledToFit()
                            // not default icon colors because of lack of contrast with background
                                .foregroundStyle(Color.primary)
                                .frame(width: 50, height: 50)
                            
                            if slide.image == "calendar" {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 20, height: 20)
                                    .offset(x: 20, y: -20)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(slide.title)
                            .font(.headline)
                        
                        Text(slide.headline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Onboarding Notes")
    }
}
