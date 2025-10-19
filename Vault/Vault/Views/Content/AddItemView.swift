import SwiftUI
import SwiftData

struct AddItemView: View {
    let category: ContentCategory
    
    @State private var urlString = ""
    @State private var title = ""
    @State private var description = ""
    @State private var imageURLString = ""
    @State private var selectedCategory: ContentCategory
    @State private var selectedSubcategory = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var parsedMetadata: ParsedMetadata?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    init(category: ContentCategory) {
        self.category = category
        self._selectedCategory = State(initialValue: category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("URL") {
                    HStack {
                        TextField("https://example.com/content", text: $urlString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button("Fetch") {
                            Task {
                                await fetchMetadata()
                            }
                        }
                        .disabled(urlString.isEmpty || isLoading)
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ContentCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Enter title", text: $title)
                    TextField("Enter description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Image URL (optional)", text: $imageURLString)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if !selectedSubcategory.isEmpty {
                    Section("Subcategory") {
                        TextField("Subcategory", text: $selectedSubcategory)
                    }
                }
                
                if subscriptionManager.isPro {
                    Section {
                        Button("Add Subcategory") {
                            // Show subcategory input
                        }
                    }
                }
            }
            .navigationTitle("Add New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(title.isEmpty || urlString.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Loading metadata...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func fetchMetadata() async {
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let parser = MetadataParserService()
            let metadata = try await parser.parse(url: url)
            
            await MainActor.run {
                self.parsedMetadata = metadata
                self.title = metadata.title
                self.description = metadata.description ?? ""
                if let imageURL = metadata.imageURL {
                    self.imageURLString = imageURL.absoluteString
                }
                
                // Check if source is supported for free users
                if !metadata.sourceType.isFreeSource && !subscriptionManager.isPro {
                    showError("Only YouTube, Instagram, Amazon, and Apple Books are available in the free version. Please upgrade to Pro for more sources.")
                }
            }
        } catch {
            await MainActor.run {
                showError("Failed to fetch metadata: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveItem() {
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        let item = ContentItem(
            title: title,
            sourceURL: url,
            category: selectedCategory,
            sourceType: parsedMetadata?.sourceType ?? .unknown
        )
        
        item.itemDescription = description.isEmpty ? nil : description
        item.imageURL = URL(string: imageURLString)
        item.subcategory = selectedSubcategory.isEmpty ? nil : selectedSubcategory
        
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            showError("Failed to save item: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    AddItemView(category: .watch)
        .environmentObject(SubscriptionManager())
}
