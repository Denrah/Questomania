//
//  NavigationView.swift
//  Questomania
//
//  Created by National Team on 19.11.2022.
//

import SwiftUI

class NavigationView: UINavigationController {
  func push<T: View>(view: T) {
    let vc = UIHostingController<T>(rootView: view)
    pushViewController(vc, animated: true)
  }
}
