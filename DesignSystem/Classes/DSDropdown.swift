//
//  DSDropdown.swift
//  DesignSystem
//
//  Created by lazymisu on 18/05/23.
//

import UIKit

@objc public protocol DSDropdownDelegate: NSObjectProtocol {
    func numberOfItems(in dropdown: DSDropdown) -> Int
    func dropdown(_ dropdown: DSDropdown, titleForItemAt index: Int) -> String
    func dropdown(_ dropdown: DSDropdown, didSelectItemAt index: Int)
    @objc optional func dropdown(_ dropdown: DSDropdown, didDeselectItemAt index: Int)
}

@IBDesignable open class DSDropdown: UIView {
    
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
    
    @IBInspectable public var textColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var placeholderColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var font: String = "System" {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var fontSize: CGFloat = 14 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var placeholder: String = "" {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var horizontalSpacing: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable public var maxItems: Int = 3
    
    @IBInspectable public var allowDeselect: Bool = false
    
    /// For default should be the ViewController's `view`. Use the `scrollView` as long as the component is inside it.
    @IBOutlet public weak var parentView: UIView?
    
    @IBOutlet open weak var delegate: DSDropdownDelegate?
    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = backgroundColor
        button.tintColor = .clear
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = backgroundColor
        tableView.tintColor = .clear
        tableView.separatorColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var rightImage: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "chevron.down")
        } else {
            // TODO: Fallback on earlier versions
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private var borderColor: UIColor = .black
    
    private var title: String = ""
    
    private var isDropdownOpen = false {
        didSet { setNeedsLayout() }
    }
    
    private(set) public var indexForSelectedItem: Int? {
        didSet { setNeedsLayout() }
    }
    
    private var placeholderLabelLeadingConstraint: NSLayoutConstraint?
    
    private var placeholderLabelTrailingConstraint: NSLayoutConstraint?
    
    private var rightImageTraillingConstraint: NSLayoutConstraint?
    
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
        layer.cornerRadius = cornerRadius
        
        let titleColor = indexForSelectedItem == nil ? placeholderColor : textColor
        borderColor = isDropdownOpen ? focusedColor : normalColor
        
        if let index = indexForSelectedItem, let title = delegate?.dropdown(self, titleForItemAt: index) {
            self.title = title
        } else {
            title = placeholder
        }
        
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont(name: font, size: fontSize) ?? .systemFont(ofSize: fontSize)
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = borderWidth
        button.layer.cornerRadius = cornerRadius
        button.setTitle(title, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: horizontalSpacing, bottom: 0, right: horizontalSpacing + 16)
        
        placeholderLabel.font = UIFont(name: font, size: 12) ?? .systemFont(ofSize: 12)
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = borderColor
        placeholderLabel.isHidden = indexForSelectedItem == nil
        placeholderLabelLeadingConstraint?.constant = horizontalSpacing
        placeholderLabelTrailingConstraint?.constant = -(horizontalSpacing + 16)
        
        dropdownTableView.layer.borderColor = borderColor.cgColor
        dropdownTableView.layer.borderWidth = borderWidth
        dropdownTableView.layer.cornerRadius = cornerRadius
        
        rightImage.tintColor = placeholderColor
        rightImageTraillingConstraint?.constant = -horizontalSpacing
    }
    
    // MARK: - Methods
    
    public func selectItem(at index: Int) {
        indexForSelectedItem = index
        delegate?.dropdown(self, didSelectItemAt: index)
    }
    
    public func deselectItem() {
        if let indexForSelectedItem = indexForSelectedItem {
            delegate?.dropdown?(self, didDeselectItemAt: indexForSelectedItem)
        }
        indexForSelectedItem = nil
    }
    
    private func setupUI() {
        addSubview(button)
        addSubview(rightImage)
        addSubview(placeholderLabel)
        
        button.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
        
        rightImageTraillingConstraint = rightImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalSpacing)
        placeholderLabelLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing)
        placeholderLabelTrailingConstraint = placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -(horizontalSpacing + 16))
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.heightAnchor.constraint(equalTo: heightAnchor),
            rightImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightImage.widthAnchor.constraint(equalToConstant: 16),
            placeholderLabel.centerYAnchor.constraint(equalTo: topAnchor),
        ])
        
        rightImageTraillingConstraint?.isActive = true
        placeholderLabelLeadingConstraint?.isActive = true
        placeholderLabelTrailingConstraint?.isActive = true
        
    }
    
    @objc private func dropdownButtonTapped() {
        isDropdownOpen.toggle()
        isDropdownOpen ? showDropdownTableView() : hideDropdownTableView()
    }
    
    private func showDropdownTableView() {
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.reloadData()
        
        parentView?.addSubview(dropdownTableView)
        
        dropdownTableView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: -1).isActive = true
        dropdownTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dropdownTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        var heightAnchor: CGFloat = 0
        
        let numberOfItems = self.delegate?.numberOfItems(in: self) ?? 0
        
        if numberOfItems > maxItems {
            heightAnchor = (CGFloat(maxItems) + 0.5) * 44
            dropdownTableView.isScrollEnabled = true
        } else {
            heightAnchor = CGFloat(numberOfItems * 44)
            dropdownTableView.isScrollEnabled = false
        }
        
        dropdownTableView.heightAnchor.constraint(equalToConstant: heightAnchor).isActive = true
        
        if let parentView = parentView as? UIScrollView {
            parentView.layoutIfNeeded()
            
            let dropdownYpos = parentView.convert(dropdownTableView.frame.origin, to: nil).y
            let delta = dropdownYpos + heightAnchor
            
            if parentView.contentSize.height < delta {
                dropdownTableView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
            }
            
            // FIXME: scroll to list
            //            parentView.setContentOffset(CGPoint(x: 0, y: parentView.contentOffset.y + (parentView.contentSize.height - delta)), animated: true)
        }
        
        renderTableView(show: false)
        animate { self.renderTableView(show: true) }
    }
    
    private func hideDropdownTableView() {
        animate {
            self.renderTableView(show: false)
        } completion: {
            self.dropdownTableView.removeFromSuperview()
        }
    }
    
    private func renderTableView(show: Bool) {
        dropdownTableView.alpha = show ? 1 : 0
        dropdownTableView.transform = show ? .identity : CGAffineTransform(translationX: 0, y: -40).scaledBy(x: 1, y: 0.1)
        rightImage.transform = show ? CGAffineTransform(rotationAngle: .pi): .identity
    }
    
    private func animate(_ animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            animations()
            self.layoutIfNeeded()
            
        }, completion: { _ in
            self.isUserInteractionEnabled = true
            completion?()
        })
    }
}

extension DSDropdown: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.delegate?.numberOfItems(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets(top: 0, left: horizontalSpacing, bottom: 0, right: horizontalSpacing)
        cell.preservesSuperviewLayoutMargins = false
        cell.textLabel?.text = self.delegate?.dropdown(self, titleForItemAt: indexPath.row)
        cell.textLabel?.textColor = placeholderColor
        cell.textLabel?.font = UIFont(name: font, size: fontSize) ?? .systemFont(ofSize: fontSize)
        cell.backgroundColor = backgroundColor
        let bgColorView = UIView()
        bgColorView.backgroundColor = borderColor.withAlphaComponent(0.3)
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isDropdownOpen = false
        hideDropdownTableView()
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        if allowDeselect, indexForSelectedItem == indexPath.row {
            deselectItem()
        } else {
            selectItem(at: indexPath.row)
        }
    }
}
