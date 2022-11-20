//
//  EditorService.swift
//  Questomania
//
//  Created by National Team on 19.11.2022.
//

import Foundation

class EditorService {
  static let shared = EditorService()
  
  var questRoot: QuestStepNode?
  var currentStep: QuestStepNode?
  
  private init() {
    
  }
  
  func createQuest(startStep: QuestStep) {
    questRoot = QuestStepNode(step: startStep)
    currentStep = questRoot
  }
  
  func saveQuest(name: String) {
    guard let questRoot = questRoot else { return}
    guard let data = try? JSONEncoder().encode(questRoot) else { return }
    
    let path = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(name)
    try? data.write(to: path)
  }
  
  func getQuests() -> [(name: String, quest: QuestStepNode, file: URL)] {
    let path = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0]
    if let directoryContents = try? FileManager.default.contentsOfDirectory(
      at: path,
      includingPropertiesForKeys: nil
    ) {
      return directoryContents.compactMap { url in
        let name = url.lastPathComponent
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let quest = try? JSONDecoder().decode(QuestStepNode.self, from: data) else { return nil }
        return (name: name, quest: quest, file: url)
      }
    }
    return []
  }
}
