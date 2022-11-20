//
//  PlayerView.swift
//  Questomania
//
//  Created by National Team on 20.11.2022.
//

import SwiftUI

struct PlayerView: View {
  @State var questStep: QuestStepNode
  @State var questionAnswer: String = ""
  @State var questionError = false
  @State var optionsError = false
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        switch questStep.step {
        case .empty:
          EmptyView()
        case .question(let text, let answer, let nextStep):
          VStack {
            HStack {
              Text(text)
              Spacer()
            }
            TextField("Ответ", text: $questionAnswer)
              .textFieldStyle(.roundedBorder)
            if questionError {
              HStack {
                Text("Неверный ответ").foregroundColor(.red)
                Spacer()
              }
            }
            Button {
              if questionAnswer.lowercased() == answer.lowercased() {
                questStep = nextStep
              } else {
                questionError = true
              }
            } label: {
              Spacer()
              Text("Ответить")
              Spacer()
            }.buttonStyle(BorderedButtonStyle())
          }.onAppear {
            questionAnswer = ""
            questionError = false
          }.id(questStep.id)
        case .options(let text, let options):
          VStack {
            HStack {
              Text(text)
              Spacer()
            }
            if optionsError {
              HStack {
                Text("Неверный ответ").foregroundColor(.red)
                Spacer()
              }.padding(.top, 8)
            }
            switch options {
            case .checking(let options, let nextStep):
              ForEach(options.indices, id: \.self) { index in
                Button {
                  if options[index].isCorrect {
                    questStep = nextStep
                  } else {
                    optionsError = true
                  }
                } label: {
                  Spacer()
                  Text(options[index].text)
                  Spacer()
                }.buttonStyle(BorderedButtonStyle())
              }
            case .branching(let options):
              ForEach(options.indices, id: \.self) { index in
                Button {
                  questStep = options[index].nextStep
                } label: {
                  Spacer()
                  Text(options[index].text)
                  Spacer()
                }.buttonStyle(BorderedButtonStyle())
              }
            }
          }.onAppear {
            optionsError = false
          }.id(questStep.id)
        case .ending(let text):
          HStack {
            Text(text)
            Spacer()
          }
          Text("Конец").padding(.top, 24)
        }
      }.padding(16)
    }
  }
}

