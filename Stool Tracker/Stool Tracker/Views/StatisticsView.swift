//
//  StatisticsView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoolEntry.timestamp, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<StoolEntry>
    
    @State private var period: StatPeriod = .month
    
    enum StatPeriod {
        case week, month, all
    }
    
    var filteredEntries: [StoolEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                return entries.filter { $0.timestamp ?? Date.distantPast >= weekAgo }
            }
        case .month:
            if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                return entries.filter { $0.timestamp ?? Date.distantPast >= monthAgo }
            }
        case .all:
            return Array(entries)
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.gradientBackground
                    .ignoresSafeAreaCompat()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period
                        Picker("Period", selection: $period) {
                            Text("Week").tag(StatPeriod.week)
                            Text("Month").tag(StatPeriod.month)
                            Text("All time").tag(StatPeriod.all)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        // Частота стула
                        FrequencyCard(entries: filteredEntries, period: period)
                        
                        // Распределение по типам
                        BristolTypeChart(entries: filteredEntries)
                        
                        // Распределение по цветам
                        StoolColorChartFromArray(entries: filteredEntries)
                        
                        // Среднее время суток
                        AverageTimeCard(entries: filteredEntries)
                        
                        // Запорные и частые дни
                        ConstipationDaysCard(entries: filteredEntries)
                    }
                    .padding()
                }
            }
            .navigationTitleCompat("Statistics")
        }
    }
}

struct FrequencyCard: View {
    let entries: [StoolEntry]
    let period: StatisticsView.StatPeriod
    
    var frequencyPerDay: Double {
        guard !entries.isEmpty else { return 0 }
        let days = daysCount
        return Double(entries.count) / Double(days)
    }
    
    var daysCount: Int {
        let calendar = Calendar.current
        
        guard !entries.isEmpty else { return 1 }
        
        // Get unique days with entries
        var daysWithEntries = Set<Date>()
        for entry in entries {
            if let timestamp = entry.timestamp {
                let day = calendar.startOfDay(for: timestamp)
                daysWithEntries.insert(day)
            }
        }
        
        // If there are days with entries, return their count
        if !daysWithEntries.isEmpty {
            return max(1, daysWithEntries.count)
        }
        
        // Fallback: count days between first and last entry
        if let first = entries.last?.timestamp,
           let last = entries.first?.timestamp {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: first), to: calendar.startOfDay(for: last)).day ?? 0
            return max(1, days + 1) // +1 to include both days
        }
        
        return 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stool frequency")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(String(format: "%.1f", frequencyPerDay))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.darkAccentColor)
                    Text("times per day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(entries.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.darkAccentColor)
                    Text("total entries")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct BristolTypeChart: View {
    let entries: [StoolEntry]
    
    var typeDistribution: [Int: Int] {
        var distribution: [Int: Int] = [:]
        for entry in entries {
            let type = Int(entry.bristolType)
            distribution[type, default: 0] += 1
        }
        return distribution
    }
    
    var chartData: [(type: Int, count: Int)] {
        typeDistribution.map { (type: $0.key, count: $0.value) }
            .sorted { $0.type < $1.type }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribution by stool types")
                .font(.headline)
            
            // Simple visualization without Charts framework
            VStack(alignment: .leading, spacing: 12) {
                ForEach(chartData, id: \.type) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Type \(item.type)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.darkAccentColor)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 24)
                                    .cornerRadius(12)
                                
                                Rectangle()
                                    .fill(AppTheme.darkAccentColor)
                                    .frame(
                                        width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(item.count) / CGFloat(max(chartData.map { $0.count }.max() ?? 1, 1)))),
                                        height: 24
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .frame(height: 24)
                    }
                }
            }
            .frame(height: CGFloat(chartData.count * 50))
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct AverageTimeCard: View {
    let entries: [StoolEntry]
    
    var averageHour: Double {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let totalHours = entries.compactMap { entry -> Int? in
            guard let timestamp = entry.timestamp else { return nil }
            return calendar.component(.hour, from: timestamp)
        }.reduce(0, +)
        
        return Double(totalHours) / Double(entries.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average time of day")
                .font(.headline)
            
            HStack {
                Text("\(String(format: "%.0f", averageHour)):00")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.darkAccentColor)
                
                Spacer()
                
                Text("most frequent time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct StoolColorChartFromArray: View {
    let entries: [StoolEntry]
    
    var colorDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        for entry in entries {
            if let color = entry.color, !color.isEmpty {
                distribution[color, default: 0] += 1
            }
        }
        return distribution
    }
    
    var chartData: [(color: String, count: Int)] {
        colorDistribution.map { (color: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count } // Сортируем по убыванию количества
    }
    
    // Color mapping to actual colors (supports both English and Russian for backward compatibility)
    private func colorForStool(_ colorName: String) -> Color {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribution by stool colors")
                .font(.headline)
            
            // Simple visualization without Charts framework
            VStack(alignment: .leading, spacing: 12) {
                ForEach(chartData, id: \.color) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            // Color indicator
                            Circle()
                                .fill(colorForStool(item.color))
                                .frame(width: 16, height: 16)
                            
                            Text(translateColorName(item.color))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.darkAccentColor)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 24)
                                    .cornerRadius(12)
                                
                                Rectangle()
                                    .fill(colorForStool(item.color))
                                    .frame(
                                        width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(item.count) / CGFloat(max(chartData.map { $0.count }.max() ?? 1, 1)))),
                                        height: 24
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .frame(height: 24)
                    }
                }
            }
            .frame(height: CGFloat(chartData.count * 50))
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct ConstipationDaysCard: View {
    let entries: [StoolEntry]
    
    var constipationDays: Int {
        let calendar = Calendar.current
        var daysWithEntries = Set<Date>()
        
        for entry in entries {
            if let timestamp = entry.timestamp {
                let day = calendar.startOfDay(for: timestamp)
                daysWithEntries.insert(day)
            }
        }
        
        guard let firstEntry = entries.last?.timestamp,
              let lastEntry = entries.first?.timestamp else {
            return 0
        }
        
        var currentDate = calendar.startOfDay(for: firstEntry)
        let endDate = calendar.startOfDay(for: lastEntry)
        var constipationCount = 0
        var consecutiveDaysWithout = 0
        
        while currentDate <= endDate {
            if daysWithEntries.contains(currentDate) {
                if consecutiveDaysWithout >= 2 {
                    constipationCount += consecutiveDaysWithout - 1
                }
                consecutiveDaysWithout = 0
            } else {
                consecutiveDaysWithout += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        if consecutiveDaysWithout >= 2 {
            constipationCount += consecutiveDaysWithout - 1
        }
        
        return constipationCount
    }
    
    var tooFrequentDays: Int {
        let calendar = Calendar.current
        var dayCounts: [Date: Int] = [:]
        
        for entry in entries {
            if let timestamp = entry.timestamp {
                let day = calendar.startOfDay(for: timestamp)
                dayCounts[day, default: 0] += 1
            }
        }
        
        return dayCounts.values.filter { $0 >= 4 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special days")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(constipationDays)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                    Text("days without stool")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(tooFrequentDays)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    Text("too frequent days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

#Preview {
    StatisticsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

