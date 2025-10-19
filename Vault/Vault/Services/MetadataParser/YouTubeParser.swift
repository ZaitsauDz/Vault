import Foundation

final class YouTubeParser: MetadataParser {
    func canParse(url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host.contains("youtube.com") || host.contains("youtu.be")
    }
    
    func parse(url: URL) async throws -> ParsedMetadata {
        // Extract video ID
        let videoID = extractVideoID(from: url)
        
        // For now, use OpenGraph as fallback since YouTube API requires authentication
        // In a production app, you would use YouTube Data API v3
        return try await parseWithOpenGraph(url: url, sourceType: .youtube)
    }
    
    private func extractVideoID(from url: URL) -> String? {
        if let host = url.host, host.contains("youtu.be") {
            return String(url.path.dropFirst()) // Remove leading slash
        } else if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        }
        return nil
    }
    
    private func parseWithOpenGraph(url: URL, sourceType: SourceType) async throws -> ParsedMetadata {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw ParsingError.invalidData
        }
        
        let title = extractOpenGraphContent(from: html, property: "og:title") ?? url.lastPathComponent
        let description = extractOpenGraphContent(from: html, property: "og:description")
        let imageURLString = extractOpenGraphContent(from: html, property: "og:image")
        let imageURL = imageURLString.flatMap { URL(string: $0) }
        
        return ParsedMetadata(
            title: title,
            description: description,
            imageURL: imageURL,
            sourceType: sourceType
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
}
