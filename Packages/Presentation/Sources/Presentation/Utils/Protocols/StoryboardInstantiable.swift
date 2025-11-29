import UIKit

protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> T
}

extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        let components = NSStringFromClass(Self.self).components(separatedBy: ".")
        guard let last = components.last, !last.isEmpty else {
            fatalError("Cannot determine default storyboard file name for \(Self.self)")
        }
        return last
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName

        // Try multiple bundles to reliably locate storyboards and resolve
        // runtime classes across Swift package -> framework -> app boundaries.
        // Order of attempts:
        // 1) Provided bundle (explicit)
        // 2) Framework bundle where this class is defined (Bundle(for:))
        // 3) Package resource bundle (Bundle.module)
        // 4) Main bundle
        let candidateBundles: [Bundle?] = [bundle, Bundle(for: Self.self), .module, Bundle.main]

        var lastError: Error?
        var attempts: [String] = []
        for candidate in candidateBundles {
            guard let bund = candidate else { continue }

            // Avoid calling UIStoryboard(name:bundle:) on a bundle that does
            // not contain the compiled storyboard resource. UIKit will raise
            // an Objective-C exception if the storyboard isn't found which
            // crashes the process. Instead check for the compiled storyboard
            // file first (storyboardc) and only try to instantiate if present.
            // storyboards are compiled into a "*.storyboardc" bundle which may
            // live inside a localization folder (e.g. Base.lproj). Use
            // `url(forResource:withExtension:)` which searches localized
            // subdirectories and returns the correct URL when present.
            if bund.url(forResource: fileName, withExtension: "storyboardc") == nil {
                continue
            }

            let storyboard = UIStoryboard(name: fileName, bundle: bund)
            print("[StoryboardInstantiable] tried bundle=\(bund.bundlePath) for storyboard=\(fileName)")
            let initial = storyboard.instantiateInitialViewController()
            if let initial = initial {
                attempts.append("bundle='\(bund.bundlePath)' -> initialVC=")
                attempts.append(String(describing: type(of: initial)))
            } else {
                attempts.append("bundle='\(bund.bundlePath)' -> no initial view controller")
            }

            if let vc = initial as? Self {
                return vc
            }
        }

        // If we got here none of the candidate bundles produced the correct
        // initial view controller — fail with diagnostic message.
        let tried = candidateBundles.compactMap { $0?.bundlePath }
        let details = attempts.joined(separator: " | ")
        fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName). Tried bundles: \(tried). Attempts: [\(details)]")
        // unreachable
    }
}
