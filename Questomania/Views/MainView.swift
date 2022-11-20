//
//  MainView.swift
//  Questomania
//
//  Created by National Team on 20.11.2022.
//

import SwiftUI

struct MainView: View {
  @State var quests: [(name: String, quest: QuestStepNode, file: URL)] = []
  
  func loadData() {
    quests = EditorService.shared.getQuests()
  }
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack {
        VStack {
          Button {
            pushViewToNavigation(EditorView())
          } label: {
            Spacer()
            Text("\(Image(systemName: "plus")) Создать квест")
            Spacer()
          }.buttonStyle(BorderedButtonStyle())
          Button {
            selectFile()
          } label: {
            Spacer()
            Text("\(Image(systemName: "tray.and.arrow.up")) Открыть квест")
            Spacer()
          }.buttonStyle(BorderedButtonStyle())
          Spacer()
        }.padding(.bottom, 8)
        HStack {
          Text("Квесты:")
            .font(.title)
          Spacer()
        }
        ForEach(quests.indices, id: \.self) { index in
          HStack {
            Text(quests[index].name)
            Spacer()
            Button("\(Image(systemName: "square.and.arrow.up")) Поделиться") {
              shareFile(quests[index].file)
            }
          }.padding(16).background(Color.blue.opacity(0.05)).cornerRadius(8).onTapGesture {
            pushViewToNavigation(PlayerView(questStep: quests[index].quest))
          }
        }
      }.padding(16)
    }.onAppear {
      loadData()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
