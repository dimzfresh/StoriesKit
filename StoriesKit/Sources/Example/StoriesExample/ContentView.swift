import SwiftUI
import StoriesKit

struct ContentView: View {
    @StateObject private var dataModel = StoriesDataModel()
    @State private var selectedGroup: StoriesGroupModel?
    @Namespace private var avatarNamespace
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                    storiesCarouselView
                    randomImagesSection
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
        .overlay {
            if let selectedGroup {
                StoriesView(
                    selectedGroup: selectedGroup,
                    groups: dataModel.storiesGroups,
                    onClose: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            self.selectedGroup = nil
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 1.0)),
                    removal: .opacity.combined(with: .scale(scale: 1.0))
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedGroup)
            }
        }
    }
    
    private var headerView: some View {
        GradientHeaderView()
    }
    private var storiesCarouselView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "music.mic")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text("Artist Stories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(dataModel.storiesGroups.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal, 16)
            
            StoriesCarouselView(
                storiesGroups: dataModel.storiesGroups,
                avatarNamespace: avatarNamespace,
                onStoryGroupTap: { group in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedGroup = group
                    }
                }
            )
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    private var randomImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text("Featured Images")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dataModel.generateRandomImages()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Refresh")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 16)
            
            RandomImagesView(images: dataModel.randomImages)
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }
}
