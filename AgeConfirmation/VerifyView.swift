import SwiftUI
import ProximityReader
import PassKit

struct VerifyView: View {
    @Binding var isError: Bool
    @Binding var errorCode:Int
    @Binding var errorText:String
    @Binding var isSupported:Bool
    @Binding var adult:Int
    @Binding var checkdAge: Int
    @Binding var TermsofUseLink:String
    @Binding var isTermsofUse:Bool
    let ageList = [18, 20]
    @Environment(\.openURL) var openURL
    @State var Region:Locale.Region = .japan
    @EnvironmentObject var DebugSetting: DebugSettings
    @Binding var isDebugMenu:Bool
    
    var body: some View {
        //https://developer.apple.com/jp/design/human-interface-guidelines/id-verifier
        
        Spacer()
        Image(systemName: "person.text.rectangle")
            .font(.system(size: 60))
            .foregroundStyle(.red)
            .padding()
            .onTapGesture(count: 10) {
                DebugSetting.DEBUG = true
                isDebugMenu = true
            }
        Text(LocalizedStringKey("#MobileID"))
            .bold()
            .font(.title)
        Text(LocalizedStringKey("#MobileIDabout"))
            .padding(.horizontal)
        
        Button(action: {
            checkdAge = 0
            verifyButtonTapped()
        }) {
            Text(LocalizedStringKey("#VerifyAge"))
                .bold()
                .frame(width:300,height:40)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        
        .onOpenURL { url in
            if url.absoluteString == "ageverifier://scan" {
                checkdAge = 0
                verifyButtonTapped()
            }
        }
        
        Picker(LocalizedStringKey("#AdultAges"), selection: $adult) {
            ForEach(ageList, id: \.self) { age in
                Text(LocalizedStringKey("\(String(age))old")).tag(age)
            }
            if !ageList.contains(adult) {
                Text(LocalizedStringKey("\(String(adult))old")).tag(adult)
            }
        }
        Spacer()
        Text(LocalizedStringKey("#AgeMobileIDprivacy"))
            .onOpenURL { url in
                if url.absoluteString == "ageverifier://terms" {
                    isTermsofUse.toggle()
                }
            }
            .padding([.leading, .bottom, .trailing])
            .font(.caption)
    }
    
    func verifyButtonTapped() {
        Task {
            // デバイスがモバイル文書の読み取りをサポートしているか確認
            guard MobileDocumentReader.isSupported else {
                errorCode = 1
                isSupported = false
                isError.toggle()
                
                return
            }
            
            do {
                try await self.verifyAge()
            } catch MobileDocumentReaderError.cancelled {
                //キャンセル
                errorCode = 2
                isError.toggle()
            } catch {
                errorText = String(localized: "#ReadingError\(error.localizedDescription)")
            }
        }
    }
    
    //読み取り処理
    private func verifyAge() async throws {
        print("スキャン開始")
        if MobileNationalIDCardDisplayRequest.isSupportedRegion(Region) {
            var MNIDoptions = MobileNationalIDCardDisplayRequest.Options(
                validationMode: DebugSetting.MNIDoptions
            )
            let request = MobileNationalIDCardDisplayRequest(
                region: .japan,
                elements: [.ageAtLeast(adult)],
                options: MNIDoptions
            )
            let reader = MobileDocumentReader()
            let readerSession = try await reader.prepare()
            let response = try await readerSession.requestDocument(request)
        } else {
            errorCode = 4
        }
    }

}

#Preview {
    VerifyView(isError: .constant(false), errorCode: .constant(0), errorText: .constant(""), isSupported: .constant(false), adult: .constant(18), checkdAge: .constant(18), TermsofUseLink: .constant("https://apple.com"), isTermsofUse: .constant(false), isDebugMenu: .constant(false))
}
