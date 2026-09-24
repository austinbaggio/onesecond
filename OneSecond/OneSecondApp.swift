import SwiftUI

@main
struct OneSecondApp: App {
    @StateObject private var router = Router.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .fullScreenCover(item: $router.pending) { app in
                    BreatheView(app: app)
                }
        }
    }
}
