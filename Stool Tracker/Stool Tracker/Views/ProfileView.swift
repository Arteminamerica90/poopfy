//
//  ProfileView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import CoreData
import UserNotifications

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoolEntry.timestamp, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<StoolEntry>
    
    @State private var notificationsEnabled = true
    @State private var reminderTime = Date()
    
    private var iOS14OrLater: Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.gradientBackground
                    .ignoresSafeAreaCompat()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("General statistics")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(entries.count)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(AppTheme.darkAccentColor)
                                    Text("total entries")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if let firstEntry = entries.last?.timestamp {
                                    VStack(alignment: .trailing) {
                                        Text(daysSince(firstEntry))
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(AppTheme.darkAccentColor)
                                        Text("days tracking")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        
                        // Reminders
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminders")
                                .font(.headline)
                            
                            Toggle("Enable reminders", isOn: Binding(
                                get: { notificationsEnabled },
                                set: { newValue in
                                    notificationsEnabled = newValue
                                    if newValue {
                                        requestNotificationPermission()
                                        scheduleReminder()
                                    } else {
                                        cancelReminders()
                                    }
                                }
                            ))
                            
                            if notificationsEnabled {
                                DatePicker("Reminder time", selection: Binding(
                                    get: { reminderTime },
                                    set: { newValue in
                                        reminderTime = newValue
                                        scheduleReminder()
                                    }
                                ), displayedComponents: .hourAndMinute)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        
                        // About
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.headline)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("This app helps you track your bowel movements and maintain a healthy lifestyle.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .navigationTitleCompat("Profile")
        }
        .modifier(NavigationViewStyleModifier())
    }
    
    private func daysSince(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        return "\(days)"
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                scheduleReminder()
            }
        }
    }
    
    private func scheduleReminder() {
        guard notificationsEnabled else { return }
        
        cancelReminders()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Reminder", comment: "Notification title")
        content.body = NSLocalizedString("Haven't had a bowel movement in a while, record how you feel", comment: "Notification body")
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "stoolReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Reminder setup error: \(error)")
            }
        }
    }
    
    private func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["stoolReminder"])
    }
}

#Preview {
    ProfileView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

