import GoogleMobileAds
import SwiftUI

public struct AdBannerView: UIViewRepresentable {
    public typealias UIViewType = BannerView
    let adSize: AdSize

    init(_ adSize: AdSize) {
        self.adSize = adSize
    }

    public func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-3362935681837714/8392953389"
        banner.load(Request())
        banner.delegate = context.coordinator
        return banner
    }

    public func updateUIView(_ uiView: BannerView, context: Context) {}

    public func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator()
    }
}

public class BannerCoordinator: NSObject, BannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Banner loaded successfully")
    }

    public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Failed to load banner: \(error.localizedDescription)")
    }
}

#Preview {
    let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
    AdBannerView(adSize)
        .frame(height: 50)
}
