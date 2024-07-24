import Foundation

extension NSProgressIndicator {
    static func addProgressIndicator(to view: NSView) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .small

        view.addSubview(progressIndicator)

        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        progressIndicator.startAnimation(view)
        return progressIndicator
    }

    func set(tintColor: NSColor) {
        guard let adjustedTintColor = NSColor.white.usingColorSpace(.deviceRGB) else {
            return
        }

        let tintColorRedComponent = adjustedTintColor.redComponent
        let tintColorGreenComponent = adjustedTintColor.greenComponent
        let tintColorBlueComponent = adjustedTintColor.blueComponent

        let tintColorMinComponentsVector = CIVector(x: tintColorRedComponent, y: tintColorGreenComponent, z: tintColorBlueComponent, w: 0.0)
        let tintColorMaxComponentsVector = CIVector(x: tintColorRedComponent, y: tintColorGreenComponent, z: tintColorBlueComponent, w: 1.0)

        let colorClampFilter = CIFilter(name: "CIColorClamp")!
        colorClampFilter.setDefaults()
        colorClampFilter.setValue(tintColorMinComponentsVector, forKey: "inputMinComponents")
        colorClampFilter.setValue(tintColorMaxComponentsVector, forKey: "inputMaxComponents")

        contentFilters = [colorClampFilter]
    }
}
