//
//  MainTabView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView(selectedTab: $selectedTab)
                .tabItem {
                    Group {
                        if #available(iOS 14.0, *) {
                            Label("Calendar", systemImage: "calendar")
                        } else {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                    }
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Group {
                        if #available(iOS 14.0, *) {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        } else {
                            Image(systemName: "chart.bar.fill")
                            Text("Statistics")
                        }
                    }
                }
                .tag(1)
            
            ArticlesView()
                .tabItem {
                    Group {
                        if #available(iOS 14.0, *) {
                            Label("Articles", systemImage: "book.fill")
                        } else {
                            Image(systemName: "book.fill")
                            Text("Articles")
                        }
                    }
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Group {
                        if #available(iOS 14.0, *) {
                            Label("Profile", systemImage: "person.fill")
                        } else {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                }
                .tag(3)
        }
        .accentColor(AppTheme.darkAccentColor)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

