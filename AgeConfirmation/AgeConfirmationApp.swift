import SwiftUI
import ProximityReader

class DebugSettings: ObservableObject {
    @Published var DEBUG = false
    @Published var locale = 0
    @Published var colorScheme = 0
    @Published var sizeCategory = "large"
    @State var MNIDoptions:MobileNationalIDCardDisplayRequest.Options.ValidationMode = .confirm
}

@main
struct AgeConfirmationApp: App {
    @StateObject var DebugSetting = DebugSettings()
    @StateObject private var console = ConsoleLogger()

    @Environment(\.locale) var locale
    
    init() {
        //設定アプリでリンクを表示するための措置
            UserDefaults.standard.register(defaults: [
                "setting_openApp": " ",
                "reset_device_judment": " ",
                "setting_TermsofUse": " "
            ])
        
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DebugSetting)
                .debugLocale(DebugSetting,locale:locale)
                .debugColorScheme(DebugSetting)
                .environmentObject(console)
        }
    }
}

extension View {
    func debugLocale(_ index: DebugSettings, locale: Locale) -> some View {
        if index.DEBUG {
            switch index.locale {
            case 1:
                self.environment(\.locale, .init(identifier: "ja"))
            case 2:
                self.environment(\.locale, .init(identifier: "en"))
            case 3:
                self.environment(\.locale, .init(identifier: "zh_cn"))
            default:
                self.environment(\.locale, .init(identifier: locale.language.languageCode?.identifier ?? "ja"))
            }
        } else {
            self.environment(\.locale, .init(identifier: locale.language.languageCode?.identifier ?? "ja"))
        }
    }
    func debugColorScheme(_ index: DebugSettings) -> some View {
        switch index.colorScheme {
        case 1:
            return preferredColorScheme(.light)
        case 2:
            return preferredColorScheme(.dark)
        default:
            return preferredColorScheme(nil)
        }
    }
}
