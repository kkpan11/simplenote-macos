import Foundation

extension NSViewController {
    var containingNavigationController: SPNavigationController? {
        parent as? SPNavigationController
    }
}
