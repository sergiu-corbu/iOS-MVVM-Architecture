//
//  Debouncer.swift
//  MVVM Project
//
//  Created by Doru Cojocaru on 24.07.2023.
//

import Foundation

final class Debouncer {

    private let queue: DispatchQueue
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func debounce(action: @escaping () -> Void) {
        cancel()
        workItem = DispatchWorkItem { [weak self] in
            action()
            self?.cancel()
        }
        queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
