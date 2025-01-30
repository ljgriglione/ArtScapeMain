import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject {
    @Published var geocodedLocation: CLLocationCoordinate2D?
    @Published var isValidAddress: Bool = false  // Tracks if the address is valid

    private let geocoder = CLGeocoder()

    func geocodeAddress(_ address: String) {
        geocoder.geocodeAddressString(address) { placemarks, _ in
            DispatchQueue.main.async {
                if let location = placemarks?.first?.location {
                    self.geocodedLocation = location.coordinate
                    self.isValidAddress = true  // Address is valid
                } else {
                    self.geocodedLocation = nil
                    self.isValidAddress = false // Address is invalid
                }
            }
        }
    }
}

