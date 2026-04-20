import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationService = LocationService.shared
    @State private var nearbyProducts: [Product] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 26.0667, longitude: 50.5577), // Bahrain default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        // TODO: Replace with design handoff
        Text("MapView — placeholder")
    }
}
