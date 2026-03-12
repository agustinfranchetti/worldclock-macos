import SwiftUI

struct TimezoneRowView: View {
    @EnvironmentObject var model: ClockModel
    let clock: WorldClock
    @Binding var hoverDate: Date?

    private var displayDate: Date { hoverDate ?? model.currentTime }

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = clock.timeZone
        return f.string(from: displayDate)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        f.timeZone = clock.timeZone
        return f.string(from: displayDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(clock.displayName.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    Text(dateString)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .contentTransition(.numericText())
                }

                Spacer()

                Text(timeString)
                    .font(.system(size: 28, weight: .thin, design: .monospaced))
                    .foregroundStyle(hoverDate != nil ? .secondary : .primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.1), value: timeString)
            }

            TimelineBarView(
                timezone: clock.timeZone,
                currentTime: model.currentTime,
                hoverDate: $hoverDate
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        // Overlay covers the whole row — much easier hover target than just the 14pt bar
        .overlay(
            MouseTrackingView(
                onMove: { fraction in
                    var cal = Calendar.current
                    cal.timeZone = clock.timeZone
                    let startOfDay = cal.startOfDay(for: model.currentTime)
                    hoverDate = startOfDay.addingTimeInterval(Double(fraction) * 86400)
                },
                onExit: {
                    hoverDate = nil
                }
            )
        )
    }
}
