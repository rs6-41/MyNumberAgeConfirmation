//https://github.com/arasan01/WorkThrough_SwiftUI
import SwiftUI

struct Cell: Identifiable {
    var id = UUID()
    var icon: String
    var headline: String
    var discription: String
}

struct NewContentView: View {
    @Binding var cells:[Cell]
    @Binding var title:String
    @Binding var isOpen:Bool
    @Environment(\.openURL) var openURL
    @Binding var isTermsofUse:Bool
    @Binding var isTermsofUseButton:Bool
    var body: some View {
        VStack {
            ScrollView {
                Spacer()
                    .frame(height: 55)
                Text(title)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
                    .frame(height: 50)
                VStack(alignment: .leading, spacing: 40) {
                    ForEach(cells) { cell in
                        HStack(spacing: 20) {
                            Group {
                                Image(systemName: "\(cell.icon)")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                            }.frame(width:45)
                            VStack(alignment: .leading) {
                                Text(cell.headline)
                                    .font(.headline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(cell.discription)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }.frame(maxWidth: .infinity)
                        }.padding(.horizontal)
                    }
                }.padding(.horizontal)
            }
            Spacer()
            Button(action: {
                isOpen.toggle()
            }) {
                Text(LocalizedStringKey("#Continue"))
                    .bold()
                    .frame(width:300,height:40)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            if isTermsofUseButton {
                Button {
                    isOpen = false
                    isTermsofUse = true
                } label: {
                    Text(LocalizedStringKey("#TermsofUse"))
                }.padding(.bottom)
            }
        }
    }
}
