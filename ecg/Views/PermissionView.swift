//
//  PermissionView.swift
//  ecg
//
//  Created by insung on 4/9/25.
//

import SwiftUI

struct PermissionView: View {
    @StateObject var permissionManager = PermissionManager()
    
    var body: some View {
        VStack(spacing: 48) {
            // 상단 안내 타이틀
            VStack(alignment: .center, spacing: 24) {
                Text("permission_title")
                    .font(.headerFont)
                    .foregroundColor(.onBackgroundColor)
                
                Text("permission_subtitle")
                    .multilineTextAlignment(.center)
                    .font(.subtitleFont)
                    .foregroundColor(.onBackgroundColor)
            }
            
            Spacer()

            // 접근 권한 항목
            HStack(alignment: .top, spacing: 60) {
                // 필수 항목
                VStack(alignment: .leading, spacing: 24) {
                    Text("essential_permission_title")
                        .font(.subtitleFont)
                        .foregroundColor(.primaryColor)

                    HStack(spacing: 8) {
                        Image(uiImage: UIImage(named: "ic_bluetooth")!)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("bluetooth")
                                .font(.subtitleFont)
                                .foregroundColor(.primaryColor)
                            Text("bluetooth_for_connect")
                                .font(.desciptionFont)
                                .foregroundColor(.secondaryColor)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(uiImage: UIImage(named: "ic_location")!)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("location_service")
                                .font(.subtitleFont)
                                .foregroundColor(.primaryColor)
                            Text("location_for_connect")
                                .font(.desciptionFont)
                                .foregroundColor(.secondaryColor)
                        }
                    }
                }
                
                Divider()
                    .background(Color.outlineColor)
                    .frame(maxHeight: .infinity)
                
                // 선택 항목
                VStack(alignment: .leading, spacing: 24) {
                    Text("optional_permission_title")
                        .font(.subtitleFont)
                        .foregroundColor(.primaryColor)

                    HStack(spacing: 8) {
                        Image(uiImage: UIImage(named: "ic_bell")!)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("push_service")
                                .font(.subtitleFont)
                                .foregroundColor(.primaryColor)
                            Text("push_service_provide")
                                .font(.desciptionFont)
                                .foregroundColor(.secondaryColor)
                        }
                    }
                }
            }
            Spacer()

            // 안내 문구
            VStack(alignment: .leading, spacing: 8) {
                Text("service_provide_description1")
                Text("service_provide_description2")
            }
            .font(.desciptionFont)
            .foregroundColor(.secondaryColor)

            
            // 계속 버튼
            Button(action: {
                if permissionManager.allPermissionsGranted == false {
                   permissionManager.checkAllPermissions()
                }
            }) {
                Text("계속")
                    .frame(maxWidth: 440)
                    .padding()
                    .foregroundColor(.backgroundColor)
            }
            .background(Color.primaryColor)
            .cornerRadius(12)
        }.fullScreenCover(isPresented: $permissionManager.allPermissionsGranted) {
            ContentView()
        }.transaction({ transaction in
            transaction.disablesAnimations = true
        })
        .padding(24)
    }
}
#Preview {
    PermissionView()
}
