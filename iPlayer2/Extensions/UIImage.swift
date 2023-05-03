//
//  UIImage.swift
//  iPlayer2
//
//  Created by Testpress on 02/05/23.
//

import Foundation
import UIKit

extension UIImage {
    func resize(toWidth width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode) else { return nil }
        return resizedImage
    }
}
