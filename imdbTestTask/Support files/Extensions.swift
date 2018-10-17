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
        //        if UIDevice().userInterfaceIdiom == .phone {
//            switch UIScreen.main.nativeBounds.height {
//            case 1334, 2436:                                         // iPhone 6/6S/7/8/X
//                return
//            case 1920, 2208:                                           // iPhone 6+/6S+/7+/8+
//
//            default:                                                    //iPhone 5 or 5S or 5C
//
//            }
//        }
 
