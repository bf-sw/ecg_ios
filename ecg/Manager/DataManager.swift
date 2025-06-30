//
//  DataManager.swift
//  ecg
//
//  Created by insung on 6/25/25.
//

import SwiftUI

class DataManager {
    static let shared = DataManager()
    private var documentDelegate: UIDocumentPickerDelegate?
    
    private func makeCSV(from waveforms: [Waveform]) -> String {
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
    
    func saveData(_ waveforms: [Waveform]) {
        guard let last = waveforms.last else { return }

        let timestamp = Int(last.measureDate.timeIntervalSince1970)
        let key = "waveform_\(timestamp)"
        do {
            let data = try JSONEncoder().encode(waveforms)
            UserDefaults.standard.set(data, forKey: key)
            appendSavedDataKeys(key)
            print("✅ waveforms 저장 완료: \(key)")
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }
    
    func loadData(for key: String) -> [Waveform]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let decoder = JSONDecoder()
            let waveforms = try decoder.decode([Waveform].self, from: data)
            return waveforms
        } catch {
            print("❌ 불러오기 실패: \(error)")
            return nil
        }
    }
    
    func appendSavedDataKeys(_ key: String) {
        var keys = UserDefaults.standard.stringArray(forKey: "waveform_keys") ?? []
        if !keys.contains(key) {
            keys.append(key)
            UserDefaults.standard.set(keys, forKey: "waveform_keys")
        }
    }
    
    func getAllDataKeys() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "waveform_keys") ?? []
    }
    
    func exportCSVFile(from waveforms: [Waveform]) {
        let csv = makeCSV(from: waveforms)
        guard let fileName = waveforms.last?.measureDate.fileName() else {
            return
        }

        // 임시 파일로 먼저 저장
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            presentShareController(from: tempURL)
        } catch {
            PopupManager.shared.hideLoading()
            ToastManager.shared.show(message: "저장에 실패하였습니다.\n\(error)")
            return
        }
    }

    func presentShareController(from url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
            
        // iPad 대응: popover 위치 설정
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
