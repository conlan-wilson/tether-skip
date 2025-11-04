import SwiftUI

enum ContentTab: String, Hashable { case beacons, send, settings, home }

struct ContentView: View {
    @Environment(AppModel.self) var model: AppModel
    @AppStorage("appearance") var appearance = ""

    var body: some View {
        HomeView()

//        TabView {
//            NavigationStack {
//                HomeView()
//                    .navigationTitle("Home")
//            }
//            .tabItem { Label("Home", systemImage: "house.fill") }
//            NavigationStack {
//                BeaconListView()
//                    .navigationTitle("Beacons")
//            }
//            .tabItem { Label("Beacons", systemImage: "antenna.radiowaves.left.and.right") }
//
//            NavigationStack {
//                SendBeaconView()
//                    .navigationTitle("Send")
//            }
//            .tabItem { Label("Send", systemImage: "paperplane.fill") }
//
//            NavigationStack {
//                SettingsView(appearance: $appearance)
//                    .navigationTitle("Settings")
//            }
//            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
//        }
    }
}
