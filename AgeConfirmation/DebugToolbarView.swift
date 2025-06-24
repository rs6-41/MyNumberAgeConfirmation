import SwiftUI
import ProximityReader

struct DebugToolbarView: View {
    @EnvironmentObject var DebugSetting: DebugSettings
    @Binding var isDebugMenu: Bool
    @State var isDebugView = false
    @State var debugModeAlert = false
    @Environment(\.locale) var locale
    var body: some View {
        HStack {
            if isDebugView {
                Button(action: {
                    DebugSetting.DEBUG.toggle()
                }) {
                    Image(systemName: DebugSetting.DEBUG ? "ant.circle.fill": "ant.circle")
                        .font(.title2)
                        .foregroundStyle(DebugSetting.DEBUG ? .purple : .gray)
                }
            }
            if DebugSetting.DEBUG {
                Button(action: {
                    isDebugMenu.toggle()
                }) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundStyle(.purple)
                }
            }
        }.onAppear() {
            #if DEBUG
            isDebugView = true
            #endif
        }
        .onOpenURL { url in
            if url.absoluteString == "ageverifier://debug" {
                debugModeAlert = true
            }
        }
        .alert(LocalizedStringKey("#DebugmodeAlertTitle"), isPresented: $debugModeAlert) {
            Button(LocalizedStringKey("#OK"),role:.destructive) {
                isDebugView = true
                DebugSetting.DEBUG = true
            }
            Button(LocalizedStringKey("#Close"),role:.cancel) {
                isDebugView = false
                DebugSetting.DEBUG = false
            }
        } message: {
            Text("#DebugmodeAlertMessage")
        }
    }
}
