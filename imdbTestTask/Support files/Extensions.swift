//
//  Helper.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 16.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit


extension Notification.Name {
    static let PosterDownloadCompleted = Notification.Name(rawValue: "posterDownloadCompleted")
}

extension CGFloat {
    static func calculateCellHeight(accordingTo deviceWidth: CGFloat) -> CGFloat {
        let multiplyer = CGFloat(0.269)
        return deviceWidth * multiplyer
    }
}

extension UIView {
    func fakeFunction() {
        print("fake!")
    }
}

extension UILabel {
    func fakeFunction2() {
        print("fake!")
    }
}
