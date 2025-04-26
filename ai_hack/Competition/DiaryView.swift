//
//  DiaryView.swift
//  NTUiOSClubLLM
//
//  Created by 陳致和 on 2025/3/5.
//


import SwiftUI
import PhotosUI

struct DiaryView: View {
    @Environment(\.openRouter) private var openRouter
    @State private var isLoading: Bool = false
    @State private var userInput: String = "😃 Happy"
    @State private var aiResponse: String?
    
    // added:
    @State private var photosPickerItem: [PhotosPickerItem] = []
    @State private var photoModels:[PhotoModel] = []
    @State private var selectedFeeling: Feeling = .happy
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader{ proxy in
                ScrollView(.horizontal){
                    HStack(spacing: 16){
                        ForEach(photoModels){ photo in
                            VStack{
                                Image(uiImage: photo.uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: 8))
                                    .frame(maxWidth: proxy.size.width * 0.7)
                                
                                if let city = photo.placemark?.locality{
                                    Text(city).font(.caption)
                                }
                                
                                if let createdDate = photo.createdDate {
                                    Text(createdDate, format: .relative(presentation: .named))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                
            }.frame(maxHeight: 300)
            
            Text("How are you feeling today")
                .font(.title)
                .bold()
            Picker("Select a Feeling", selection: $selectedFeeling) {
                ForEach(Feeling.allCases) { feeling in
                    Text(feeling.rawValue).tag(feeling)
                }
            }
            .pickerStyle(.menu)
            .scaleEffect(1.5)
            .frame(width: 350, height: 60)
            .padding()
            .onChange(of: selectedFeeling) { _, newValue in
                            userInput = newValue.rawValue
                        }
            // TODO: 在這裡放入可以選多張圖片的 PhotosPicker
            HStack{
                PhotosPicker("Select Photo", selection: $photosPickerItem, maxSelectionCount: 3, matching: .images, photoLibrary: .shared())
                    .onChange(of: photosPickerItem){ _, newValue in
                        photoModels = []
                        
                        let ids = newValue.compactMap(\.itemIdentifier)
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
                        result.enumerateObjects { asset, _, _ in
                            Task{
                                guard let uiImage = await loadUIImage(from: asset, targetSize: .init(width: 512, height: 512))
                                        else { return }
                                let placemark = await asset.getPlacemark()
                                placemark?.printInfomration()
                                photoModels.append(PhotoModel(
                                    id: asset.localIdentifier,
                                    uiImage: uiImage,
                                    placemark: placemark,
                                    createdDate: asset.creationDate
                                    )
                                )
                            }
                        }
                            
                    }.padding()
                Button("Create Diary", action: sendRequest)
                    .buttonStyle(.borderedProminent)
                    .overlay {
                        ProgressView()
                            .opacity(isLoading ? 1 : 0)
                    }
                    .disabled(userInput.isEmpty)
                    .padding()
            }
            
            
            
            
            ScrollView{
                if let aiResponse {
                    Text(aiResponse)
                        .font(.title2)
                }
            }.frame(minHeight: 100)
        }
        .padding()
        .disabled(isLoading)
        .font(.title3.bold())
        .buttonStyle(.bordered)
    }
    struct PhotoModel: Identifiable {
        let id: String
        let uiImage: UIImage
        let placemark: CLPlacemark?
        let createdDate: Date?
    }
    
    func sendRequest() {
        guard !userInput.isEmpty, !isLoading else { return }
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            
            // TODO: 改放選中的圖片 & 放入 ChatMessage 中
            let images: [UIImage] = photoModels.map(\.uiImage)
            do {
                let response = try await openRouter.sendRequest(
                    model: .deepseek,
                    messages: [ChatMLMessage(role: .user,
                                             content: """
                        請依照使用者的心情：\(userInput)，以及所看到的照片寫一篇繁體中文短日記。
                        """,
                                             uiImages: images)],
                    temperature: 0.5,
                    maxTokens: 256
                )
                aiResponse = response.content
            } catch {
                print("發生錯誤")
            }
        }
    }
    
    /// 從 PhotosPickerItem 讀取 UIImage
    func loadUIImage(from item: PhotosPickerItem) async -> UIImage? {
        guard
            let data = try? await item.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else {
            print("無法讀取圖片 Data")
            return nil
        }
        return uiImage
    }
    
    /// 從 PHAsset 讀取 UIImage
    func loadUIImage(from asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode = .aspectFit) async -> UIImage? {
        await withCheckedContinuation { continuation in
            PHImageManager.default()
                .requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFit,
                    options: nil) { uiImage, info in
                        guard
                            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool,
                            !isDegraded
                        else {
                            return
                        }
                        continuation.resume(returning: uiImage)
                    }
        }
    }
    enum Feeling: String, CaseIterable, Identifiable {
            case happy = "😃 Happy"
            case sad = "😢 Sad"
            case excited = "🤩 Excited"
            case angry = "😡 Angry"
            case relaxed = "😌 Relaxed"
            
            var id: String { self.rawValue }
        }
}

//extension PHAsset {
//    /// 從經緯度反向讀取地點資訊，取得像是國家、街道等資訊
//    func getPlacemark(preferredLocale: Locale? = nil) async -> CLPlacemark? {
//        guard let location = location else { return nil }
//        let geocoder = CLGeocoder()
//        do {
//            let result = try await geocoder.reverseGeocodeLocation(location, preferredLocale: preferredLocale)
//            let placemark = result.first
//            return placemark
//        } catch {
//            print("無法讀取位址資訊 \(error)")
//            return nil
//        }
//    }
//}


//extension CLPlacemark {
//    /// 印出 Placemark 中提供的資訊，方便快速學習有什麼內容可用
//    func printInfomration() {
//        print("行政區域（省/州）: \(administrativeArea ?? "無資料")")
//        print("興趣點: \(areasOfInterest?.joined(separator: ", ") ?? "無相關地點")")
//        print("國家: \(country ?? "無資料")")
//        print("內陸水域: \(inlandWater ?? "無相關水域")")
//        print("國家代碼: \(isoCountryCode ?? "無資料")")
//        print("城市: \(locality ?? "無資料")")
//        print("高度（公尺）: \(location?.altitude.description ?? "無資料")")
//        print("航向（度數，相對於正北）: \(location?.course.description ?? "無資料")")
//        print("航向精確度（度數）: \(location?.courseAccuracy.description ?? "無資料")")
//        print("所在樓層: \(location?.floor?.description ?? "無資料")")
//        print("速度（公尺/秒）: \(location?.speed.description ?? "無資料")")
//        print("速度精確度（公尺/秒）: \(location?.speedAccuracy.description ?? "無資料")")
//        print("水平精確度（公尺）: \(location?.horizontalAccuracy.description ?? "無資料")")
//        print("垂直精確度（公尺）: \(location?.verticalAccuracy.description ?? "無資料")")
//        print("地點名稱: \(name ?? "無名稱")")
//        print("海洋: \(ocean ?? "無相關海域")")
//        print("郵遞區號: \(postalCode ?? "無郵遞區號")")
//        print("地理區域: \(region?.description ?? "無區域資料")")
//        print("子行政區域（縣/區）: \(subAdministrativeArea ?? "無資料")")
//        print("城市轄區: \(subLocality ?? "無資料")")
//        print("門牌號: \(subThoroughfare ?? "無門牌號")")
//        print("街道名稱: \(thoroughfare ?? "無街道資料")")
//        print("時區: \(timeZone?.identifier ?? "無時區資料")")
//    }
//}

#Preview {
    DiaryView()
       .environment(\.openRouter, .shared)
}
