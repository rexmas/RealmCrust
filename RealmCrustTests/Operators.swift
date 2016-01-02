import Foundation

infix operator ||= { associativity right }
func ||= (inout left: Bool, right: Bool) {
    left = left || right
}

infix operator &&= { associativity right }
func &&= (inout left: Bool, right: Bool) {
    left = left && right
}
