import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationService = LocationService.shared
    @EnvironmentObject var appState: AppState
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?
    @State private var isLoading = false
    @State private var selectedCategory = "All"
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 26.0667, longitude: 50.5577),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    private let quickFilters = ["All", "Under BHD 100", "Tech", "Furniture"]

    private var filteredProducts: [Product] {
        switch selectedCategory {
        case "Under BHD 100":
            return products.filter { $0.price < 100 }
        case "Tech":
            return products.filter { ["Electronics", "Mobile"].contains($0.category) }
        case "Furniture":
            return products.filter { $0.category == "Furniture" }
        default:
            return products
        }
    }

    private func categoryEmoji(_ category: String) -> String {
        let map: [String: String] = [
            "Vehicles": "🚗", "Property": "🏠", "Mobile": "📱",
            "Electronics": "📷", "Furniture": "🪑", "Fashion": "👕",
            "Sports": "🚲", "Books": "📚", "Other": "📦"
        ]
        return map[category] ?? "🏷️"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            Map(position: $cameraPosition) {
                ForEach(filteredProducts) { product in
                    if product.latitude != 0 {
                        Annotation(product.title, coordinate: CLLocationCoordinate2D(latitude: product.latitude, longitude: product.longitude)) {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                    selectedProduct = product
                                }
                            } label: {
                                let isSelected = selectedProduct?.id == product.id
                                VStack(spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(categoryEmoji(product.category))
                                            .font(.system(size: 12))
                                        Text(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                                            .font(.inter(12, weight: .bold))
                                            .foregroundStyle(isSelected ? .white : Color.omText)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(isSelected ? Color.omAccent : .white)
                                    .clipShape(Capsule())
                                    .shadow(color: isSelected ? Color.omAccent.opacity(0.4) : Color.stone700.opacity(0.15),
                                            radius: 6, y: 3)

                                    // Pin tail
                                    Triangle()
                                        .fill(isSelected ? Color.omAccent : .white)
                                        .frame(width: 10, height: 5)
                                }
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                if locationService.currentLocation != nil {
                    UserAnnotation()
                }
            }
            .ignoresSafeArea()

            // Overlays
            VStack(spacing: 0) {
                // Status bar spacer
                Color.clear.frame(height: 56)

                // Top search pill
                HStack(spacing: Spacing.m) {
                    HStack(spacing: Spacing.m) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.omTextMuted)
                        Text("Nearby").font(.omCallout).foregroundStyle(Color.omText)
                        Spacer()
                        Button {
                            appState.selectedTab = .home
                        } label: {
                            Text("List")
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.omAccent)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Spacing.l)
                    .frame(height: 48)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .shadow(color: Color.stone700.opacity(0.08), radius: 8, y: 2)
                }
                .padding(.horizontal, Spacing.l)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.s) {
                        ForEach(quickFilters, id: \.self) { f in
                            OMChip(label: f, active: selectedCategory == f)
                                .onTapGesture { selectedCategory = f }
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                }
                .padding(.top, Spacing.m)

                Spacer()

                // Recenter button
                HStack {
                    Spacer()
                    Button {
                        if let loc = locationService.currentLocation {
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: loc.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                ))
                            }
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.omAccent)
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.stone700.opacity(0.12), radius: 6, y: 2)
                    }
                    .padding(.trailing, Spacing.l)
                    .padding(.bottom, selectedProduct != nil ? 200 : Spacing.xl)
                }
            }

            // Bottom card
            if let product = selectedProduct {
                bottomCard(product)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task { await loadNearby() }
        .onAppear { locationService.requestPermission() }
    }

    private func loadNearby() async {
        isLoading = true
        defer { isLoading = false }
        let lat = locationService.currentLocation?.coordinate.latitude ?? 26.0667
        let lng = locationService.currentLocation?.coordinate.longitude ?? 50.5577
        products = (try? await ProductService.nearby(lat: lat, lng: lng, radiusKm: 20)) ?? []
    }

    private func bottomCard(_ product: Product) -> some View {
        VStack(spacing: 0) {
            // Grabber
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.omBorderStrong)
                .frame(width: 40, height: 5)
                .padding(.top, Spacing.m)

            HStack(spacing: Spacing.m) {
                AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.cream200).overlay(Image(systemName: "photo").foregroundStyle(Color.stone300))
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                    Text(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                        .font(.inter(16, weight: .bold)).foregroundStyle(Color.omAccent)
                    HStack(spacing: 3) {
                        Image(systemName: "mappin").font(.system(size: 10)).foregroundStyle(Color.omTextSubtle)
                        Text(product.location).font(.inter(12)).foregroundStyle(Color.omTextMuted)
                    }
                }
                Spacer()
                NavigationLink { ProductDetailView(product: product) } label: {
                    OMButton(label: "View", variant: .primary, size: .sm) {}
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
        }
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, 100) // above tab bar
        .shadow(color: Color.stone700.opacity(0.12), radius: 16, y: -4)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
