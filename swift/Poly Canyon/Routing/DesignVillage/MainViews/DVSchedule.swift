import SwiftUI

struct DVSchedule: View {
    @State private var selectedDay = 0
    let days = ["Friday", "Saturday", "Sunday"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                daySelector
                
                scheduleContent
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 40)
        }
    }
    
    private var daySelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<days.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDay = index
                    }
                } label: {
                    Text(days[index])
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedDay == index ? 
                                         DVDesignSystem.Colors.text : 
                                         DVDesignSystem.Colors.textSecondary)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    VStack(spacing: 0) {
                        Spacer()
                        if selectedDay == index {
                            LinearGradient(
                                colors: [
                                    DVDesignSystem.Colors.orange,
                                    DVDesignSystem.Colors.teal
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(height: 3)
                            .transition(.opacity)
                        } else {
                            Color.clear.frame(height: 3)
                        }
                    }
                )
            }
        }
        .background(DVDesignSystem.Components.card())
        .cornerRadius(12)
    }
    
    private var scheduleContent: some View {
        VStack(spacing: 16) {
            if selectedDay == 0 {
                // Friday
                scheduleDay(title: "Friday Events", events: [
                    ScheduleEvent(time: "12:00 PM - 2:00 PM", title: "Registration", description: "Check-in at Design Village HQ"),
                    ScheduleEvent(time: "2:00 PM - 6:00 PM", title: "Structure Setup", description: "Build your structure at your assigned location"),
                    ScheduleEvent(time: "7:00 PM - 8:30 PM", title: "Opening Ceremony", description: "Welcome remarks and introductions")
                ])
            } else if selectedDay == 1 {
                // Saturday
                scheduleDay(title: "Saturday Events", events: [
                    ScheduleEvent(time: "8:00 AM - 9:00 AM", title: "Breakfast", description: "Light breakfast at Design Village HQ"),
                    ScheduleEvent(time: "10:00 AM - 12:00 PM", title: "Public Tours", description: "First round of public tours"),
                    ScheduleEvent(time: "12:00 PM - 1:30 PM", title: "Lunch", description: "Lunch break at Design Village HQ"),
                    ScheduleEvent(time: "2:00 PM - 4:00 PM", title: "Public Tours", description: "Second round of public tours"),
                    ScheduleEvent(time: "4:30 PM - 6:00 PM", title: "Design Talks", description: "Professional architects share insights"),
                    ScheduleEvent(time: "7:00 PM - 9:00 PM", title: "Evening Social", description: "Networking with other participants")
                ])
            } else {
                // Sunday
                scheduleDay(title: "Sunday Events", events: [
                    ScheduleEvent(time: "8:00 AM - 9:00 AM", title: "Breakfast", description: "Light breakfast at Design Village HQ"),
                    ScheduleEvent(time: "9:00 AM - 11:00 AM", title: "Judging", description: "Structures evaluated by jury"),
                    ScheduleEvent(time: "11:30 AM - 1:00 PM", title: "Awards Ceremony", description: "Recognition of top designs"),
                    ScheduleEvent(time: "1:00 PM - 3:00 PM", title: "Cleanup", description: "Dismantle structures and leave no trace")
                ])
            }
        }
    }
    
    private func scheduleDay(title: String, events: [ScheduleEvent]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DVTitleWithShadow(
                text: title,
                font: .system(size: 20, weight: .bold)
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            ForEach(events) { event in
                scheduleEventRow(event: event)
            }
            .padding(.bottom, 16)
        }
        .background(DVDesignSystem.Components.card())
    }
    
    private func scheduleEventRow(event: ScheduleEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text(event.time)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
                    .frame(width: 140, alignment: .leading)
                
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DVDesignSystem.Colors.text)
                
                Spacer()
            }
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.system(size: 14))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
                    .padding(.leading, 140)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Rectangle()
                .fill(DVDesignSystem.Colors.surface)
                .cornerRadius(8)
                .shadow(color: DVDesignSystem.Colors.shadowColor.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
    }
}

struct ScheduleEvent: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let description: String
}

struct DVSchedule_Previews: PreviewProvider {
    static var previews: some View {
        DVSchedule()
            .nexusStyle()
    }
}
