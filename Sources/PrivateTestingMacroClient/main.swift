import PrivateTestingMacro

enum Test {
    @PrivateTestable
    private func performHiddenLogic(on value: Int) -> Int {
        return value * value
    }
}
