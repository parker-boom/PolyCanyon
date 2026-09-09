import Foundation

struct OnboardingFlow {
    enum Stage: CaseIterable { case title, location, permission, locating, visit, virtualExplanation, introduction, navigation, stories }
    enum Location { case undecided, denied, locating, visit, remote }
    private(set) var stage: Stage = .title
    private(set) var usesLocation = false
    private(set) var requestPending = false

    var isVirtualIntroduction: Bool { [.introduction, .navigation, .stories].contains(stage) }
    var progress: Int {
        switch stage {
        case .title: return 0
        case .location: return 1
        case .permission, .locating, .visit, .virtualExplanation, .introduction: return 2
        case .navigation: return 3
        case .stories: return 4
        }
    }
    mutating func begin() { stage = .location }
    mutating func chooseVisit(location: Location = .undecided) {
        usesLocation = location != .denied
        stage = location == .denied ? .virtualExplanation : .permission
    }
    mutating func request() -> Bool {
        guard stage == .permission, !requestPending else { return false }
        requestPending = true
        stage = .locating
        return true
    }
    mutating func observe(_ location: Location) {
        guard stage == .locating || stage == .visit else { return }
        switch location {
        case .visit, .remote, .locating: requestPending = false; usesLocation = true; stage = .visit
        case .denied:
            requestPending = false; usesLocation = false; stage = .virtualExplanation
        case .undecided:
            usesLocation = true
            stage = .locating
            requestPending = location == .undecided
        }
    }
    mutating func introduce(usingLocation: Bool) {
        // Each explicit journey has its own introduction. Virtual never inherits permission intent.
        usesLocation = usingLocation
        requestPending = false
        stage = usingLocation ? .visit : .introduction
    }
    mutating func next() {
        switch stage {
        case .virtualExplanation: introduce(usingLocation: false)
        case .introduction: stage = .navigation
        case .navigation: stage = .stories
        default: break
        }
    }
    mutating func back() {
        switch stage {
        case .title: break
        case .location: stage = .title
        case .permission, .virtualExplanation, .introduction: stage = .location; usesLocation = false
        case .locating, .visit: stage = .permission; usesLocation = false
        case .navigation: stage = .introduction
        case .stories: stage = .navigation
        }
        requestPending = false
    }
    func recommendsMap(_ location: Location) -> Bool { usesLocation }
    func recordsVisits(_ location: Location) -> Bool { usesLocation && [.visit, .remote, .locating].contains(location) }
}
