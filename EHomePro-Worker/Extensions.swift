//
//  Extensions.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation
import UIKit
import SwiftUI


func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let backgroundColor = hexStringToUIColor(hex: "#F2F2F2")
let shadowColor = Color.black.opacity(0.1)




enum ActivityStatus: String, CaseIterable {
    case created = "CREATED"
    case createdSecondTry = "CREATED_SECOND_TRY"
    case processing = "PROCESSING"
    case processingSecondTry = "PROCESSING_SECOND_TRY"
    case inAction = "IN_ACTION"
    case cancel = "CANCEL"
}

enum OrderStatus: String, CaseIterable {
    case waiting
    case done
    case accepted
    case canceled
    
}

//func extractCityAndState(from response: GeocodeResponse) -> [(city: String, state: String)]? {
//    var locations: [(city: String, state: String)] = []
//    
//    for result in response.results {
//        var city: String?
//        var state: String?
//        
//        for component in result.address_components {
//            if component.types.contains("locality") {
//                city = component.long_name // or use short_name based on preference
//            } else if component.types.contains("administrative_area_level_1") {
//                state = component.short_name // or use long_name based on preference
//            }
//        }
//        
//        if let city = city, let state = state {
//            locations.append((city: city, state: state))
//        }
//    }
//    
//    
//    return locations
//}

//func extractFormattedAdresses(from response: GeocodeResponse) -> [String] {
//    lazy var formattedAdresses:[String] = []
//    for addressComponents in response.results {
//        formattedAdresses.append(addressComponents.formatted_address)
//    }
//    return formattedAdresses
//}
//
//
//func extractZipcodes(from response: GeocodeResponse) -> [String] {
//    var zipcodes: [String] = []
//    
//    for result in response.results {
//        // Loop through each address component to find the postal_code
//        for component in result.address_components {
//            if component.types.contains("postal_code") {
//                // If a postal_code is found, add it to the zipcodes array
//                zipcodes.append(component.long_name) // or short_name based on your preference
//                break // Stop searching through more components once the postal_code is found
//            }
//        }
//    }
//    
//    return zipcodes
//}

//func isLocationInUSA(from result: GeocodeResult) -> Bool {
//    for component in result.address_components {
//        if component.types.contains("country") && (component.long_name == "United States" || component.short_name == "US") {
//            return true
//        }
//    }
//    return false
//}
//func detectValidLocationsInUSA(from response: GeocodeResponse) -> [Bool] {
//    return response.results.map { isLocationInUSA(from: $0) }
//}

func getRestUrl() -> String {
    return "https://gateway.intelligentehome.com"
}

enum NetworkError: Error {
    case invalidURL
    case unknownError
    case httpError(statusCode: Int)
}


extension UserDefaults {

    enum Keys: String, CaseIterable {

        case unitsNotation
        case temperatureNotation
        case allowDownloadsOverCellular

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
//
//extension UITabBarController {
//    open override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        tabBar.layer.masksToBounds = true
//        tabBar.layer.cornerRadius = 16
//        // Choose with corners should be rounded
//        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top left, top right
//
//        // Uses `accessibilityIdentifier` in order to retrieve shadow view if already added
//        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
//            shadowView.frame = tabBar.frame
//        } else {
//            let shadowView = UIView(frame: .zero)
//            shadowView.frame = tabBar.frame
//            shadowView.accessibilityIdentifier = "TabBarShadow"
//            shadowView.backgroundColor = UIColor.white
////            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
//            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
//            shadowView.layer.masksToBounds = false
//            shadowView.layer.shadowColor = Color.black.cgColor
//            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -8.0)
//            shadowView.layer.shadowOpacity = 0.3
//            shadowView.layer.shadowRadius = 10
//            view.addSubview(shadowView)
//            view.bringSubviewToFront(tabBar)
//        }
//    }
//}


func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func formatDateAndTime(from dateArray: [Int]) -> (date: String, time: String) {
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    timeFormatter.dateFormat = "HH:mm"
    
    if dateArray.count >= 5 {
        var components = DateComponents()
        components.year = dateArray[0]
        components.month = dateArray[1]
        components.day = dateArray[2]
        components.hour = dateArray[3]
        components.minute = dateArray[4]
        
        if let date = Calendar.current.date(from: components) {
            let formattedDate = dateFormatter.string(from: date)
            let formattedTime = timeFormatter.string(from: date)
            return (date: formattedDate, time: formattedTime)
        }
    }
    return (date: "Invalid date", time: "Invalid time")
}

func formatPrice(_ price: Double) -> String {
    if floor(price) == price {
        // If the number is an integer, display it without any decimal places
        return String(format: "%.0f", price)
    } else {
        // Otherwise, display it with up to two decimal places
        return String(format: "%.2f", price)
    }
}
