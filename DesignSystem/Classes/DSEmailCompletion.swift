//
//  DSTextFieldAutocomplete.swift
//  DesignSystem
//
//  Created by felix on 12/28/23.
//

import UIKit

@objc public protocol DSEmailCompletionDelegate: NSObjectProtocol {
    func numberOfDomains(in emailCompletion: DSEmailCompletion) -> Int
    func emailCompletion(_ emailCompletion: DSEmailCompletion, titleForDomainAt index: Int) -> String
    @objc optional func emailCompletion(_ emailCompletion: DSEmailCompletion, didSelectDomainAt index: Int, forTextField textField: UITextField)
}

@IBDesignable open class DSEmailCompletion: UIView {

    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet{ setNeedsLayout() }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var borderColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var textColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var domainColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var textFont: String = "System" {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var domainFont: String = "System" {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var fontSize: CGFloat = 14 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var horizontalSpacing: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var maxItems: Int = 3
    
    @IBOutlet public weak var textField: UITextField!
    
    /// For default should be the ViewController's `view`. Use the `scrollView` as long as the component is inside it.
    @IBOutlet public weak var parentView: UIView?
    
    @IBOutlet open weak var delegate: DSEmailCompletionDelegate?
    
    // MARK: - Properties
    
    private var isDropdownOpen = false {
        didSet { setNeedsLayout() }
    }
   
    // MARK: - UI
    
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = backgroundColor
        tableView.tintColor = .clear
        tableView.separatorColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Life Cycle
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        performLayoutSubviews()
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
}

// MARK: - Private Methods
    
extension DSEmailCompletion {
    
    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        
        if let text = sender.text, let firstIndex = text.firstIndex(of: "@"), firstIndex == text.index(before: text.endIndex) {
            showDropdownTableView()
        } else {
            hideDropdownTableView()
        }
    }
    
    private func performLayoutSubviews() {
        layer.cornerRadius = cornerRadius
        
        dropdownTableView.layer.borderColor = borderColor.cgColor
        dropdownTableView.layer.borderWidth = borderWidth
        dropdownTableView.layer.cornerRadius = cornerRadius
    }
    
    private func showDropdownTableView() {
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.reloadData()
        
        parentView?.addSubview(dropdownTableView)
        
        dropdownTableView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        dropdownTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dropdownTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        var heightAnchor: CGFloat = 0
        
        let numberOfItems = self.delegate?.numberOfDomains(in: self) ?? 0
        
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
    }
    
    private func animate(_ animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            animations()
            self.layoutIfNeeded()
            
        }, completion: { _ in
            completion?()
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DSEmailCompletion: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.delegate?.numberOfDomains(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets(top: 0, left: horizontalSpacing, bottom: 0, right: horizontalSpacing)
        cell.preservesSuperviewLayoutMargins = false
        let domain = self.delegate?.emailCompletion(self, titleForDomainAt: indexPath.row) ?? ""
        let attributedString = NSMutableAttributedString()
        let textFont = UIFont(name: textFont, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let domainFont = UIFont(name: domainFont, size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
        attributedString.append(NSAttributedString(string: textField.text ?? "", attributes: [.font: textFont, .foregroundColor: textColor]))
        attributedString.append(NSAttributedString(string: domain, attributes: [.font: domainFont, .foregroundColor: domainColor]))
        cell.textLabel?.attributedText = attributedString
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
        let domain = self.delegate?.emailCompletion(self, titleForDomainAt: indexPath.row) ?? ""
        textField.text?.append(domain)
        delegate?.emailCompletion?(self, didSelectDomainAt: indexPath.row, forTextField: textField)
    }
}
