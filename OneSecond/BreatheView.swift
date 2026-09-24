import SwiftUI

struct BreatheView: View {
    let app: GatedApp

    @Environment(\.openURL) private var openURL
    @State private var expanded = false
    @State private var breathsLeft = GateStore.breaths
    @State private var finished = false

    private let inhale = 4.0
    private let exhale = 6.0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.25))
                    .frame(width: 280, height: 280)
                Circle()
                    .fill(Color.teal.gradient)
                    .frame(width: 280, height: 280)
                    .scaleEffect(expanded ? 1 : 0.35)
                Text(finished ? "" : "\(breathsLeft)")
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.title2.weight(.medium))
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(.easeInOut, value: title)

            Spacer()

            if finished {
                Button {
                    GateStore.grantPass(for: app.id)
                    Router.shared.pending = nil
                    if let url = app.url { openURL(url) }
                } label: {
                    Text("Open \(app.name)").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Button {
                GateStore.recordSkip()
                Router.shared.pending = nil
            } label: {
                Text("I don't need it right now").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .controlSize(.large)
        }
        .padding(24)
        .task { await breathe() }
    }

    private var title: String {
        if finished { return "Do you still want to open \(app.name)?" }
        return expanded ? "Breathe in" : "Breathe out"
    }

    private func breathe() async {
        do {
            while breathsLeft > 0 {
                withAnimation(.easeInOut(duration: inhale)) { expanded = true }
                try await Task.sleep(for: .seconds(inhale))
                withAnimation(.easeInOut(duration: exhale)) { expanded = false }
                try await Task.sleep(for: .seconds(exhale))
                breathsLeft -= 1
            }
            withAnimation { finished = true }
        } catch {
            // View went away mid-session.
        }
    }
}
