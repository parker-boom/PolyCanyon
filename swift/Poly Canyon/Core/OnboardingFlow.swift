import Foundation

struct OnboardingFlow {
    enum Stage: Int, CaseIterable { case title, location, introduction, navigation, stories }
    enum Location { case undecided, denied, locating, visit, remote }
    private(set) var stage: Stage = .title
    private(set) var usesLocation = false
    private(set) var requestPending = false

    mutating func begin() { stage = .location }
    mutating func request() -> Bool {
        guard stage == .location, !requestPending else { return false }
        requestPending = true
        return true
    }
    mutating func observe(_ location: Location) {
        if location != .undecided { requestPending = false }
    }
    mutating func introduce(usingLocation: Bool) {
        usesLocation = usingLocation
        requestPending = false
        stage = .introduction
    }
    mutating func next() {
        if let next = Stage(rawValue: stage.rawValue + 1), stage.rawValue >= Stage.introduction.rawValue { stage = next }
    }
    mutating func back() {
        if let previous = Stage(rawValue: stage.rawValue - 1) { stage = previous }
        requestPending = false
    }
    func recommendsMap(_ location: Location) -> Bool { usesLocation && location == .visit }
    func recordsVisits(_ location: Location) -> Bool {
        usesLocation && (location == .visit || location == .locating)
    }
}
