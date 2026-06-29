import CryptoKit
import Foundation

enum UnlockCalculator {
    static func compute(macInput: String, snInput: String, useNewAlgorithm: Bool) -> String {
        let mac = macInput.uppercased().replacingOccurrences(
            of: "[^0-9A-F]",
            with: "",
            options: .regularExpression
        )
        let sn = snInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard mac.count == 12, !sn.isEmpty else { return "" }

        let dataStr = useNewAlgorithm ? sn + mac + "XIAOMI" : mac + sn + "XIAOMI"
        guard let data = dataStr.data(using: .utf8) else { return "" }

        let hashBytes = Array(SHA256.hash(data: data))
        return (0..<10).map { String(hashBytes[$0] % 10) }.joined()
    }
}
