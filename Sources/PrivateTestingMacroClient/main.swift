import PrivateTestingMacro

@Testable
private func performHiddenLogic(on value: Int) -> Int {
    return value * value
}
