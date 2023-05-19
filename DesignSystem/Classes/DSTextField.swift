//
//  DSTextField.swift
//  DesignSystem
//
//  Created by lazymisu on 19/05/23.
//

import UIKit

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
    
    @IBInspectable public var horizontalSpacing: CGFloat = 0 {
        didSet { setNeedsLayout()
            awakeFromNib() }
    }
    
    // MARK: - UI
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialize
    
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
        
        borderColor = isFirstResponder ? focusedColor : normalColor
        
        borderStyle = .none
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        
        placeholderLabel.font = UIFont(name: font?.fontName ?? "System", size: 12)
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = borderColor
        placeholderLabel.isHidden = text?.isEmpty ?? true
        placeholderLabelLeadingConstraint?.constant = horizontalSpacing
        placeholderLabelTrailingConstraint?.constant = -horizontalSpacing
        
        superview?.insertSubview(placeholderLabel, aboveSubview: self)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -horizontalSpacing),
            placeholderLabel.centerYAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        let placeholderText = placeholder ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = horizontalSpacing
        paragraphStyle.tailIndent = -horizontalSpacing

        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font ?? .systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: placeholderColor
        ])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalSpacing, height: frame.height))
        rightView = paddingView
        rightViewMode = .always
        leftView = paddingView
        leftViewMode = .always
    }
    
    // MARK: - Properties
    
    private var borderColor: UIColor = .black
    
    private var placeholderLabelLeadingConstraint: NSLayoutConstraint?
    
    private var placeholderLabelTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Methods
    
    private func setupUI() {
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    @objc private func textFieldDidBeginEditing() {
        setNeedsLayout()
    }
    
    @objc private func textFieldDidEndEditing() {
        setNeedsLayout()
    }
}
