import Foundation

/// An app the user wants to pause before opening.
struct GatedApp: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    /// URL scheme used to jump back into the app, e.g. "instagram://".
    var urlScheme: String

    var url: URL? {
        URL(string: urlScheme.contains("://") ? urlScheme : urlScheme + "://")
    }
}

/// Everything is stored locally in UserDefaults. Nothing leaves the phone.
enum GateStore {
    static let breathsKey = "breaths"
    static let graceKey = "graceMinutes"
    static let skippedKey = "skippedCount"

    private static let appsKey = "gatedApps"
    private static let passesKey = "passUntil"
    private static let defaults = UserDefaults.standard

    static let presets: [GatedApp] = [
        GatedApp(name: "Instagram", urlScheme: "instagram://"),
        GatedApp(name: "Facebook", urlScheme: "fb://"),
        GatedApp(name: "TikTok", urlScheme: "tiktok://"),
        GatedApp(name: "X", urlScheme: "twitter://"),
        GatedApp(name: "YouTube", urlScheme: "youtube://"),
        GatedApp(name: "Reddit", urlScheme: "reddit://"),
        GatedApp(name: "Snapchat", urlScheme: "snapchat://"),
        GatedApp(name: "Threads", urlScheme: "barcelona://"),
        GatedApp(name: "LinkedIn", urlScheme: "linkedin://"),
    ]

    static var apps: [GatedApp] {
        get {
            if let data = defaults.data(forKey: appsKey),
               let apps = try? JSONDecoder().decode([GatedApp].self, from: data) {
                return apps
            }
            // First launch: start with Instagram and Facebook, saved so their IDs stay stable.
            let seeded = Array(presets.prefix(2))
            self.apps = seeded
            return seeded
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: appsKey)
        }
    }

    static func app(withID id: UUID) -> GatedApp? {
        apps.first { $0.id == id }
    }

    static var breaths: Int { defaults.object(forKey: breathsKey) as? Int ?? 3 }
    static var graceMinutes: Int { defaults.object(forKey: graceKey) as? Int ?? 10 }

    /// True if the user already did the breathing for this app recently.
    static func hasPass(for id: UUID) -> Bool {
        let passes = defaults.dictionary(forKey: passesKey) as? [String: Double] ?? [:]
        return (passes[id.uuidString] ?? 0) > Date().timeIntervalSince1970
    }

    static func grantPass(for id: UUID) {
        var passes = defaults.dictionary(forKey: passesKey) as? [String: Double] ?? [:]
        passes[id.uuidString] = Date().addingTimeInterval(Double(graceMinutes) * 60).timeIntervalSince1970
        defaults.set(passes, forKey: passesKey)
    }

    static func recordSkip() {
        defaults.set(defaults.integer(forKey: skippedKey) + 1, forKey: skippedKey)
    }
}

/// Tells the UI which app is waiting behind a breathing session.
@MainActor
final class Router: ObservableObject {
    static let shared = Router()
    @Published var pending: GatedApp?
}
