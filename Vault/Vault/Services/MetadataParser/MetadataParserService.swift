import Foundation

protocol MetadataParser {
    func canParse(url: URL) -> Bool
    func parse(url: URL) async throws -> ParsedMetadata
}

struct ParsedMetadata {
    let title: String
    let description: String?
    let imageURL: URL?
    let sourceType: SourceType
}

final class MetadataParserService {
    private let parsers: [MetadataParser]
    
    init() {
        self.parsers = [
            YouTubeParser(),
            InstagramParser(),
            AmazonParser(),
            AppleBooksParser(),
            OpenGraphParser() // Fallback
        ]
    }
    
    func parse(url: URL) async throws -> ParsedMetadata {
        guard let parser = parsers.first(where: { $0.canParse(url: url) }) else {
            throw ParsingError.unsupportedURL
        }
        
        return try await parser.parse(url: url)
    }
}

enum ParsingError: Error, LocalizedError {
    case unsupportedURL
    case networkError
    case invalidData
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .unsupportedURL:
            return "Unsupported URL format"
        case .networkError:
            return "Network connection error"
        case .invalidData:
            return "Invalid data received"
        case .parsingFailed:
            return "Failed to parse metadata"
        }
    }
}
