//
//  Task+Utils.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.10.2022.
//

import Foundation

typealias VoidTask = Task<Void, Never>

extension Task where Success == Never, Failure == Never {
    
    /// Suspends the current task for at least the given duration in seconds.
    static func sleep(seconds: TimeInterval) async {
        let duration = UInt64(seconds * 1_000_000_000)
        try? await sleep(nanoseconds: duration)
    }
    
    static func debugSleep(seconds: TimeInterval = 1.5) async {
        await sleep(seconds: seconds)
    }
}

extension Task where Failure == Never, Success == Void {
    
    @discardableResult
    init(priority: TaskPriority? = nil, _ operation: @escaping () async throws -> Void, `catch`: @escaping (Error) -> Void) {
        self.init(priority: priority) {
            do {
                _ = try await operation()
            } catch {
                await MainActor.run {
                    `catch`(error)
                }
            }
        }
    }
}
