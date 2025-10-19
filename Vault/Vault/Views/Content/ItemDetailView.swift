import SwiftUI
import SwiftData

struct ItemDetailView: View {
    let item: ContentItem
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedImageURL: String
    @State private var editedSubcategory: String
    @State private var showingDeleteAlert = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(item: ContentItem) {
        self.item = item
        self._editedTitle = State(initialValue: item.title)
        self._editedDescription = State(initialValue: item.itemDescription ?? "")
        self._editedImageURL = State(initialValue: item.imageURL?.absoluteString ?? "")
        self._editedSubcategory = State(initialValue: item.subcategory ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image
                    if let imageURL = item.imageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        // Description
                        if isEditing {
                            TextField("Description", text: $editedDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        } else if let description = item.itemDescription {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Metadata
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: item.sourceType.icon)
                                    .foregroundColor(.blue)
                                Text(item.sourceType.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("Added \(item.dateAdded, style: .relative)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let subcategory = item.subcategory {
                                HStack {
                                    Image(systemName: "tag")
                                        .foregroundColor(.blue)
                                    Text(subcategory)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Source URL
                        Button(action: {
                            if let url = URL(string: item.sourceURL.absoluteString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "link")
                                Text("Open Original")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Delete Item", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        item.title = editedTitle
        item.itemDescription = editedDescription.isEmpty ? nil : editedDescription
        item.imageURL = editedImageURL.isEmpty ? nil : URL(string: editedImageURL)
        item.subcategory = editedSubcategory.isEmpty ? nil : editedSubcategory
        item.dateModified = Date()
        
        do {
            try modelContext.save()
            isEditing = false
        } catch {
            // Handle error
        }
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Handle error
        }
    }
}

#Preview {
    let item = ContentItem(
        title: "Sample Item",
        sourceURL: URL(string: "https://example.com")!,
        category: .watch
    )
    item.itemDescription = "This is a sample description for the item."
    item.imageURL = URL(string: "https://picsum.photos/400/300")
    
    return ItemDetailView(item: item)
}
