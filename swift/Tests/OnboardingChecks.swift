import Foundation

@main struct OnboardingChecks {
    static func main() {
        for outcome in [OnboardingFlow.Location.denied, .remote, .visit, .locating, .undecided] {
            var flow = OnboardingFlow()
            precondition(!flow.request())
            flow.begin()
            precondition(flow.stage == .location && !flow.request(), "The choice screen never prompts")
            flow.chooseVisit()
            precondition(flow.stage == .permission && flow.usesLocation)
            precondition(flow.request() && !flow.request(), "One explicit permission request")
            flow.observe(outcome)
            switch outcome {
            case .visit, .remote, .locating:
                precondition(flow.stage == .visit && flow.recommendsMap(outcome) && flow.recordsVisits(outcome), "In-person choice survives remote or missing position")
                flow.observe(.locating)
                precondition(flow.stage == .visit && flow.usesLocation)
                flow.observe(.remote)
                precondition(flow.stage == .visit && flow.usesLocation)
                flow.observe(.denied)
                precondition(flow.stage == .virtualExplanation && !flow.recordsVisits(.visit))
            case .denied:
                precondition(flow.stage == .virtualExplanation && !flow.usesLocation)
                flow.next(); precondition(flow.stage == .introduction)
            case .undecided:
                precondition(flow.stage == .locating && !flow.recordsVisits(outcome))
                flow.introduce(usingLocation: false)
                flow.observe(.visit)
                precondition(flow.stage == .introduction && !flow.usesLocation, "Late fixes never override opting out")
            }
        }
        var denied = OnboardingFlow()
        denied.begin(); denied.chooseVisit(location: .denied)
        precondition(denied.stage == .virtualExplanation && !denied.request(), "Known denial goes directly to a clear continuation without another prompt")
        var flow = OnboardingFlow()
        flow.begin(); flow.introduce(usingLocation: false)
        for state in [OnboardingFlow.Location.undecided, .denied, .locating, .visit, .remote] {
            precondition(!flow.recommendsMap(state) && !flow.recordsVisits(state))
        }
        flow.next(); precondition(flow.stage == .navigation)
        flow.next(); precondition(flow.stage == .stories)
        flow.next(); precondition(flow.stage == .stories)
        flow.back(); flow.back(); flow.back(); precondition(flow.stage == .location)
        flow.chooseVisit(); precondition(flow.request())
        flow.observe(.visit); flow.back(); precondition(flow.stage == .permission)
        flow.introduce(usingLocation: false); precondition(!flow.recordsVisits(.visit))
        print("PASS: explicit journeys; separate permission/confirmation; denied continuation; remote/no-fix preserve choice; opt-out, late fix, revocation, back")
    }
}
