//
//  QuestStep.swift
//  Questomania
//
//  Created by National Team on 18.11.2022.
//

import UIKit

struct Slide: Codable {
  let imageData: Data
  let text: String
  
  var image: UIImage? {
    UIImage(data: imageData)
  }
}

enum AnswerOptionType: Codable {
  case branching(nextStep: QuestStepNode)
  case checking(isCorrect: Bool)
}

struct AnswerOptionChecking: Codable {
  let text: String
  var isCorrect: Bool
}

struct AnswerOptionBranching: Codable {
  let text: String
  var nextStep: QuestStepNode
}

enum AnswerOptions: Codable {
  case checking(options: [AnswerOptionChecking], nextStep: QuestStepNode)
  case branching(options: [AnswerOptionBranching])
}

indirect enum QuestStep: Codable {
  case question(text: String, answer: String, nextStep: QuestStepNode)
  case options(text: String, options: AnswerOptions)
  case ending(text: String)
  case empty
  
  func settingNextStep(_ nextStep: QuestStepNode, branchingIndex: Int? = nil) -> QuestStep {
    switch self {
    case .question(let text, let answer, _):
      return .question(text: text, answer: answer, nextStep: nextStep)
    case .options(let text, let options):
      switch options {
      case .checking(let options, _):
        return .options(text: text, options: .checking(options: options, nextStep: nextStep))
      case .branching(let options):
        var newOptions = options
        if let branchingIndex = branchingIndex {
          newOptions[branchingIndex].nextStep = nextStep
        }
        return .options(text: text, options: .branching(options: newOptions))
      }
    case .ending(let text):
      return .ending(text: text)
    case .empty:
      return .empty
    }
  }
}

class QuestStepNode: Codable {
  var step: QuestStep
  var id: String
  var parent: QuestStepNode?
  
  enum CodingKeys: String, CodingKey {
    case step, id
  }
  
  var nextStep: QuestStepNode? {
    switch step {
    case .question(_, _, let nextStep):
      if case .empty = nextStep.step {
        return nil
      }
      return nextStep
    case .options(_, let options):
      if case .checking(_, let nextStep) = options {
        return nextStep
      }
      return nil
    case .ending:
      return nil
    case .empty:
      return nil
    }
  }
  
  internal init(step: QuestStep, id: String = UUID().uuidString) {
    self.step = step
    self.id = id
  }
}
