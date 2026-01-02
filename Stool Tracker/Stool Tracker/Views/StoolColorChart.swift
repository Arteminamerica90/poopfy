//
//  StoolColorChart.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import CoreData

struct StoolColorChart: View {
    let entries: FetchedResults<StoolEntry>
    
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
            .sorted { $0.count > $1.count } // Sort by descending count
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

// Preview не поддерживается для FetchedResults напрямую

