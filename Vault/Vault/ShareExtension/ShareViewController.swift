import UIKit
import SwiftUI
import UniformTypeIdentifiers
import SwiftData

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] (url, error) in
                guard let url = url as? URL else {
                    self?.close()
                    return
                }
                
                Task { @MainActor in
                    await self?.handleURL(url)
                }
            }
        }
    }
    
    @MainActor
    private func handleURL(_ url: URL) async {
        let hostingController = UIHostingController(
            rootView: ShareExtensionView(
                url: url,
                onSave: { [weak self] in
                    self?.close()
                },
                onCancel: { [weak self] in
                    self?.close()
                }
            )
        )
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

struct ShareExtensionView: View {
    let url: URL
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var metadata: ParsedMetadata?
    @State private var selectedCategory: ContentCategory = .watch
    @State private var isLoading = true
    @State private var title = ""
    @State private var description = ""
    @State private var imageURLString = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                if isLoading {
                    Section {
                        ProgressView("Loading metadata...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // Preview Section
                    if let metadata = metadata {
                        Section("Preview") {
                            if let imageURL = metadata.imageURL {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(maxHeight: 200)
                            }
                            
                            TextField("Title", text: $title)
                            TextField("Description", text: $description, axis: .vertical)
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Category Selection
                    Section("Category") {
                        Picker("Select Category", selection: $selectedCategory) {
                            ForEach(ContentCategory.allCases, id: \.self) { category in
                                Label(category.displayName, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle("Save to Vault")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        onSave()
                    }
                    .disabled(metadata == nil || title.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .task {
            await loadMetadata()
        }
    }
    
    private func loadMetadata() async {
        let parser = MetadataParserService()
        do {
            metadata = try await parser.parse(url: url)
            if let metadata = metadata {
                title = metadata.title
                description = metadata.description ?? ""
                if let imageURL = metadata.imageURL {
                    imageURLString = imageURL.absoluteString
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load metadata: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func saveItem() {
        guard let metadata = metadata else { return }
        
        // Save to SwiftData using shared App Group container
        do {
            let modelContainer = try ModelContainer(
                for: ContentItem.self,
                configurations: ModelConfiguration(
                    groupContainer: .identifier("group.com.vault.digitalcontent")
                )
            )
            
            let item = ContentItem(
                title: title,
                sourceURL: url,
                category: selectedCategory.rawValue,
                sourceType: metadata.sourceType.rawValue
            )
            item.itemDescription = description.isEmpty ? nil : description
            item.imageURL = imageURLString.isEmpty ? nil : URL(string: imageURLString)
            
            modelContainer.mainContext.insert(item)
            try modelContainer.mainContext.save()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showingError = true
        }
    }
}
