//
//  DataModels.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/10/25.
//

import Foundation
import SwiftData

/// A thread-safe, lightweight envelope to pass data to background actors
struct ScenarioTransfer: Sendable {
    let id: PersistentIdentifier
    let embedding: [Double]
    let title: String
}
