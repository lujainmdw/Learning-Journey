import WidgetKit
import SwiftUI

struct LogWidgetEntryView: View {
    @Environment(ThemeViewModel.self) var themeVM
    let vm: LogWidgetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: vm.statusIcon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(vm.statusColor)
                Spacer()
                Text(vm.statusBadge)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(vm.statusColor.opacity(0.2))
                    .foregroundStyle(vm.statusColor)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.learnedDaysText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                Text(vm.freezedSummaryText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            // Read-Only Status Pill
            Text(vm.statusLabel)
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(vm.isLearned ? themeVM.primaryColor.opacity(0.25) : themeVM.primaryColor)
                .foregroundStyle(vm.isLearned ? themeVM.primaryColor : .black)
                .clipShape(Capsule())
                .glassEffect(
                    .regular
                    .tint(themeVM.primaryColor),
                    in: .capsule)
        }
        .containerBackground(Color.black, for: .widget)
    }
}

struct LogWidget: Widget {
    let kind: String = "LogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LogWidgetEntryView(vm: LogWidgetViewModel(entry: entry))
                .environment(ThemeViewModel.shared)
        }
        .configurationDisplayName("Learning Journey")
        .description("View your daily learning streak and status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    LogWidget()
} timeline: {
    LearningEntry(date: .now, learnedDays: 3, freezedDays: 0, todayStatus: "none")
    LearningEntry(date: .now, learnedDays: 4, freezedDays: 0, todayStatus: "learned")
}
