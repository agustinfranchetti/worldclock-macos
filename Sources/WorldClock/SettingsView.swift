import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: ClockModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Configure Clocks")
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding()

            Divider()

            List {
                Section {
                    ForEach($model.clocks) { $clock in
                        ClockEditorRow(clock: $clock, onDelete: {
                            if let idx = model.clocks.firstIndex(where: { $0.id == clock.id }) {
                                model.removeClock(at: IndexSet(integer: idx))
                            }
                        })
                    }
                    .onMove { model.moveClock(from: $0, to: $1) }

                    if model.clocks.count < 6 {
                        AddClockRow()
                            .environmentObject(model)
                    }
                } header: {
                    Text("Up to 6 clocks · drag to reorder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.inset)
        }
        .frame(width: 400, height: 420)
    }
}

struct ClockEditorRow: View {
    @Binding var clock: WorldClock
    var onDelete: () -> Void
    @State private var showingPicker = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                TextField("City name", text: $clock.displayName)
                    .textFieldStyle(.roundedBorder)

                Button {
                    showingPicker = true
                } label: {
                    HStack {
                        Text(clock.timeZoneIdentifier.replacingOccurrences(of: "_", with: " "))
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingPicker) {
                    TimezonePickerSheet(selection: $clock.timeZoneIdentifier)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(.vertical, 4)
    }
}

struct TimezonePickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) var dismiss
    @State private var search = ""

    private var filtered: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers.sorted()
        guard !search.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Timezone")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            TextField("Search...", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    let tzList: [String] = filtered
                    ForEach(tzList, id: \.self) { tz in
                        Button {
                            selection = tz
                            dismiss()
                        } label: {
                            HStack {
                                Text(tz.replacingOccurrences(of: "_", with: " "))
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if tz == selection {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .frame(width: 360, height: 460)
    }
}

struct AddClockRow: View {
    @EnvironmentObject var model: ClockModel
    @State private var isAdding = false
    @State private var newName = ""
    @State private var newTzId = TimeZone.current.identifier
    @State private var showingPicker = false

    var body: some View {
        if isAdding {
            VStack(alignment: .leading, spacing: 8) {
                TextField("City name (optional)", text: $newName)
                    .textFieldStyle(.roundedBorder)

                Button {
                    showingPicker = true
                } label: {
                    HStack {
                        Text(newTzId.replacingOccurrences(of: "_", with: " "))
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingPicker) {
                    TimezonePickerSheet(selection: $newTzId)
                }

                HStack {
                    Button("Cancel") {
                        isAdding = false
                        newName = ""
                    }
                    .foregroundStyle(.secondary)
                    Spacer()
                    Button("Add") {
                        let name = newName.isEmpty
                            ? (newTzId.split(separator: "/").last.map { String($0).replacingOccurrences(of: "_", with: " ") } ?? newTzId)
                            : newName
                        model.addClock(WorldClock(timeZoneIdentifier: newTzId, displayName: name))
                        isAdding = false
                        newName = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.vertical, 4)
        } else {
            Button {
                isAdding = true
            } label: {
                Label("Add Clock", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}
