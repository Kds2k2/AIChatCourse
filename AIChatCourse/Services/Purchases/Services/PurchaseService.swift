//
//  PurchaseService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 23.02.2026.
//

import SwiftUI

protocol PurchaseService: Sendable {
    func listenForTransactions(onTransactionsUpdated: @escaping @Sendable ([PurchasedEntitlement]) async -> Void) async
    func getUserEntitlements() async throws -> [PurchasedEntitlement]
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func onRestorePurchase() async throws -> [PurchasedEntitlement]
    func onPurchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
    func logIn(userId: String) async throws -> [PurchasedEntitlement]
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws
    func logOut() async throws
}

enum PurchaseError: LocalizedError {
    case productNotFount, userCancelledPurchase, failedToPurchase
}
