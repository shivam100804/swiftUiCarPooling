//
//  FiltersView.swift
//  CarPolling
//
//  Created by Shivam Yadav on 15/04/25.
//

import SwiftUI

struct FiltersView: View {
    @State private var selectedFilters: Set<String> = []
    
    let availableFilters = [
        "Morning Rides",
        "Evening Rides",
        "Weekends Only",
        "Female Drivers Only",
        "Verified Riders"
    ]
    
    var body: some View {
        NavigationStack {
            List(availableFilters, id: \.self) { filter in
                HStack {
                    Text(filter)
                    Spacer()
                    if selectedFilters.contains(filter) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedFilters.contains(filter) {
                        selectedFilters.remove(filter)
                    } else {
                        selectedFilters.insert(filter)
                    }
                }
            }
            .navigationTitle("Ride Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Apply") {
                        // Handle filter application
                    }
                }
            }
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
