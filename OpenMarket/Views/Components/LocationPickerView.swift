import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    var onSelect: (CLLocationCoordinate2D, String) -> Void

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 26.2235, longitude: 50.5876),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var pinCoordinate = CLLocationCoordinate2D(latitude: 26.2235, longitude: 50.5876)
    @State private var locationName = "Manama, Bahrain"
    @State private var isGeocoding = false

    var body: some View {
        ZStack {
            // Map
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    Annotation("", coordinate: pinCoordinate) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.omAccent)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.omAccent)
                                .offset(y: -4)
                        }
                    }
                }
                .onTapGesture { point in
                    if let coord = proxy.convert(point, from: .local) {
                        pinCoordinate = coord
                        reverseGeocode(coord)
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            ))
                        }
                    }
                }
            }
            .ignoresSafeArea()

            // Top bar
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Pick location")
                        .font(.inter(16, weight: .semibold))
                        .foregroundStyle(Color.omText)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.s)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                    Spacer()
                    // Balance
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                Spacer()
            }

            // Bottom confirm card
            VStack {
                Spacer()
                VStack(spacing: Spacing.m) {
                    HStack(spacing: Spacing.m) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.omAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selected location").font(.omCaption).foregroundStyle(Color.omTextMuted)
                            if isGeocoding {
                                Text("Finding address…").font(.omBodyMed).foregroundStyle(Color.omTextMuted)
                            } else {
                                Text(locationName).font(.omBodyMed).foregroundStyle(Color.omText)
                            }
                        }
                        Spacer()
                    }
                    OMButton(label: "Confirm location", size: .lg, fullWidth: true) {
                        onSelect(pinCoordinate, locationName)
                        dismiss()
                    }
                }
                .padding(Spacing.xl)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
                .padding(.horizontal, Spacing.m)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            isGeocoding = false
            if let placemark = placemarks?.first {
                let parts = [placemark.locality, placemark.administrativeArea].compactMap { $0 }
                locationName = parts.joined(separator: ", ")
                if locationName.isEmpty { locationName = "Unknown location" }
            }
        }
    }
}
