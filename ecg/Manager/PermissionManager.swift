//
//  PermissionManager.swift
//  ecg
//
//  Created by insung on 4/10/25.
//

import Foundation
import CoreBluetooth
import CoreLocation

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    @Published var allPermissionsGranted = false
    @Published var showSettings = false

    private var locationManager: CLLocationManager!
    private var bluetoothManager: CBCentralManager!

    private var locationAuthorized = false
    private var bluetoothAuthorized = false

    func checkAllPermissions() {
        // 블루투스 권한 요청
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        }
        // 위치 권한 요청
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
        }

        locationManager.requestWhenInUseAuthorization()

        // 블루투스 권한은 CBCentralManagerDelegate의 상태 확인으로 처리
    }

    // CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorized = (manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways)
        updatePermissionStatus()
    }

    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothAuthorized = (central.state == .poweredOn)
        updatePermissionStatus()
    }

    private func updatePermissionStatus() {
        allPermissionsGranted = locationAuthorized && bluetoothAuthorized

        if !allPermissionsGranted {
            showSettings = true
        }
    }
}
