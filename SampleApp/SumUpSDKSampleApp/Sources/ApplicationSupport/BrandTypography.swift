import SwiftUI

/**
 Extension providing Dynamic Type-compatible styles for use in the UI.
 */
extension Font {
    
    // MARK: - Brand Typography
    
    /// **72pt Semibold**
    ///
    /// Custom size, does not scale with Dynamic Type.
    static var brandAmountDisplay: Font {
        .system(size: 72, weight: .semibold, design: .default)
    }
    
    /// **34pt Bold**
    ///
    /// Maps to ``Font/largeTitle``.
    static var brandHero: Font {
        .largeTitle.bold()
    }
    
    /// **20pt Semibold**
    ///
    /// Maps to ``Font/title3``.
    static var brandTitle: Font {
        .title3.weight(.semibold)
    }
    
    /// **17pt Bold**
    ///
    /// Maps to ``Font/headline``.
    static var brandHeadlineBold: Font {
        .headline.bold()
    }
    
    /// **17pt Semibold**
    ///
    /// Maps to ``Font/headline``.
    static var brandHeadline: Font {
        .headline
    }
    
    /// **16pt Medium**
    ///
    /// Maps to ``Font/callout``.
    static var brandCalloutMedium: Font {
        .callout.weight(.medium)
    }
    
    /// **16pt Regular**
    ///
    /// Maps to ``Font/callout``.
    static var brandCallout: Font {
        .callout
    }
    
    /// **15pt Bold**
    ///
    /// Maps to ``Font/subheadline``.
    static var brandSubheadlineBold: Font {
        .subheadline.bold()
    }
    
    /// **15pt Regular**
    ///
    /// Maps to ``Font/subheadline``.
    static var brandSubheadline: Font {
        .subheadline
    }
    
    /// **13pt Regular**
    ///
    /// Maps to ``Font/footnote``.
    static var brandFootnote: Font {
        .footnote
    }
    
    /// **12pt Regular**
    ///
    /// Maps to ``Font/caption``.
    static var brandCaption: Font {
        .caption
    }
}
