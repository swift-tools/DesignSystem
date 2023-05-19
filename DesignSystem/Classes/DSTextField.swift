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
    
    // FIXME: Da problemas si usamos imagenes del sistema (crashea Storyboard)
    @IBInspectable public var rightImage: UIImage? = nil {
        didSet { setNeedsLayout(); awakeFromNib() }
    }
    
    @IBInspectable public var horizontalSpacing: CGFloat = 0 {
        didSet { setNeedsLayout(); awakeFromNib() }
    }
    
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
        
        rightButton.setImage(rightImage, for: .normal)
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

        let paddingView = UIView()

        if rightImage == nil {
            paddingView.frame = CGRect(x: 0, y: 0, width: horizontalSpacing, height: frame.height)
        } else {
            paddingView.addSubview(rightButton)
            rightButton.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: 6).isActive = true
            // FIXME: si cambia el horizontalSpacing se actualiza esto?
            rightButton.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -horizontalSpacing).isActive = true
            rightButton.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor).isActive = true
        }

        rightView = paddingView
        rightViewMode = .always

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalSpacing, height: frame.height))
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
