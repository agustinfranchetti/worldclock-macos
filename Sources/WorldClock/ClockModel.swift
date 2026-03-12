import Foundation
import Combine

struct WorldClock: Identifiable, Codable, Sendable {
    var id: UUID
    var timeZoneIdentifier: String
    var displayName: String

    init(id: UUID = UUID(), timeZoneIdentifier: String, displayName: String) {
        self.id = id
        self.timeZoneIdentifier = timeZoneIdentifier
        self.displayName = displayName
    }

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    var shortName: String {
        let words = displayName.split(separator: " ")
        if words.count >= 2 {
            return words.prefix(3).map { String($0.prefix(1)).uppercased() }.joined()
        }
        return String(displayName.prefix(3)).uppercased()
    }
}

@MainActor
class ClockModel: ObservableObject {
    @Published var clocks: [WorldClock] {
        didSet { save() }
    }
    @Published var currentTime = Date()

    private var timerCancellable: AnyCancellable?
    private let timeFormatter = DateFormatter()

    init() {
        timeFormatter.dateFormat = "HH:mm"

        if let data = UserDefaults.standard.data(forKey: "savedClocks"),
           let saved = try? JSONDecoder().decode([WorldClock].self, from: data) {
            self.clocks = saved
        } else {
            self.clocks = Self.defaultClocks()
        }

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.currentTime = date
            }
    }

    static func defaultClocks() -> [WorldClock] {
        let localId = TimeZone.current.identifier
        let localCity = localId.split(separator: "/").last
            .map { String($0).replacingOccurrences(of: "_", with: " ") } ?? "Local"

        return [
            WorldClock(timeZoneIdentifier: localId, displayName: localCity),
            WorldClock(timeZoneIdentifier: "America/New_York", displayName: "New York"),
            WorldClock(timeZoneIdentifier: "Europe/London", displayName: "London"),
        ]
    }

    func formattedTime(for clock: WorldClock) -> String {
        timeFormatter.timeZone = clock.timeZone
        return timeFormatter.string(from: currentTime)
    }

    var menuBarText: String {
        clocks.map { "\($0.shortName) \(formattedTime(for: $0))" }
            .joined(separator: "  ·  ")
    }

    var headerDateText: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: currentTime)
    }

    func save() {
        if let data = try? JSONEncoder().encode(clocks) {
            UserDefaults.standard.set(data, forKey: "savedClocks")
        }
    }

    func addClock(_ clock: WorldClock) {
        guard clocks.count < 6 else { return }
        clocks.append(clock)
    }

    func removeClock(at offsets: IndexSet) {
        clocks.remove(atOffsets: offsets)
    }

    func moveClock(from source: IndexSet, to destination: Int) {
        clocks.move(fromOffsets: source, toOffset: destination)
    }
}
