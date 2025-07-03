//
//  DataManager.swift
//  ecg
//
//  Created by insung on 6/25/25.
//

import SwiftUI

class DataManager {
    static let shared = DataManager()

    // MARK: - CSV 변환
    private func makeCSV(from waveforms: [WaveformModel]) -> String {
        var csv = "Index,Lead1,Lead2,Lead3,AVR,AVL,AVF\n"
        for (index, waveform) in waveforms.enumerated() {
            let lead3 = waveform.calculateLead3()
            let avr = waveform.calculateAVR()
            let avl = waveform.calculateAVL()
            let avf = waveform.calculateAVF()
            csv += "\(index),\(waveform.lead1),\(waveform.lead2),\(lead3),\(avr),\(avl),\(avf)\n"
        }
        return csv
    }

    // MARK: - 일반 기록용 저장
    func saveRecordedData(_ waveforms: [WaveformModel]) {
        guard let last = waveforms.last else { return }

        let timestamp = Int(last.measureDate.timeIntervalSince1970)
        let key = "recorded_waveform_\(timestamp)"
        do {
            let data = try JSONEncoder().encode(waveforms)
            UserDefaults.standard.set(data, forKey: key)
            appendSavedDataKeys(key, listKey: "recorded_waveform_keys")
            print("✅ 기록용 waveforms 저장 완료: \(key)")
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }
    
    func loadRecordedData(for key: String) -> [WaveformModel]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode([WaveformModel].self, from: data)
        } catch {
            print("❌ 기록용 불러오기 실패: \(error)")
            return nil
        }
    }
    
    func deleteRecordedData(for keys: [String]) {
        var savedKeys = getAllRecordedKeys()
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
            savedKeys.removeAll { $0 == key }
            print("🗑️ 삭제 완료: \(key)")
        }
    }


    func getAllRecordedKeys() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "recorded_waveform_keys") ?? []
    }

    // MARK: - 이벤트용 저장
    func saveEventData(_ waveforms: [WaveformModel]) {
        guard let last = waveforms.last else { return }

        let timestamp = Int(last.measureDate.timeIntervalSince1970)
        let key = "event_waveform_\(timestamp)"
        do {
            let data = try JSONEncoder().encode(waveforms)
            UserDefaults.standard.set(data, forKey: key)
            appendSavedDataKeys(key, listKey: "event_waveform_keys")
            print("✅ 이벤트용 waveforms 저장 완료: \(key)")
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }

    func loadEventData(for key: String) -> [WaveformModel]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode([WaveformModel].self, from: data)
        } catch {
            print("❌ 이벤트용 불러오기 실패: \(error)")
            return nil
        }
    }

    func getAllEventKeys() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "event_waveform_keys") ?? []
    }

    // MARK: - 저장 키 관리
    private func appendSavedDataKeys(_ key: String, listKey: String) {
        var keys = UserDefaults.standard.stringArray(forKey: listKey) ?? []
        if !keys.contains(key) {
            keys.append(key)
            UserDefaults.standard.set(keys, forKey: listKey)
        }
    }
    
    func exportCSVFiles(from items: [MeasurementModel]) {
        var fileURLs: [URL] = []

        for item in items {
            guard let last = item.waveforms.last else { continue }
            let fileName = last.measureDate.fileName()
            let csv = makeCSV(from: item.waveforms)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                try csv.write(to: tempURL, atomically: true, encoding: .utf8)
                fileURLs.append(tempURL)
            } catch {
                print("❌ CSV 저장 실패: \(error)")
            }
        }

        if !fileURLs.isEmpty {
            presentShareController(from: fileURLs)
        }
    }

    func presentShareController(from urls: [URL]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        DispatchQueue.main.async {
            topVC.present(activityVC, animated: true)
        }
    }
}
