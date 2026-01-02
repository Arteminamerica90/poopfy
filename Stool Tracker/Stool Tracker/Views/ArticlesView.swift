//
//  ArticlesView.swift
//  Stool Tracker
//
//  Created by Artem Menshikov on 02.01.2026.
//

import SwiftUI

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let category: String
}

struct ArticlesView: View {
    let articles: [Article] = [
        Article(
            title: "Basics of Healthy Nutrition",
            content: "For normal bowel movements, it's important to include enough fiber in your diet (25-30g per day). It's found in vegetables, fruits, and whole grains. Don't forget to drink water - at least 1.5-2 liters per day. Physical activity and adequate sleep also help maintain healthy digestion.",
            category: "Nutrition"
        ),
        Article(
            title: "Foods for Constipation",
            content: "If you have constipation, include in your diet: prunes, figs, kiwi, apples with skin, beets, oatmeal, flax seeds. Avoid or limit: white bread, rice, bananas (unripe), red meat, fast food. Remember: each body is unique, monitor your reaction to foods.",
            category: "Nutrition"
        ),
        Article(
            title: "Daily Routine and Bowel Movements",
            content: "Developing a habit of going to the bathroom at the same time helps regulate your bowels. Try to set aside 10-15 minutes in the morning after breakfast. Don't rush, relax. Regularity is more important than frequency. Over time, your body will get used to this routine.",
            category: "Routine"
        ),
        Article(
            title: "When to See a Doctor",
            content: "Be sure to see a doctor if you notice: blood in stool, sudden unexplained weight loss, severe abdominal pain, changes in bowel frequency lasting more than two weeks. Don't delay your visit - early diagnosis helps solve problems faster.",
            category: "Health"
        ),
        Article(
            title: "Water and Digestion",
            content: "Water plays a key role in forming normal stool. With insufficient fluid, stool becomes harder, which can lead to constipation. Drink water evenly throughout the day, not just when you feel thirsty. Warm water in the morning on an empty stomach can help activate your bowels.",
            category: "Nutrition"
        ),
        Article(
            title: "Physical Activity",
            content: "Regular physical exercise stimulates bowel function. Even 20-30 minutes of walking per day can improve digestion. Ab exercises, yoga, swimming - all of this helps maintain intestinal health. The key is regularity, not intensity.",
            category: "Health"
        ),
        Article(
            title: "Apples for Digestion",
            content: "Apples are rich in pectin - soluble fiber that helps normalize stool. Eat apples with the skin, as that's where most of the fiber is. One apple a day can help maintain regular bowel movements. Best eaten between meals.",
            category: "Fruits"
        ),
        Article(
            title: "Prunes for Constipation",
            content: "Prunes are one of the most effective natural remedies for constipation. They contain sorbitol and fiber, which gently stimulate bowel function. 3-5 prunes per day is enough. You can eat them dried or soaked in water overnight. Great for a morning snack.",
            category: "Fruits"
        ),
        Article(
            title: "Kiwi for Intestines",
            content: "Kiwi contains actinidin - an enzyme that helps digest proteins and improves bowel function. One kiwi per day provides the daily requirement of vitamin C and helps maintain regular bowel movements. Eat kiwi in the morning on an empty stomach or after breakfast for best effect.",
            category: "Fruits"
        ),
        Article(
            title: "Pears and Digestion",
            content: "Pears are rich in fiber and contain fructose and sorbitol, which have a mild laxative effect. Ripe pears are especially beneficial. One pear per day can help with constipation. Eat pears with the skin for maximum benefit. Best eaten between meals.",
            category: "Fruits"
        ),
        Article(
            title: "Figs for Intestinal Health",
            content: "Figs contain lots of fiber and natural sugars that help gently stimulate bowel function. Fresh or dried figs are equally beneficial. 2-3 figs per day can help with constipation. Figs are also rich in potassium and magnesium, which are important for intestinal muscle function.",
            category: "Fruits"
        ),
        Article(
            title: "Bananas and Stool",
            content: "Ripe bananas help normalize stool thanks to their pectin and fiber content. However, unripe bananas can cause constipation. Only eat fully ripe bananas with brown spots on the skin. One ripe banana per day is beneficial for digestion.",
            category: "Fruits"
        ),
        Article(
            title: "Apricots for Regularity",
            content: "Apricots, especially dried apricots, are rich in fiber and sorbitol, which help with constipation. Dried apricots are an excellent snack for maintaining intestinal health. 5-6 dried apricots per day can help normalize stool. Soak dried apricots in water overnight for a milder effect.",
            category: "Fruits"
        ),
        Article(
            title: "Plums and Digestion",
            content: "Plums contain sorbitol and fiber, which help gently stimulate bowel function. Fresh plums in season or prunes year-round are excellent choices. 3-4 plums per day can help with constipation. Eat plums between meals for better absorption.",
            category: "Fruits"
        ),
        Article(
            title: "Oranges for Fiber",
            content: "Oranges are rich in fiber, especially if eaten with the white pith (albedo). One orange per day provides a good portion of fiber and vitamin C. Fiber from oranges helps form soft stool. Eat whole oranges, not just drink the juice.",
            category: "Fruits"
        ),
        Article(
            title: "Grapes and Digestion",
            content: "Grapes contain fiber and natural sugars that help maintain regular bowel movements. Dark grapes are especially beneficial. A handful of grapes (about 100-150g) per day can help digestion. Eat grapes with seeds if they don't cause discomfort.",
            category: "Fruits"
        )
    ]
    
    @State private var selectedCategory: String? = nil
    
    var filteredArticles: [Article] {
        if let category = selectedCategory {
            return articles.filter { $0.category == category }
        }
        return articles
    }
    
    var categories: [String] {
        Array(Set(articles.map { $0.category })).sorted()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.gradientBackground
                    .ignoresSafeAreaCompat()
                
                VStack(spacing: 0) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: { selectedCategory = nil }) {
                                Text("All")
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == nil ? AppTheme.darkAccentColor : Color.white.opacity(0.8))
                                    .foregroundColor(selectedCategory == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? AppTheme.darkAccentColor : Color.white.opacity(0.8))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Articles list
                    ScrollView {
                        if #available(iOS 14.0, *) {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredArticles) { article in
                                    ArticleCard(article: article)
                                }
                            }
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredArticles) { article in
                                    ArticleCard(article: article)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitleCompat("Articles")
        }
    }
}

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(article.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryColor.opacity(0.3))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            Text(article.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(article.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

#Preview {
    ArticlesView()
}
