import Foundation

private struct DeviceTokenRequest: Encodable {
    let token: String
    let platform: String
}

struct DeviceService {
    static func register(token: String) async {
        guard !token.isEmpty else { return }
        try? await APIClient.shared.requestVoid(
            Constants.Endpoints.devices,
            method: "POST",
            body: DeviceTokenRequest(token: token, platform: "ios")
        )
    }

    static func unregister(token: String) async {
        guard !token.isEmpty else { return }
        try? await APIClient.shared.requestVoid(
            Constants.Endpoints.devices,
            method: "DELETE",
            body: DeviceTokenRequest(token: token, platform: "ios")
        )
    }
}
