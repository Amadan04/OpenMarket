import SwiftUI
import MapKit

struct SavedLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddSheet = false
    @State private var editingLocation: SavedLocation? = nil

    @AppStorage("saved_locations") private var locationsData: String = ""

    private var locations: [SavedLocation] {
        (try? JSONDecoder().decode([SavedLocation].self, from: Data(locationsData.utf8))) ?? defaultLocations
    }

    private let defaultLocations: [SavedLocation] = [
        SavedLocation(id: 1, name: "Home", address: "123 Main St, Manama", latitude: 26.2235, longitude: 50.5876),
        SavedLocation(id: 2, name: "Work", address: "456 Office Blvd, Riffa", latitude: 26.1299, longitude: 50.5550),
    ]

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACCOUNT").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Saved locations").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(spacing: Spacing.m) {
                        ForEach(locations) { loc in
                            Button { editingLocation = loc } label: {
                                HStack(spacing: Spacing.m) {
                                    Image(systemName: loc.name.lowercased() == "home" ? "house.fill" : "briefcase.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.omAccent)
                                        .frame(width: 40, height: 40)
                                        .background(Color.omAccentSoft)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(loc.name).font(.omBodyMed).foregroundStyle(Color.omText)
                                        Text(loc.address).font(.omCaption).foregroundStyle(Color.omTextMuted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.omTextSubtle)
                                }
                                .padding(Spacing.l)
                                .background(Color.omBgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }

                        Button { showAddSheet = true } label: {
                            HStack(spacing: Spacing.m) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.omAccent)
                                Text("Add a location")
                                    .font(.inter(15, weight: .semibold))
                                    .foregroundStyle(Color.omAccent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.l)
                            .background(Color.omAccentSoft)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddSheet) {
            EditLocationSheet(existing: nil) { newLoc in
                var updated = locations
                updated.append(newLoc)
                saveLocations(updated)
            }
        }
        .sheet(item: $editingLocation) { loc in
            EditLocationSheet(existing: loc) { updated in
                var all = locations
                if let idx = all.firstIndex(where: { $0.id == loc.id }) {
                    all[idx] = updated
                }
                saveLocations(all)
            } onDelete: {
                saveLocations(locations.filter { $0.id != loc.id })
            }
        }
    }

    private func saveLocations(_ locs: [SavedLocation]) {
        locationsData = String(data: (try? JSONEncoder().encode(locs)) ?? Data(), encoding: .utf8) ?? ""
    }
}

struct SavedLocation: Codable, Identifiable {
    let id: Int
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
}

private struct EditLocationSheet: View {
    let existing: SavedLocation?
    var onSave: (SavedLocation) -> Void
    var onDelete: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var address: String

    init(existing: SavedLocation?, onSave: @escaping (SavedLocation) -> Void, onDelete: (() -> Void)? = nil) {
        self.existing = existing
        self.onSave = onSave
        self.onDelete = onDelete
        _name    = State(initialValue: existing?.name ?? "")
        _address = State(initialValue: existing?.address ?? "")
    }

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5).padding(.top, Spacing.m)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText).frame(width: 32, height: 32)
                            .background(Color.omBgSunken).clipShape(Circle())
                    }
                    Spacer()
                    Text(existing == nil ? "Add location" : "Edit location")
                        .font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        OMField(label: "Label (e.g. Home, Work)", text: $name)
                        OMField(label: "Address", text: $address)

                        if let onDelete {
                            Button {
                                onDelete()
                                dismiss()
                            } label: {
                                Text("Remove this location")
                                    .font(.inter(14, weight: .semibold))
                                    .foregroundStyle(Color.omDanger)
                                    .frame(maxWidth: .infinity)
                                    .padding(Spacing.m)
                                    .background(Color.omDanger.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                    .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omDanger.opacity(0.2), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.l)
                    .padding(.bottom, Spacing.xl)
                }

                VStack {
                    OMButton(label: "Save location", size: .lg, fullWidth: true, icon: "mappin.circle.fill") {
                        let loc = SavedLocation(
                            id: existing?.id ?? Int(Date().timeIntervalSince1970),
                            name: name.trimmingCharacters(in: .whitespaces),
                            address: address.trimmingCharacters(in: .whitespaces),
                            latitude: existing?.latitude ?? 26.2235,
                            longitude: existing?.longitude ?? 50.5577
                        )
                        onSave(loc)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || address.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
            }
        }
        .presentationDetents([.medium])
    }
}
