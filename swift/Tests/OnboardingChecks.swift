import Foundation

@main struct OnboardingChecks {
    static func main() {
        var flow = OnboardingFlow()
        precondition(!flow.request(), "Title must not request location")
        flow.begin()
        precondition(flow.request())
        precondition(!flow.request(), "Repeated taps must not duplicate permission requests")
        flow.observe(.denied)
        precondition(!flow.requestPending)
        flow.introduce(usingLocation: false)
        for state in [OnboardingFlow.Location.undecided, .denied, .locating, .visit, .remote] {
            precondition(!flow.recommendsMap(state), "Explicit virtual choice remains virtual")
            precondition(!flow.recordsVisits(state), "Explicit virtual choice must not record")
        }
        flow.introduce(usingLocation: true)
        precondition(flow.recommendsMap(.visit) && flow.recordsVisits(.visit))
        precondition(!flow.recommendsMap(.locating) && flow.recordsVisits(.locating), "Permission without a fix preserves recording policy without claiming proximity")
        precondition(!flow.recommendsMap(.remote) && !flow.recordsVisits(.remote))
        precondition(!flow.recommendsMap(.denied) && !flow.recordsVisits(.denied), "Revocation during introduction must be respected")
        precondition(!flow.recommendsMap(.undecided) && !flow.recordsVisits(.undecided))
        precondition(!flow.request(), "Introduction cannot request permissions")
        flow.next()
        precondition(flow.stage == .navigation)
        flow.next()
        precondition(flow.stage == .stories)
        flow.next()
        precondition(flow.stage == .stories, "Forward cannot leave the final page")
        flow.back()
        precondition(flow.stage == .navigation && flow.usesLocation)
        flow.back()
        flow.back()
        precondition(flow.stage == .location)
        flow.introduce(usingLocation: false)
        flow.next()
        flow.next()
        precondition(!flow.recordsVisits(.visit), "Going back and choosing virtual must replace the old choice")
        print("Onboarding state checks passed: explicit skip, repeated taps, no fix, remote, canyon, revocation.")
    }
}
