import SwiftUI

struct HomeView: View {
    @State private var apps = GateStore.apps
    @State private var showingAdd = false
    @AppStorage(GateStore.breathsKey) private var breaths = 3
    @AppStorage(GateStore.graceKey) private var graceMinutes = 10
    @AppStorage(GateStore.skippedKey) private var skipped = 0

    var body: some View {
        NavigationStack {
            List {
                if skipped > 0 {
                    Section {
                        Label("You walked away \(skipped) time\(skipped == 1 ? "" : "s")", systemImage: "leaf")
                    }
                }

                Section {
                    ForEach(apps) { app in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(app.name)
                                Text(app.urlScheme).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Try") { Router.shared.pending = app }
                                .buttonStyle(.bordered)
                        }
                    }
                    .onDelete { apps.remove(atOffsets: $0) }

                    Button("Add app", systemImage: "plus") { showingAdd = true }
                } header: {
                    Text("Apps")
                }

                Section("Settings") {
                    Stepper("Breaths: \(breaths)", value: $breaths, in: 1...10)
                    Stepper("Free pass after: \(graceMinutes) min", value: $graceMinutes, in: 1...60)
                }

                Section("Setup (once per app)") {
                    Text("""
                    1. Open the Shortcuts app and tap Automation.
                    2. Tap + and choose App.
                    3. Pick the app (e.g. Instagram), check "Is Opened", and select "Run Immediately". Tap Next.
                    4. Tap "New Blank Automation", then "Add Action".
                    5. Search for "Breathe Before Opening" and add it.
                    6. Tap "App" in the action and pick the same app from this list.
                    """)
                    .font(.callout)
                }
            }
            .navigationTitle("One Second")
            .sheet(isPresented: $showingAdd) {
                AddAppView { apps.append($0) }
            }
            .onChange(of: apps) { _, newValue in
                GateStore.apps = newValue
            }
        }
    }
}

struct AddAppView: View {
    var onAdd: (GatedApp) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var scheme = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Common apps") {
                    ForEach(GateStore.presets, id: \.name) { preset in
                        Button(preset.name) {
                            onAdd(GatedApp(name: preset.name, urlScheme: preset.urlScheme))
                            dismiss()
                        }
                    }
                }
                Section {
                    TextField("Name", text: $name)
                    TextField("URL scheme, e.g. instagram://", text: $scheme)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    Button("Add") {
                        onAdd(GatedApp(name: name, urlScheme: scheme))
                        dismiss()
                    }
                    .disabled(name.isEmpty || scheme.isEmpty)
                } header: {
                    Text("Other app")
                } footer: {
                    Text("The URL scheme is used to send you back to the app after breathing.")
                }
            }
            .navigationTitle("Add App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
