import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var model: ClockModel
    let onSettingsTap: () -> Void

    // Shared hover state — one absolute date drives all three bars
    @State private var hoverDate: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(model.headerDateText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.3)
                Spacer()
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13))
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            // Clock cards — all share the same hoverDate binding
            GlassEffectContainer(spacing: 8) {
                VStack(spacing: 8) {
                    ForEach(model.clocks) { clock in
                        TimezoneRowView(clock: clock, hoverDate: $hoverDate)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 12)

            // Footer
            HStack {
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .frame(width: 360)
    }
}
