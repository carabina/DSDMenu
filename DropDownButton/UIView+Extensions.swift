//
//  UIView+Extensions.swift
//  DropDownButton
//
//  Created by m3g0byt3 on 09/06/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import UIKit

extension UIView {

    func snapshotImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            return snapshotImageBlockBased()
        } else {
            return snapshotImageContextBased()
        }
    }

    @available(iOS 10.0, *)
    private func snapshotImageBlockBased() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }

    private func snapshotImageContextBased() -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, contentScaleFactor)
        drawHierarchy(in: bounds, afterScreenUpdates: true)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
