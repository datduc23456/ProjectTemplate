//
//  CommonUtil.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 16/11/2022.
//

import Foundation
import UIKit

class CommonUtil {
    static var SCREEN_WIDTH: CGFloat {
        return (AppDelegate.shared.window?.bounds.width)!
    }
    
    static func getYearFromDate(_ dateString: String, dateFormat: String = "yyyy-MM-dd") -> String {
        let date = dateString.toDate(dateFormat: dateFormat)
        return "\((date?.get(.year)).isNil(value: 1996))"
    }
    
    static func getMonthFromDate(_ dateString: String, dateFormat: String = "yyyy-MM-dd") -> String {
        let date = dateString.toDate(dateFormat: dateFormat)
        return "\((date?.get(.month)).isNil(value: 12))"
    }
    
    static func getDayFromDate(_ dateString: String, dateFormat: String = "yyyy-MM-dd") -> String {
        let date = dateString.toDate(dateFormat: dateFormat)
        return "\((date?.get(.month)).isNil(value: 28))"
    }

    static func convertNumberMonthToText(_ month: Int) -> String {
        let df = DateFormatter()
        return df.shortMonthSymbols[safe: month - 1].isNil(value: "Null")
    }
    
    static func getThumbnailYoutubeUrl(_ key: String) -> URL {
        return URL(string: "https://img.youtube.com/vi/\(key)/maxresdefault.jpg")!
    }
    
    static func saveImageFromPhotosToLocal(info: [UIImagePickerController.InfoKey : Any]) -> String? {
        guard let image = info[.originalImage] as? UIImage else {
            return nil
        }
        let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
//        let imageSize: Int = imgData.count
//        let sizeMB = Double(imageSize) / (1024.0*1024.0)
        var fileExtention = "jpeg"
        if let imgURL = info[.imageURL] as? URL {
            let subString = imgURL.lastPathComponent.split(separator: ".")
            fileExtention = String(subString[subString.count - 1])
        }
        let fileName = "IMG_\(Int64(Date().timeIntervalSince1970)).\(fileExtention)"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(fileName)
        do {
            try imgData.write(to: url)
        } catch {
            print("Unable to Write Image Data to Disk")
            return nil
        }
        return fileName
    }
}

public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
