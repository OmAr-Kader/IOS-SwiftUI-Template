import Foundation

@frozen public struct Tasker : Sendable {
    
    private var tasks: [String: Task<Void, Error>] = [:]

    private var backTask: Task<Void, Error>?
    
    private var mainTask: Task<Void, Error>?

    @inline(__always) @discardableResult mutating nonisolated func backSync(
        block: @Sendable @escaping @BackgroundActor () async -> Void
    ) -> Task<Void, Error>? {
        backTask = Task { @BackgroundActor [backTask] in
            let _ = await backTask?.result
            return await block()
        }
        return backTask
    }
    
    @inline(__always) @discardableResult mutating nonisolated func mainSync(
        block: @MainActor @escaping @Sendable () async -> Void
    ) -> Task<Void, Error>? {
        mainTask = Task { @MainActor [mainTask] in
            let _ = await mainTask?.result
            return await block()
        }
        return mainTask
    }
    
    @inline(__always) @discardableResult nonisolated func back(
        block: @BackgroundActor @escaping () async -> Void
    ) -> Task<Void, Error>? {
        return Task { @BackgroundActor in
            return await block()
        }
    }
    
    @inline(__always) @discardableResult mutating nonisolated func backAutoCancle(id: String, block: @BackgroundActor @escaping () async -> Void) -> Task<Void, Error>? {
        tasks.checkAndCancel(id: id)
        var copy: Tasker? = self
        let task = Task<Void, Error> { @BackgroundActor in
            defer {
                copy?.removeTask(id)
            }
            return await block()
        }
        tasks[id] = task
        return task
    }
    
    @inline(__always) @discardableResult mutating nonisolated func backOnlyFirst(id: String, block: @BackgroundActor @escaping () async -> Void) -> Task<Void, Error>? {
        guard tasks[id] == nil else {
            print("already exist task with id: \(id)")
            return nil
        }
        var copy: Tasker? = self
        let task = Task<Void, Error> { @BackgroundActor in
            defer {
                copy?.removeTask(id)
            }
            return await block()
        }
        tasks[id] = task
        return task
    }
    
    
    mutating func removeTask(_ id: String) {
        self.tasks.removeValue(forKey: id)
    }
    
    
    mutating func deInit() {
        backTask?.cancel()
        mainTask?.cancel()
        self.backTask = nil
        self.mainTask = nil
        tasks.cancelAll()
    }
}


extension [String: Task<Void, Error>]  {
    
    mutating nonisolated func checkAndCancel(id: String) {
        guard let oldTask = self[id] else { return }
        if !oldTask.isCancelled {
            oldTask.cancel()
        }
        self.removeValue(forKey: id)
        print("canceled \(id)")
    }
    
    mutating nonisolated func cancel(id: String) {
        guard let task = self[id] else { return }
        task.cancel()
        self[id] = nil
    }
    
    mutating nonisolated func cancelAll() {
        for (id, task) in self {
            task.cancel()
            self[id] = nil
        }
    }
    
    mutating nonisolated func remove(id: String) {
        self[id] = nil
    }
}


@inline(__always) @discardableResult func TaskBackSwitcher(
    block: @BackgroundActor @escaping () async -> Void
) -> Task<Void, Error>? {
    return Task { @BackgroundActor in
        return await block()
    }
}

@inline(__always) @discardableResult func TaskMainSwitcher(
    block: @MainActor @escaping () async -> Void
) -> Task<Void, Error>? {
    return Task { @MainActor in
        return await block()
    }
}


protocol ScopeFunc {}
extension NSObject: ScopeFunc {}
extension Array : ScopeFunc {}
extension Int : ScopeFunc {}
extension Float : ScopeFunc {}


extension Optional where Wrapped: ScopeFunc {

    @inline(__always) func `let`<R>(_ block: (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBack<R>(_ block: @BackgroundActor (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    
    @BackgroundActor
    @inline(__always) func letBackN<R>(_ block: @BackgroundActor (Wrapped?) -> R?) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }

    @inline(__always) func letSusBack<R>(_ block: @BackgroundActor (Wrapped) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self? {
        guard let self = self else { return nil }
        block(self)
        return self
    }
    
}


extension Optional where Wrapped == ScopeFunc? {

    @inline(__always) func `let`<R>(_ block: (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBack<R>(_ block: @BackgroundActor (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBackN<R>(_ block: @BackgroundActor (Wrapped?) -> R?) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }

    @inline(__always) func letSusBack<R>(_ block: @BackgroundActor (Wrapped) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        guard let self = self else { return nil }
        block(self)
        return self
    }
}



extension Optional {
    func `let`(do: (Wrapped)->()) {
        guard let v = self else { return }
        `do`(v)
    }
}

extension ScopeFunc {
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
    
    @inline(__always) func supply(_ block: (Self) -> ()) {
        block(self)
    }
    
    @BackgroundActor
    @inline(__always) func applyBack(_ block: @BackgroundActor (Self) -> ()) -> Self {
        block(self)
        return self
    }
    
    @BackgroundActor
    @inline(__always) func supplyBack(_ block: @BackgroundActor (Self) -> ()) {
        block(self)
    }
    
    @inline(__always) func `let`<R>(_ block: (Self) -> R) -> R {
        return block(self)
    }
    
}


public extension TimeInterval {
    var nanoseconds: UInt64 {
        return UInt64((self * 1_000_000_000).rounded())
    }
}

public extension Task where Success == Never, Failure == Never {
    static func sleep(sec duration: TimeInterval) async {
        try? await Task.sleep(nanoseconds: duration.nanoseconds)
    }
}

@globalActor actor BackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}


/*
 
 
 public actor TaskerActor : Sendable {

     var backTask: Task<Void, Error>?
     
     var mainTask: Task<Void, Error>?

     @inline(__always) @discardableResult func backSync(
         block: @Sendable @escaping @BackgroundActor () async -> Void
     ) -> Task<Void, Error>? {
         backTask = Task { @BackgroundActor [backTask] in
             let _ = await backTask?.result
             return await block()
         }
         return backTask
     }
     
     @inline(__always) @discardableResult func mainSync(
         block: @MainActor @escaping @Sendable () async -> Void
     ) -> Task<Void, Error>? {
         mainTask = Task { @MainActor [mainTask] in
             let _ = await mainTask?.result
             return await block()
         }
         return mainTask
     }
     
     @inline(__always) @discardableResult func back(
         block: @BackgroundActor @escaping () async -> Void
     ) -> Task<Void, Error>? {
         return Task { @BackgroundActor in
             return await block()
         }
     }
     
     deinit {
         backTask?.cancel()
         mainTask?.cancel()
         self.backTask = nil
         self.mainTask = nil
     }
 }
 
 */
