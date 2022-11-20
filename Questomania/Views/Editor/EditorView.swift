//
//  EditorView.swift
//  Questomania
//
//  Created by National Team on 20.11.2022.
//

import SwiftUI

struct EditorView: View {
  @State var currentStep: QuestStepNode?
  @State var question = ""
  @State var answer = ""
  @State var endingText = ""
  @State var branches: [AnswerOptionBranching] = []
  @State var checkOptions: [AnswerOptionChecking] = []
  @State var branchingQuestion = ""
  @State var checkingQuestion = ""
  @State var checkingOption = ""
  @State var branchingOption = ""
  @State var branchingNavOptionIndex: Int?
  
  
  @State var stepCreateActionShown = false
  @State var saveSheetShown = false
  @State var questName = ""
  
  init() {
    currentStep = EditorService.shared.currentStep
  }
  
  var body: some View {
    VStack {
      if currentStep != nil {
          VStack {
        HStack {
          if currentStep?.parent != nil {
            Button("\(Image(systemName: "chevron.left"))Назад") {
              EditorService.shared.currentStep = currentStep?.parent
              currentStep = EditorService.shared.currentStep
            }.buttonStyle(BorderedButtonStyle())
          }
          if let nextStep = currentStep?.nextStep {
            Button("Вперед\(Image(systemName: "chevron.right"))") {
              EditorService.shared.currentStep = nextStep
              currentStep = EditorService.shared.currentStep
            }.buttonStyle(BorderedButtonStyle())
          }
          Spacer()
          Button("Сохранить квест") {
            questName = ""
            saveSheetShown = true
          }.buttonStyle(BorderedButtonStyle())
        }.sheet(isPresented: $saveSheetShown) {
          TextField("Название квеста", text: $questName)
          Button("Сохранить") {
            EditorService.shared.saveQuest(name: questName)
          }.disabled(questName.isEmpty)
        }
        Divider()
      }.padding(.bottom, 16)
    }
      if let currentStep = currentStep {
        switch currentStep.step {
        case .question(let text, let answer, let nextStep):
          questionStep(initQuestion: text, initAnswer: answer, nextStep: nextStep)
        case .ending(let text):
          endingStep(text: text)
        case .options(let text, let options):
          switch options {
          case .checking(let options, let nextStep):
            choosingStep(text: text, checkOptions: options, nextStep: nextStep)
          case .branching(let options):
            branchingStep(text: text, branches: options)
          }
        default:
          EmptyView()
        }
      } else {
        startStep()
      }
    }.padding(16).confirmationDialog("Добавить шаг", isPresented: $stepCreateActionShown) {
      Button("Вопрос с ответом") {
        let nextStep = QuestStepNode(step: .question(text: "", answer: "", nextStep: .init(step: .empty)))
        nextStep.parent = EditorService.shared.currentStep
        EditorService.shared.currentStep?.step = EditorService.shared.currentStep?.step.settingNextStep(nextStep, branchingIndex: branchingNavOptionIndex) ?? .empty
        EditorService.shared.currentStep = nextStep
        question = ""
        answer = ""
        currentStep = EditorService.shared.currentStep
        stepCreateActionShown = false
        branchingNavOptionIndex = nil
      }
      Button("Ветвление сюжета") {
        let nextStep = QuestStepNode(step: .options(text: "", options: .branching(options: [])))
        nextStep.parent = EditorService.shared.currentStep
        EditorService.shared.currentStep?.step = EditorService.shared.currentStep?.step.settingNextStep(nextStep, branchingIndex: branchingNavOptionIndex) ?? .empty
        EditorService.shared.currentStep = nextStep
        branches = []
        branchingQuestion = ""
        branchingOption = ""
        currentStep = EditorService.shared.currentStep
        stepCreateActionShown = false
        branchingNavOptionIndex = nil
      }
      Button("Выбор правильного ответа") {
        let nextStep = QuestStepNode(step: .options(text: "", options: .checking(options: [], nextStep: .init(step: .empty))))
        nextStep.parent = EditorService.shared.currentStep
        EditorService.shared.currentStep?.step = EditorService.shared.currentStep?.step.settingNextStep(nextStep, branchingIndex: branchingNavOptionIndex) ?? .empty
        EditorService.shared.currentStep = nextStep
        currentStep = EditorService.shared.currentStep
        checkOptions = []
        checkingQuestion = ""
        checkingOption = ""
        stepCreateActionShown = false
        branchingNavOptionIndex = nil
      }
      Button("Концовка") {
        let nextStep = QuestStepNode(step: .ending(text: ""))
        nextStep.parent = EditorService.shared.currentStep
        EditorService.shared.currentStep?.step = EditorService.shared.currentStep?.step.settingNextStep(nextStep, branchingIndex: branchingNavOptionIndex) ?? .empty
        EditorService.shared.currentStep = nextStep
        endingText = ""
        currentStep = EditorService.shared.currentStep
        stepCreateActionShown = false
        branchingNavOptionIndex = nil
      }
      Button("Отмена", role: .cancel) {
        stepCreateActionShown = false
        branchingNavOptionIndex = nil
      }
    }
  }
  
  
  @ViewBuilder
  func startStep() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 16) {
        HStack {
          Text("Выберите первый шаг:")
            .font(.title)
          Spacer()
        }.padding(.bottom, 16)
        Button {
          EditorService.shared.createQuest(startStep: .question(text: "", answer: "", nextStep: .init(step: .empty)))
          currentStep = EditorService.shared.currentStep
        } label: {
          Spacer()
          Text("Вопрос с ответом")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
          .tint(.blue)
        Button {
          EditorService.shared.createQuest(startStep: .options(text: "", options: .branching(options: [])))
          currentStep = EditorService.shared.currentStep
        } label: {
          Spacer()
          Text("Ветвление сюжета")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
          .tint(.blue)
        Button {
          EditorService.shared.createQuest(startStep: .options(text: "", options: .checking(options: [], nextStep: .init(step: .empty))))
          currentStep = EditorService.shared.currentStep
        } label: {
          Spacer()
          Text("Выбор правильного ответа")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
          .tint(.blue)
      }
    }
  }
  
  @ViewBuilder
  func questionStep(initQuestion: String, initAnswer: String, nextStep: QuestStepNode) -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        TextField("Вопрос", text: $question)
          .textFieldStyle(.roundedBorder)
        TextField("Ответ", text: $answer)
          .textFieldStyle(.roundedBorder)
        HStack {
          Button("Сохранить") {
            EditorService.shared.currentStep?.step = .question(text: question, answer: answer, nextStep: nextStep)
          }.buttonStyle(BorderedButtonStyle())
          Button("Добавить переход") {
            EditorService.shared.currentStep?.step = .question(text: question, answer: answer, nextStep: nextStep)
            stepCreateActionShown = true
          }.buttonStyle(BorderedButtonStyle())
          Spacer()
        }
      }
    }.onAppear {
      question = initQuestion
      answer = initAnswer
    }.id(currentStep?.id ?? "")
  }
  
  @ViewBuilder
  func branchingStep(text: String, branches: [AnswerOptionBranching]) -> some View {
    ScrollView {
      VStack {
        TextField("Вопрос", text: $branchingQuestion)
          .textFieldStyle(.roundedBorder)
          .padding(.bottom, 16)
        ForEach(self.branches.indices, id: \.self) { index in
          VStack {
            Text(self.branches[index].text)
            Spacer()
            Button {
              EditorService.shared.currentStep?.step = .options(text: branchingQuestion, options: .branching(options: self.branches))
              branchingNavOptionIndex = index
              stepCreateActionShown = true
            } label: {
              Spacer()
              Text("Добавить переход")
              Spacer()
            }.buttonStyle(BorderedButtonStyle())
            HStack {
              Button {
                self.branches.remove(at: index)
              } label: {
                Spacer()
                Text("Удалить").foregroundColor(.red)
                Spacer()
              }.buttonStyle(BorderedButtonStyle())

              if let nextStep = self.branches[index].nextStep {
                switch nextStep.step {
                case .empty:
                  EmptyView()
                default:
                  Button {
                    EditorService.shared.currentStep = nextStep
                    currentStep = EditorService.shared.currentStep
                  } label: {
                    Spacer()
                    Text("Вперед")
                    Spacer()
                  }.buttonStyle(BorderedButtonStyle())
                }
              }
            }
          }.padding(16).background(Color.blue.opacity(0.05)).cornerRadius(8)
        }
        TextField("Вариант ответа", text: $branchingOption)
          .textFieldStyle(.roundedBorder)
        Button {
          self.branches.append(.init(text: branchingOption, nextStep: .init(step: .empty)))
          branchingOption = ""
        } label: {
          Spacer()
          Text("Добавить вариант")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
          .padding(.bottom, 24)
          .disabled(branchingOption.isEmpty)
        Button {
          EditorService.shared.currentStep?.step = .options(text: branchingQuestion, options: .branching(options: self.branches))
        } label: {
          Spacer()
          Text("Сохранить")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
      }.padding(.vertical, 8)
    }.onAppear {
      self.branchingQuestion = text
      self.branches = branches
      self.branchingOption = ""
    }.id(currentStep?.id ?? "")
  }
  
  @ViewBuilder
  func choosingStep(text: String, checkOptions: [AnswerOptionChecking], nextStep: QuestStepNode) -> some View {
    ScrollView {
      VStack {
        TextField("Вопрос", text: $checkingQuestion)
          .textFieldStyle(.roundedBorder)
          .padding(.bottom, 16)
        ForEach(self.checkOptions.indices, id: \.self) { index in
          VStack {
            Text(self.checkOptions[index].text)
            Button {
              for ind in self.checkOptions.indices {
                self.checkOptions[ind].isCorrect = false
              }
              self.checkOptions[index].isCorrect = true
            } label: {
              Spacer()
              Text("Отметить правильным")
              Spacer()
            }.buttonStyle(BorderedButtonStyle())
            Button {
              self.checkOptions.remove(at: index)
            } label: {
              Spacer()
              Text("Удалить").foregroundColor(.red)
              Spacer()
            }.buttonStyle(BorderedButtonStyle())
          }.padding(16).background(self.checkOptions[index].isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)).cornerRadius(8)
        }
        TextField("Вариант", text: $checkingOption)
          .textFieldStyle(.roundedBorder)
        Button {
          self.checkOptions.append(.init(text: checkingOption, isCorrect: false))
          checkingOption = ""
        } label: {
          Spacer()
          Text("Добавить вариант")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
          .padding(.bottom, 24)
          .disabled(checkingOption.isEmpty)
        Button {
          EditorService.shared.currentStep?.step = .options(text: checkingQuestion, options: .checking(options: self.checkOptions, nextStep: nextStep))
          stepCreateActionShown = true
        } label: {
          Spacer()
          Text("Добавить переход")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
        Button {
          EditorService.shared.currentStep?.step = .options(text: checkingQuestion, options: .checking(options: self.checkOptions, nextStep: nextStep))
        } label: {
          Spacer()
          Text("Сохранить")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
      }
    }.onAppear {
      self.checkingQuestion = text
      self.checkOptions = checkOptions
      self.checkingOption = ""
    }.id(currentStep?.id ?? "")
  }
  
  @ViewBuilder
  func endingStep(text: String) -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        TextField("Текст", text: $endingText)
          .textFieldStyle(.roundedBorder)
        Button {
          EditorService.shared.currentStep?.step = .ending(text: endingText)
        } label: {
          Spacer()
          Text("Сохранить")
          Spacer()
        }.buttonStyle(BorderedButtonStyle())
      }
    }.onAppear {
      endingText = text
    }.id(currentStep?.id ?? "")
  }
}

struct EditorView_Previews: PreviewProvider {
  static var previews: some View {
    EditorView()
  }
}
