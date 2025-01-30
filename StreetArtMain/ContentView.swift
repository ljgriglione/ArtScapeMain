

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct ContentView: View {
    // Main States that controll list and link to SwiftData
    @State private var isShowingItemSheet = false
    @Environment(\.modelContext) private var context
    @Query var aData: [ArtData]
    @State private var dataToEdit: ArtData?
    // Main Screen
    var body: some View {
        NavigationStack {
            // Controlles the list of sites
            List {
                ForEach(aData) { dataArt in
                    ArtCell(data: dataArt)
                        .onTapGesture {
                            dataToEdit = dataArt
                        }
                }
                .onDelete{ indexSet in
                    for index in indexSet{
                        context.delete(aData[index])
                    }
                    
                }
            }
           // Main heading and extra sheets
                .navigationTitle("Art Pieces")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet) {
                    AddArtSheet() }
                .sheet(item: $dataToEdit){ dataArt in
                    UpdateArtSheet(aData: dataArt)
                }
            // When data is filled the view changes and has a plus included
                .toolbar {
                    if !aData.isEmpty {
                        Button("Add Art Work", systemImage: "plus") {
                            isShowingItemSheet = true
                        }
                       
                    }
                }
                // If the data is empty it stays in the no artwork view
                .overlay {
                    if aData.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No ArtWork", systemImage: "list.bullet.rectangle.portrait")
                                .offset(y:-100)
                        }, description: {
                            Text("Start adding Art to see your list.")
                                .offset(y:-100)
                        }, actions: {
                        })
                        Button("Add ArtWork") { isShowingItemSheet = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }else {
                        // A button at the bottom of the screen that takes user to map
                        
                        NavigationLink(destination: MapView()) {
                            Text("Go to Map")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            }
                        Button("Reset Data") {
                        Task {
                            do {
                            try await
                                DatabaseManager.resetDatabase(context: context)
                            } catch {
                            print("Failed to reset database: \(error.localizedDescription)")
                            }
                    }
                }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .offset(y: 100)
                    }
                }
           
        }
    }
    
}
#Preview{
    ContentView()
    
}

struct ArtCell: View{
    var data: ArtData
    var body: some View{
        HStack{
            Text(data.name)
            Spacer()
            Text(String(data.lat))
            Spacer()
            Text(String(data.long))
            
        }
    }
}
// View when add artwork or plus button is pressed
struct AddArtSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var lat: Double = 0
    @State private var long: Double = 0
    @State private var address: String = ""
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            Form {
                // Name feild
                TextField("Art Work Name", text: $name)
                
                // Address input field
                TextField("Enter Address", text: $address)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: address) { newValue in
                        locationManager.geocodeAddress(newValue) // Auto-convert address
                                    }

                // Show coordinates if found
                if let coordinate = locationManager.geocodedLocation {
                Text("Latitude: \(coordinate.latitude)")
                Text("Longitude: \(coordinate.longitude)")
                                }
                
            }
                    .navigationTitle("New ArtWork")
                    .navigationBarTitleDisplayMode (.large)
                    .toolbar {
                        ToolbarItemGroup (placement: .topBarLeading) { Button("Cancel") { dismiss()
                        }
                        }
                ToolbarItemGroup (placement: .topBarTrailing) {
                Button("Save Artwork") {
                if let coordinate = locationManager.geocodedLocation {
                    let newArt = ArtData(name: name, address: address, long: coordinate.longitude, lat: coordinate.latitude)
                    context.insert(newArt)
                    dismiss()
                    }
                }
            .disabled(!locationManager.isValidAddress) // Only enabled if address is valid
                                       
                        }
                    
            }
        }
    }
    var numberFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.zeroSymbol = ""
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 6 // Adjust according to your precision needs
            formatter.alwaysShowsDecimalSeparator = true
            return formatter
        }
}
// view when editing a artwork piece
struct UpdateArtSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var aData: ArtData
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Art Work Name", text: $aData.name)
                TextField("Lattitude", value: $aData.lat, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Longitude", value: $aData.long, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                
            }
            .navigationTitle("Update Art")
            .navigationBarTitleDisplayMode (.large)
            .toolbar {
                ToolbarItemGroup (placement: .topBarLeading) { Button("Done") { dismiss()
                }
                    
                }
            }
        }
    }
}
struct MapView: View {
    @Environment(\.modelContext) private var context
    @Query var aData: [ArtData]
    @State var camera: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:  41.8825, longitude:  -87.6233), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)))
    
        var body: some View {
            Map(position: $camera){
                
                ForEach(aData) { item in
                    let cord = CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)
                    Marker(item.name, coordinate: cord)
                    
                }
                
               
                
            }
            
            
            
        }
}
