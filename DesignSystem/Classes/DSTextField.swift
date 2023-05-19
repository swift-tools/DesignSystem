//
//  DSTextField.swift
//  DesignSystem
//
//  Created by lazymisu on 19/05/23.
//

import UIKit

@objc public protocol DSTextFieldDelegate: NSObjectProtocol {
    func textField(_ textField: UITextField, didSelectRightButton rightButton: UIButton)
}

@IBDesignable open class DSTextField: UITextField {
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet{ setNeedsLayout() }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var normalColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var focusedColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var placeholderColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var rightImage: UIImage? = nil {
        didSet { setNeedsLayout(); awakeFromNib() }
    }
    
    @IBInspectable public var horizontalSpacing: CGFloat = 0 {
        didSet { setNeedsLayout(); awakeFromNib() }
    }
    
    // MARK: - Properties
    
    private var borderColor: UIColor = .black
    
    @IBOutlet open weak var textFieldDelegate: DSTextFieldDelegate?
    
    // MARK: - UI
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        performLayoutSubviews()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        performAwakeFromNib()
    }
}

// MARK: - Methods

extension DSTextField {
    
    private func setupUI() {
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    private func performLayoutSubviews() {
        borderColor = isFirstResponder ? focusedColor : normalColor
        
        borderStyle = .none
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        
        placeholderLabel.font = UIFont(name: font?.fontName ?? "System", size: 12)
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = borderColor
        placeholderLabel.isHidden = text?.isEmpty ?? true
        
        placeholderLabel.removeFromSuperview()
        superview?.insertSubview(placeholderLabel, aboveSubview: self)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -horizontalSpacing),
            placeholderLabel.centerYAnchor.constraint(equalTo: topAnchor)
        ])
        
        rightButton.setImage(rightImage, for: .normal)
    }
    
    private func performAwakeFromNib() {
        let placeholderText = placeholder ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = horizontalSpacing
        paragraphStyle.tailIndent = -horizontalSpacing

        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font ?? .systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: placeholderColor
        ])

        let paddingView = UIView()

        if rightImage == nil {
            paddingView.frame = CGRect(x: 0, y: 0, width: horizontalSpacing, height: frame.height)
        } else {
            paddingView.addSubview(rightButton)
            rightButton.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: 6).isActive = true
            rightButton.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -horizontalSpacing).isActive = true
            rightButton.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor).isActive = true
        }

        rightView = paddingView
        rightViewMode = .always

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalSpacing, height: frame.height))
        leftViewMode = .always
    }
    
    @objc private func textFieldDidBeginEditing() {
        setNeedsLayout()
    }
    
    @objc private func textFieldDidEndEditing() {
        setNeedsLayout()
    }
    
    @objc private func rightButtonTapped(_ sender: UIButton) {
        textFieldDelegate?.textField(self, didSelectRightButton: sender)
    }
}
