//
//  OrderModel.swift
//  BatApIos
//
//  Created by Trần Kiên on 16/3/26.
//
import Foundation
import UIKit

enum OrderStatus: Int {
    case success = 0
    case pending = 1
    case cancelled = 2
}

struct PaymentInfo {
    let productImage: UIImage?
    let productName: String
    let price: String
    let status: OrderStatus
}
