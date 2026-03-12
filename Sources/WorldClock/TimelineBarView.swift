import SwiftUI

struct TimelineBarView: View {
    let timezone: TimeZone
    let currentTime: Date
    @Binding var hoverDate: Date?

    private var currentProgress: Double {
        var cal = Calendar.current
        cal.timeZone = timezone
        let h = cal.component(.hour, from: currentTime)
        let m = cal.component(.minute, from: currentTime)
        return (Double(h) * 60 + Double(m)) / (24 * 60)
    }

    private var hoverProgress: Double? {
        guard let date = hoverDate else { return nil }
        var cal = Calendar.current
        cal.timeZone = timezone
        let start = cal.startOfDay(for: date)
        let elapsed = date.timeIntervalSince(start)
        return max(0, min(1, elapsed / 86400))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(stops: dayGradient, startPoint: .leading, endPoint: .trailing)
                    .clipShape(RoundedRectangle(cornerRadius: 3))

                ForEach([6, 12, 18], id: \.self) { hour in
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1)
                        .offset(x: geo.size.width * (Double(hour) / 24.0))
                }

                // Hover line
                if let hp = hoverProgress {
                    let hx = geo.size.width * hp
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 2, height: 12)
                        .offset(x: max(0, min(geo.size.width - 2, hx - 1)))
                }

                // Current time glow
                let x = geo.size.width * currentProgress
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(hoverDate != nil ? 0.15 : 0.4))
                    .frame(width: 8, height: 12)
                    .blur(radius: 4)
                    .offset(x: max(0, x - 4))
                    .animation(.easeInOut(duration: 0.15), value: hoverDate != nil)

                // Current time tick
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(hoverDate != nil ? 0.35 : 1.0))
                    .frame(width: 2.5, height: 12)
                    .shadow(color: .white.opacity(0.9), radius: 3)
                    .offset(x: max(0, min(geo.size.width - 2.5, x - 1.25)))
                    .animation(.easeInOut(duration: 0.15), value: hoverDate != nil)
            }
        }
        .frame(height: 14)
    }

    private var dayGradient: [Gradient.Stop] {
        [
            .init(color: Color(red: 0.04, green: 0.05, blue: 0.18), location: 0),
            .init(color: Color(red: 0.05, green: 0.07, blue: 0.22), location: 0.15),
            .init(color: Color(red: 0.10, green: 0.08, blue: 0.28), location: 0.22),
            .init(color: Color(red: 0.72, green: 0.34, blue: 0.14), location: 0.27),
            .init(color: Color(red: 0.38, green: 0.63, blue: 0.88), location: 0.38),
            .init(color: Color(red: 0.26, green: 0.56, blue: 0.92), location: 0.50),
            .init(color: Color(red: 0.30, green: 0.60, blue: 0.86), location: 0.62),
            .init(color: Color(red: 0.78, green: 0.40, blue: 0.16), location: 0.75),
            .init(color: Color(red: 0.16, green: 0.10, blue: 0.30), location: 0.85),
            .init(color: Color(red: 0.04, green: 0.05, blue: 0.18), location: 1),
        ]
    }
}
