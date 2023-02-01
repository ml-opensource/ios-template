import Foundation

struct JWT: Decodable {

    let exp: Double

    init?(accessToken: String) {
        let jwtStrings = accessToken.split(separator: ".")

        guard jwtStrings.count == 3 else { return nil }

        let claimString =
            String(jwtStrings[1]).padding(
                toLength: ((String(jwtStrings[1]).count + 3) / 4) * 4,
                withPad: "=",
                startingAt: 0
            )

        let data =
            Data(base64Encoded: claimString)!

        do {
            self =
                try JSONDecoder().decode(Self.self, from: data)

        } catch {
            print(error)
            return nil
        }
    }
}
