//
//  QuickEntryView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI
import CoreData

struct QuickEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedTab: Int
    var initialDate: Date = Date()
    
    @State private var selectedDate = Date()
    @State private var bristolType: Int16 = 4
    @State private var color: String = "Brown"
    @State private var volume: String = "Medium"
    @State private var hasPain = false
    @State private var hasBlood = false
    @State private var hasMucus = false
    @State private var comment: String = ""
    
    private var iOS14OrLater: Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }
    
    private let bristolTypes = [
        (1, "Separate hard lumps"),
        (2, "Sausage-shaped, but lumpy"),
        (3, "Sausage-shaped, with cracks"),
        (4, "Smooth and soft"),
        (5, "Soft blobs"),
        (6, "Mushy"),
        (7, "Watery")
    ]
    
    private let colors = ["Brown", "Dark brown", "Light brown", "Yellow", "Green", "Black", "Red"]
    private let volumes = ["Small", "Medium", "Large"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.gradientBackground
                    .ignoresSafeAreaCompat()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("How was your stool today?")
                            .font(.title2Compat)
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                        // Date and time
                        Group {
                            if #available(iOS 14.0, *) {
                                DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                            } else {
                                DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        
                        // Bristol Stool Scale Type
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bristol Stool Scale Type")
                                .font(.headline)
                            
                            Group {
                                if #available(iOS 14.0, *) {
                                    Picker("Type", selection: $bristolType) {
                                        ForEach(bristolTypes, id: \.0) { type in
                                            Text("\(type.0). \(type.1)").tag(Int16(type.0))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                } else {
                                    Picker("Type", selection: $bristolType) {
                                        ForEach(bristolTypes, id: \.0) { type in
                                            Text("\(type.0). \(type.1)").tag(Int16(type.0))
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        // Color
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.headline)
                            
                            Group {
                                if #available(iOS 14.0, *) {
                                    Picker("Color", selection: $color) {
                                        ForEach(colors, id: \.self) { colorOption in
                                            Text(colorOption).tag(colorOption)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                } else {
                                    Picker("Color", selection: $color) {
                                        ForEach(colors, id: \.self) { colorOption in
                                            Text(colorOption).tag(colorOption)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        // Volume
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Approximate volume")
                                .font(.headline)
                            
                            Group {
                                if #available(iOS 14.0, *) {
                                    Picker("Volume", selection: $volume) {
                                        ForEach(volumes, id: \.self) { volumeOption in
                                            Text(volumeOption).tag(volumeOption)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                } else {
                                    Picker("Volume", selection: $volume) {
                                        ForEach(volumes, id: \.self) { volumeOption in
                                            Text(volumeOption).tag(volumeOption)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        // Additional symptoms
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Additional symptoms")
                                .font(.headline)
                            
                            Toggle("Had pain", isOn: $hasPain)
                            Toggle("Had blood", isOn: $hasBlood)
                            Toggle("Had mucus", isOn: $hasMucus)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        
                        // Comment
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comment (optional)")
                                .font(.headline)
                            
                            if #available(iOS 16.0, *) {
                                TextField("How do you feel?", text: $comment, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)
                            } else {
                                TextField("How do you feel?", text: $comment)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(6)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        
                        // Save button
                        Button(action: saveEntry) {
                            Text("Save entry")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.darkAccentColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding()
                }
            }
            .navigationTitleCompat("New entry")
            .modifier(NavigationBarTitleDisplayModeModifier())
            .modifier(CancelButtonModifier())
            .onAppear {
                // Initialize date when form appears
                selectedDate = initialDate
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = StoolEntry(context: viewContext)
        newEntry.timestamp = selectedDate
        newEntry.bristolType = bristolType
        newEntry.color = color
        newEntry.volume = volume
        newEntry.hasPain = hasPain
        newEntry.hasBlood = hasBlood
        newEntry.hasMucus = hasMucus
        newEntry.comment = comment.isEmpty ? nil : comment
        
        do {
            try viewContext.save()
            // Close modal and switch to calendar tab
            presentationMode.wrappedValue.dismiss()
            selectedTab = 0
        } catch {
            let nsError = error as NSError
            print("Save error: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func resetForm() {
        selectedDate = Date()
        bristolType = 4
        color = "Brown"
        volume = "Medium"
        hasPain = false
        hasBlood = false
        hasMucus = false
        comment = ""
    }
}

// Navigation bar title display mode modifier for iOS 13/14 compatibility
struct NavigationBarTitleDisplayModeModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.navigationBarTitleDisplayMode(.inline)
        } else {
            content
        }
    }
}

// Cancel button modifier for iOS 13/14 compatibility
struct CancelButtonModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(AppTheme.darkAccentColor)
                    }
                }
        } else {
            content
                .navigationBarItems(leading:
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.darkAccentColor)
                )
        }
    }
}

#Preview {
    QuickEntryView(selectedTab: .constant(0))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

