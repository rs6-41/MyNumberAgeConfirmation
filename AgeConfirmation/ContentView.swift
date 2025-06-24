import SwiftUI
import ProximityReader
import LocalAuthentication

struct ContentView: View {
    @State var isError: Bool = false
    @State var errorCode = 0
    @State var errorText = ""
    @AppStorage("isSupported") var isSupported = true
    @AppStorage("adult") var adult = 18
    @State var isDebugMenu = false
    @State var checkdAge = 0
    @State var isLock = true
    @EnvironmentObject var DebugSetting: DebugSettings
    @State var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    @State var build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    @State var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    @State var isTermsofUse = false
    
    @State var setting_reset_device_judment = UserDefaults.standard.bool(forKey: "setting_reset_device_judment")
    
    @AppStorage("isWatsNew1.0") var isWatsNew = true
    @AppStorage("isFast") var isFast = true
    @State var tutorials = [
        Cell(icon:"person.text.rectangle",headline:String(localized: "#TutorialMyNumberCard"),discription: String(localized:"#TutorialMyNumberCarddiscription")),
        Cell(icon:"person.circle",headline:String(localized: "#Tutorialcertainty"),discription: String(localized:"#TutorialCertaintydiscription")),
        Cell(icon:"lock.shield",headline:String(localized: "#TutorialPrivacy"),discription: String(localized:"#TutorialPrivacydiscription")),
    ]
    @State var TermsofUseLink = "https://rs6-41.github.io/ID/kiyaku/"
    @State var warning = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if isSupported  {
                        VerifyView(isError: $isError, errorCode: $errorCode, errorText: $errorText, isSupported: $isSupported, adult: $adult, checkdAge: $checkdAge, TermsofUseLink: $TermsofUseLink, isTermsofUse: $isTermsofUse,isDebugMenu: $isDebugMenu)
                    } else {
                        VStack {
                            Image(systemName: "iphone.slash")
                                .font(.system(size: 80))
                                .padding()
                            Text(LocalizedStringKey("#UnsupportedDevice"))
                        }
                        .foregroundStyle(.gray)
                    }
                }
                .sheet(isPresented: $isFast, content: {
                    NewContentView(cells: $tutorials, title: .constant(String(localized:"#TutorialTitle")), isOpen: $isFast,isTermsofUse:$isTermsofUse,isTermsofUseButton: .constant(true))
                })
                .sheet(isPresented: $isTermsofUse, content: {
                    SafariView(url: URL(string: TermsofUseLink)!)
                })
                .toolbar() {
                    if isDebugMenu {
                        ToolbarItem(placement: .cancellationAction) {
                            DebugToolbarView(isDebugMenu: $isDebugMenu)
                        }
                    }
                }
                .navigationTitle(DebugSetting.DEBUG ? "DebugMode \(version)(\(build))" : LocalizedStringKey("#VerifyAgeTitle"))
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isDebugMenu, content: {
                    DebugView(isSupported: $isSupported,adult: $adult,isWatsNew: $isWatsNew,isFast:$isFast)
                })
            }
        }.onAppear() {
            warning = true
        }
        .alert(isPresented: $warning) {
            Alert(title: Text(LocalizedStringKey("#Warning")), message: Text(LocalizedStringKey("#WarningMessage")), primaryButton: .default(Text(LocalizedStringKey("#OK"))) {
                setting_reset_device_judment = true
            }, secondaryButton: .cancel() {
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                            exit(0)
                        }

            })
        }
        .onOpenURL { url in
            if url.absoluteString == "ageverifier://reset_device_judment" {
                isSupported = true
            }
        }
        .alert(LocalizedStringKey("#error"),isPresented: $isError) {
        } message: {
            switch errorCode {
            case 1:
                Text(LocalizedStringKey("#UnsupportedDevice"))
            case 2:
                Text(LocalizedStringKey("#CancelScan"))
                //case3削除済み（生体認証ロックに関するエラー）
            case 4:
                Text(LocalizedStringKey("#NotSupportRegion"))
            default:
                Text(errorText)
            }
        }
    }
}

#Preview {
    ContentView()
}
