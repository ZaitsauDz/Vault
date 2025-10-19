import Foundation

final class OpenGraphParser: MetadataParser {
    func canParse(url: URL) -> Bool {
        return true // Fallback for all URLs
    }
    
    func parse(url: URL) async throws -> ParsedMetadata {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw ParsingError.invalidData
        }
        
        let title = extractOpenGraphContent(from: html, property: "og:title") ?? 
                   extractTitleTag(from: html) ?? 
                   url.lastPathComponent
        
        let description = extractOpenGraphContent(from: html, property: "og:description") ??
                         extractMetaContent(from: html, name: "description")
        
        let imageURLString = extractOpenGraphContent(from: html, property: "og:image")
        let imageURL = imageURLString.flatMap { URL(string: $0) }
        
        return ParsedMetadata(
            title: title,
            description: description,
            imageURL: imageURL,
            sourceType: .unknown
        )
    }
    
    private func extractOpenGraphContent(from html: String, property: String) -> String? {
        let pattern = #"<meta\s+property="\#(property)"\s+content="([^"]*)"\s*/>"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: html.utf16.count)
        
        if let match = regex?.firstMatch(in: html, options: [], range: range),
           let contentRange = Range(match.range(at: 1), in: html) {
            return String(html[contentRange])
        }
        
        return nil
    }
    
    private func extractTitleTag(from html: String) -> String? {
        let pattern = #"<title[^>]*>([^<]*)</title>"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: html.utf16.count)
        
        if let match = regex?.firstMatch(in: html, options: [], range: range),
           let contentRange = Range(match.range(at: 1), in: html) {
            return String(html[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    private func extractMetaContent(from html: String, name: String) -> String? {
        let pattern = #"<meta\s+name="\#(name)"\s+content="([^"]*)"\s*/>"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: html.utf16.count)
        
        if let match = regex?.firstMatch(in: html, options: [], range: range),
           let contentRange = Range(match.range(at: 1), in: html) {
            return String(html[contentRange])
        }
        
        return nil
    }
}
