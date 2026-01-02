//
//  CalendarView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoolEntry.timestamp, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<StoolEntry>
    
    @Binding var selectedTab: Int
    @State private var selectedDate = Date()
    @State private var showAddEntry = false
    
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
                    VStack(spacing: 16) {
                        MonthCalendarView(selectedDate: $selectedDate, entries: entries, showAddEntry: $showAddEntry)
                        
                        // Stool color distribution
                        StoolColorChart(entries: entries)
                            .padding(.horizontal)
                        
                        // Entries list for selected day
                        DayEntriesList(selectedDate: selectedDate, entries: entries)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitleCompat("Calendar")
            .modifier(ToolbarModifier(showAddEntry: $showAddEntry))
            .sheet(isPresented: $showAddEntry) {
                QuickEntryView(selectedTab: $selectedTab, initialDate: selectedDate)
            }
        }
        .modifier(NavigationViewStyleModifier())
    }
}

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let entries: FetchedResults<StoolEntry>
    @Binding var showAddEntry: Bool
    
    @State private var currentMonth = Date()
    
    private var iOS14OrLater: Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.darkAccentColor)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth).capitalized)
                    .font(.title2Compat)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.darkAccentColor)
                }
            }
            .padding(.horizontal)
            
            // Days of week
            HStack {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            Group {
                if #available(iOS 14.0, *) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                DayCell(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    bristolType: getBristolType(for: date),
                                    stoolColor: getStoolColor(for: date),
                                    isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                )
                                .onTapGesture {
                                    selectedDate = date
                                    showAddEntry = true
                                }
                            } else {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        ForEach(0..<(daysInMonth.count / 7 + (daysInMonth.count % 7 > 0 ? 1 : 0)), id: \.self) { weekIndex in
                            HStack(spacing: 8) {
                                ForEach(0..<7, id: \.self) { dayIndex in
                                    let index = weekIndex * 7 + dayIndex
                                    if index < daysInMonth.count, let date = daysInMonth[index] {
                                        DayCell(
                                            date: date,
                                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                            bristolType: getBristolType(for: date),
                                            stoolColor: getStoolColor(for: date),
                                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                        )
                                        .onTapGesture {
                                            selectedDate = date
                                            showAddEntry = true
                                        }
                                    } else {
                                        Color.clear
                                            .frame(height: 44)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.6))
        .cornerRadius(16)
        .padding()
    }
    
    private var daysInMonth: [Date?] {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = (firstWeekday + 5) % 7 // Monday = 0
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        var currentDate = firstDay
        while calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: date)
        }
    }
    
    private func getBristolType(for date: Date) -> Int16? {
        // Get last entry for the day (most recent)
        let dayEntries = entries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: date)
        }
        
        // Return type from last entry (first in sorted list, as sorted descending)
        if let lastEntry = dayEntries.first, lastEntry.bristolType > 0 {
            return lastEntry.bristolType
        }
        return nil
    }
    
    private func getStoolColor(for date: Date) -> String? {
        // Get last entry for the day (most recent)
        let dayEntries = entries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: date)
        }
        
        // Return color from last entry
        if let lastEntry = dayEntries.first, let color = lastEntry.color, !color.isEmpty {
            return color
        }
        return nil
    }
    
    private func changeMonth(_ direction: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: direction, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let bristolType: Int16?
    let stoolColor: String?
    let isCurrentMonth: Bool
    
    private let calendar = Calendar.current
    
    // Color mapping to actual colors (supports both English and Russian for backward compatibility)
    private func colorForStool(_ colorName: String?) -> Color {
        guard let colorName = colorName else { return .clear }
        
        switch colorName.lowercased() {
        case "brown", "dark brown", "коричневый", "тёмно-коричневый", "темно-коричневый":
            return Color(red: 0.4, green: 0.2, blue: 0.1)
        case "light brown", "светло-коричневый":
            return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "yellow", "жёлтый", "желтый":
            return Color.yellow
        case "green", "зелёный", "зеленый":
            return Color.green
        case "black", "чёрный", "черный":
            return Color.black
        case "red", "красный":
            return Color.red
        default:
            return Color(red: 0.4, green: 0.2, blue: 0.1) // brown by default
        }
    }
    
    // Translate color name to English for display
    private func translateColorName(_ colorName: String?) -> String {
        guard let colorName = colorName else { return "" }
        
        switch colorName.lowercased() {
        case "коричневый", "brown":
            return "Brown"
        case "тёмно-коричневый", "темно-коричневый", "dark brown":
            return "Dark brown"
        case "светло-коричневый", "light brown":
            return "Light brown"
        case "жёлтый", "желтый", "yellow":
            return "Yellow"
        case "зелёный", "зеленый", "green":
            return "Green"
        case "чёрный", "черный", "black":
            return "Black"
        case "красный", "red":
            return "Red"
        default:
            return colorName.capitalized
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : (isCurrentMonth ? .primary : .secondary))
            
            if let type = bristolType, type > 0 {
                ZStack {
                    // Colored circle
                    if let color = stoolColor {
                        Circle()
                            .fill(colorForStool(color))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 1.5)
                            )
                    } else {
                        // If no color, show regular badge
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.3) : AppTheme.primaryColor.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                    
                    // Stool type number on top of circle
                    Text("\(type)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSelected ? .white : (stoolColor != nil ? .white : AppTheme.darkAccentColor))
                }
            }
        }
        .frame(width: 44, height: 50)
        .background(isSelected ? AppTheme.darkAccentColor : Color.clear)
        .cornerRadius(8)
        .opacity(isCurrentMonth ? 1.0 : 0.4)
    }
}

struct DayEntriesList: View {
    @Environment(\.managedObjectContext) private var viewContext
    let selectedDate: Date
    let entries: FetchedResults<StoolEntry>
    
    private let calendar = Calendar.current
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .short
        return formatter
    }()
    
    var dayEntries: [StoolEntry] {
        entries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Entries for \(dayText)")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            if dayEntries.isEmpty {
                Text("No entries for this day")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    ForEach(dayEntries) { entry in
                        EntryRow(entry: entry, onDelete: {
                            deleteEntry(entry)
                        })
                    }
                }
            }
        }
        .background(Color.white.opacity(0.6))
        .cornerRadius(16)
        .padding()
    }
    
    private func deleteEntry(_ entry: StoolEntry) {
        withAnimation {
            viewContext.delete(entry)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Delete error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private var dayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: selectedDate)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
}

struct EntryRow: View {
    let entry: StoolEntry
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Translate color name to English for display
    private func translateColorName(_ colorName: String) -> String {
        switch colorName.lowercased() {
        case "коричневый", "brown":
            return "Brown"
        case "тёмно-коричневый", "темно-коричневый", "dark brown":
            return "Dark brown"
        case "светло-коричневый", "light brown":
            return "Light brown"
        case "жёлтый", "желтый", "yellow":
            return "Yellow"
        case "зелёный", "зеленый", "green":
            return "Green"
        case "чёрный", "черный", "black":
            return "Black"
        case "красный", "red":
            return "Red"
        default:
            return colorName.capitalized
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                if let timestamp = entry.timestamp {
                    Text(timeFormatter.string(from: timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                if entry.bristolType > 0 {
                    Text("Type \(entry.bristolType)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryColor.opacity(0.3))
                        .cornerRadius(8)
                }
                
                    if let color = entry.color {
                        Text(translateColorName(color))
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.primaryColor.opacity(0.3))
                            .cornerRadius(8)
                    }
            }
            
            HStack {
                if entry.hasPain {
                    if #available(iOS 14.0, *) {
                        Label("Pain", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Pain")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                }
                if entry.hasBlood {
                    if #available(iOS 14.0, *) {
                        Label("Blood", systemImage: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                            Text("Blood")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
                if entry.hasMucus {
                    if #available(iOS 14.0, *) {
                        Label("Mucus", systemImage: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                            Text("Mucus")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
                
                if let comment = entry.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .alert(item: Binding<AlertItem?>(
            get: { showDeleteConfirmation ? AlertItem() : nil },
            set: { _ in showDeleteConfirmation = false }
        )) { _ in
            Alert(
                title: Text("Delete entry?"),
                message: Text("This action cannot be undone"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

// Toolbar modifier for iOS 13/14 compatibility
struct ToolbarModifier: ViewModifier {
    @Binding var showAddEntry: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddEntry = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.darkAccentColor)
                                .font(.title2Compat)
                        }
                    }
                }
        } else {
            content
                .navigationBarItems(trailing:
                    Button(action: {
                        showAddEntry = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.darkAccentColor)
                            .font(.title2Compat)
                    }
                )
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(0))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

