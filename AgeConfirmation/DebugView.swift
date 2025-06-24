import SwiftUI
import ProximityReader
import Combine

struct DebugView: View {
    @Binding var isSupported:Bool
    @Binding var adult:Int
    @Binding var isWatsNew:Bool
    @Binding var isFast:Bool
    @State var isConsole = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var DebugSetting: DebugSettings
    @EnvironmentObject var console: ConsoleLogger
    @State var MNIDoptions = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section("デバッグ") {
                    Toggle(isOn: $isSupported) {
                        Text("ID認証のサポート (UI)")
                    }
                    HStack {
                        Text("年齢要件")
                        + Text("(\(adult)歳)")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        Stepper(value: $adult, step: 1) {
                        }
                    }
                    HStack {
                        Picker("リーダー検証モード",selection:$MNIDoptions) {
                            Text("単一").tag(0)
                            Text("複数").tag(1)
                            Text("検証").tag(2)
                        }
                        .onChange(of: MNIDoptions) {
                            switch MNIDoptions {
                            case 0:
                                DebugSetting.MNIDoptions = .check
                            case 1:
                                DebugSetting.MNIDoptions = .checkMultiple
                            case 2:
                                DebugSetting.MNIDoptions = .confirm
                            default:
                                DebugSetting.MNIDoptions = .check
                            }
                        }
                    }
                    HStack {
                        Text("チュートリアル")
                        Spacer()
                        Button("テスト") {
                            isFast.toggle()
                        }.foregroundStyle(.tint)
                    }
                    HStack {
                        Text("バージョン情報")
                        Spacer()
                        Button("テスト") {
                            isWatsNew.toggle()
                        }.foregroundStyle(.tint)
                    }
                }
                Section("UIテスト") {
                    Picker("カラースキーム", selection: $DebugSetting.colorScheme) {
                        Text("システム").tag(0)
                        Text("ライト").tag(1)
                        Text("ダーク").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("言語", selection: $DebugSetting.locale) {
                        Text("システム").tag(0)
                        Text("日本語").tag(1)
                        Text("英語").tag(2)
                        Text("簡体中国語").tag(3)
                    }
                }
                
                Section("コンソール",isExpanded: $isConsole) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack(alignment: .topLeading) {
                                    Color.black
                                        .frame(maxWidth:.infinity,maxHeight:.infinity)
                                        .edgesIgnoringSafeArea(.all)
                                    Text(console.fullLog)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .textSelection(.enabled)
                                        .padding(5)
                                }
                                Text("") // dummy bottom anchor
                                    .frame(height: 1)
                                    .id("BOTTOM")
                            }
                        }
                        .background(Color.black)
                        .frame(height: 300)
                        .onChange(of: console.fullLog) { _ in
                            withAnimation {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            }
                        }
                    }
                    Button("テスト") {
                        print("test")
                    }
                }
                
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "unknown")")
                            .textSelection(.enabled)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        Text("ビルド番号")
                        Spacer()
                        Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "unknown")")
                            .textSelection(.enabled)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        Text("OS")
                        Spacer()
                        Text("\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                            .textSelection(.enabled)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        Text("デバイス名")
                        Spacer()
                        Text(modelIdentifier())
                            .textSelection(.enabled)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle("DEBUG MENU")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar() {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button("閉じる") {
                        dismiss()
                    }.bold()
                })
            }
            .listStyle(.sidebar)
        }
    }
    func modelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
    }
}

//コンソール
@MainActor
class ConsoleLogger: ObservableObject {
    @Published var fullLog = ""

    private var outputPipe = Pipe()
    private var errorPipe = Pipe()

    init() {
        // stdout をリダイレクト
        dup2(outputPipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

        // stderr をリダイレクト
        dup2(errorPipe.fileHandleForWriting.fileDescriptor, fileno(stderr))

        // stdout の監視
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                Task { @MainActor in
                    self?.fullLog += "[STDOUT] \(text)"
                }
            }
        }

        // stderr の監視（NSLog やシステムエラーなど）
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                Task { @MainActor in
                    self?.fullLog += "[STDERR] \(text)"
                }
            }
        }
    }

    deinit {
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
    }
}
