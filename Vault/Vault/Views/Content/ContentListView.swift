import SwiftUI
import SwiftData

struct ContentListView: View {
    let category: ContentCategory
    
    @Query private var items: [ContentItem]
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingLimitAlert = false
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    
    init(category: ContentCategory) {
        self.category = category
        let predicate = #Predicate<ContentItem> { item in
            item.category == category.rawValue
        }
        _items = Query(filter: predicate, sort: \.dateAdded, order: .reverse)
    }
    
    var filteredItems: [ContentItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            (item.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView {
                        Label("No Items", systemImage: category.icon)
                    } description: {
                        Text("Start saving \(category.displayName.lowercased()) content")
                    } actions: {
                        Button("Add Item") {
                            showingAddSheet = true
                        }
                    }
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemRowView(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .searchable(text: $searchText, prompt: "Search \(category.displayName.lowercased())")
                }
            }
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if canAddItem {
                            showingAddSheet = true
                        } else {
                            showingLimitAlert = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Text("\(items.count)/\(itemLimit) \(subscriptionManager.isPro ? "PRO" : "FREE")")
                            .font(.caption)
                            .foregroundColor(.vaultSecondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView(category: category)
            }
            .alert("Item Limit Reached", isPresented: $showingLimitAlert) {
                Button("Upgrade to Pro") {
                    // Navigate to subscription
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Free users are limited to \(itemLimit) items per category. Upgrade to Pro for unlimited storage.")
            }
        }
    }
    
    private var canAddItem: Bool {
        subscriptionManager.isPro || items.count < itemLimit
    }
    
    private var itemLimit: Int {
        subscriptionManager.isPro ? Int.max : 5
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}

struct ItemRowView: View {
    let item: ContentItem
    
    var body: some View {
        HStack(spacing: 12) {
            let sourceType = SourceType(rawValue: item.sourceType) ?? .unknown
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.vaultPrimary.opacity(0.2))
                        .overlay(
                            Image(systemName: sourceType.icon)
                                .foregroundColor(.vaultPrimary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.vaultPrimary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Image(systemName: sourceType.icon)
                            .foregroundColor(.vaultPrimary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let description = item.itemDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.vaultSecondaryText)
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: sourceType.icon)
                        .font(.caption)
                        .foregroundColor(.vaultPrimary)

                    Text(item.dateAdded, style: .relative)
                        .font(.caption)
                        .foregroundColor(.vaultSecondaryText)

                    Spacer()
                    
                    if let subcategory = item.subcategory {
                        Text(subcategory)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.vaultSecondary.opacity(0.1))
                            .foregroundColor(.vaultPrimary)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentListView(category: .watch)
        .environmentObject(SubscriptionManager())
}
