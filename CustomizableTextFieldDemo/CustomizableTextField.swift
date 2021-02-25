//
//  CustomizableTextField.swift
//  CustomizableTextFieldDemo
//
//  Created by Daisy Ramos on 2/22/21.
//

import UIKit
import Combine
import CombineCocoa

/// A `UITextField` subclass that customizes the insets of a textfield.
final class CustomizableTextField: UITextField {

    /// The view model containing information necessary for configuring the display of the view.
    struct ViewModel {
        
        /// The properties that can be applied to the right view.
        struct RightView {
            
            /// The optional image for the right view.
            var image: UIImage?
            
            /// The optional text for the right view.
            var text: String?
            
            /// The tint color of the text and image.
            let tintColor: UIColor?
            
            /// The padding between the accessory text and edge of the text field.
            let padding: CGFloat
        }
        
        /// The text.
        var text: String?
        
        /// The color of the text.
        let textColor: UIColor?
        
        /// The placeholder text.
        let placeholder: String?
        
        /// Sets the center inset of the text field.
        let centerInset: CGPoint
        
        /// The optional `RightView` to display on the `rightView` of a `UITextField`.
        var rightView: RightView?
    }
    
    // MARK: - CustomizableTextField
    
    /// A `ViewModel` that contains the informations to configure the view.
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            text = viewModel.text
            textColor = viewModel.textColor
            placeholder = viewModel.placeholder
            center = viewModel.centerInset
            
            rightViewImage = viewModel.rightView?.image
            rightViewText = viewModel.rightView?.text
            rightViewTintColor = viewModel.rightView?.tintColor
            rightViewPadding = viewModel.rightView?.padding ?? 0
        }
    }
    
    /// Called when the right accessory's enabled value has changed.
    var rightAccessoryButtonEnabled: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty(control: rightAccessoryButton, events: .primaryActionTriggered, keyPath: \.isSelected)
                  .eraseToAnyPublisher()
    }
    
    /// Sets the center inset of the text field..
    @IBInspectable private var centerInset: CGPoint = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// Sets padding for the `rightView` from the text field's edge.
    @IBInspectable private var rightViewPadding: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// Sets an image for the `rightView`.
    @IBInspectable private var rightViewImage: UIImage? {
        didSet {
            rightAccessoryButton.setImage(rightViewImage, for: .normal)
            rightViewMode = rightViewImage != nil || rightViewText != nil ? .always : .never
        }
    }
    
    /// Sets text for the `rightView`.
    @IBInspectable private var rightViewText: String? {
        didSet {
            rightAccessoryButton.setTitle(rightViewText, for: .normal)
            rightAccessoryButton.setTitleColor(rightViewTintColor, for: .normal)
            
            rightViewMode = rightViewText != nil || rightViewImage != nil ? .always : .never
        }
    }
    
    /// Sets tintColor for the `rightView`.
    @IBInspectable private var rightViewTintColor: UIColor? {
        didSet {
            if rightViewImage != nil {
                rightAccessoryButton.tintColor = rightViewTintColor
            }
            
            if rightViewText != nil {
                rightAccessoryButton.setTitleColor(rightViewTintColor, for: .normal)
            }
        }
    }
    
    private let rightAccessoryButton: UIButton = UIButton(frame: .zero)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = ViewModel(text: text, textColor: textColor, placeholder: placeholder, centerInset: centerInset, rightView: .init(image: rightViewImage, text: rightViewText, tintColor: rightViewTintColor, padding: rightViewPadding))
    }
    
    // MARK: - UITextField
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        insetTextRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        insetTextRect(forBounds: bounds)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x -= rightViewPadding
        return rightViewRect
    }
    
    // MARK: - CustomizableTextField
    
    private func commonInit() {
        rightView = rightAccessoryButton
        rightViewMode = .never
        
        rightAccessoryButton.controlEventPublisher(for: .primaryActionTriggered)
            .sink {
                self.rightAccessoryButton.isSelected.toggle()
            }
            .store(in: &cancellables)
        
        textPublisher
            .sink { text in
                self.viewModel?.text = text
                print(text ?? "")
            }
            .store(in: &cancellables)
    }
    
    private func insetTextRect(forBounds bounds: CGRect) -> CGRect {
        var insetBounds = bounds.insetBy(dx: centerInset.x, dy: centerInset.y)
        insetBounds.size.width -= rightViewPadding + rightAccessoryButton.bounds.width
        return insetBounds
    }
}

