//
//  DemoViewController.swift
//  CustomizableTextFieldDemo
//
//  Created by Daisy Ramos on 2/22/21.
//

import UIKit
import Combine

/// `UIViewController` to display the `CustomizableTextField` demo.
final class DemoViewController: UIViewController {

    @IBOutlet private weak var customTextField: CustomizableTextField!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customTextField.rightAccessoryButtonEnabled.sink { [weak self] isSelected in
            guard let self = self else {
                return
            }
            self.customTextField.viewModel?.rightView?.image = isSelected ? .unlocked : .locked
            self.customTextField.isSecureTextEntry = !isSelected
        }
        .store(in: &cancellables)
    }
}

private extension UIImage {
    static let unlocked: UIImage! = UIImage(systemName: "lock.shield")
    static let locked: UIImage! = UIImage(systemName: "lock.shield.fill")
}
