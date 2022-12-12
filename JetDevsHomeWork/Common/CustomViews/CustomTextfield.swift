
import UIKit.UIView

struct Constants {
    static let normalBorderWidth: CGFloat = 0.5
    static let selectedBorderWidth: CGFloat = 1
}

final class CustomTextfield: UITextField {
    
    // MARK: - Enum
    enum TextfieldState {
        case noText
        case edit
        case hasText
        case error (errorMessage: String)

        static func == (lhs: TextfieldState, rhs: TextfieldState) -> Bool {
            switch (lhs, rhs) {
            case (.noText, .noText):
                return true
            case (.edit, .edit):
                return true
            case (.hasText, .hasText):
                return true
            case (let .error(lhsMessage), let .error(rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }

        static func != (lhs: TextfieldState, rhs: TextfieldState) -> Bool {
            switch (lhs, rhs) {
            case (.noText, .noText):
                return false
            case (.edit, .edit):
                return false
            case (.hasText, .hasText):
                return false
            case (let .error(lhsMessage), let .error(rhsMessage)):
                return lhsMessage != rhsMessage
            default:
                return true
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .noText, .hasText:
                return Constants.normalBorderWidth
            default:
                return Constants.selectedBorderWidth
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .edit:
                return .clear
            default:
                return UIColor.white
            }
        }
    }

    // MARK: - Outlet, IBInspectable, Control
    fileprivate var titleLabel: UILabel = UILabel()
    fileprivate var textFieldView: UIView = UIView()
    fileprivate var errorLabel: UILabel = UILabel()
    @IBInspectable var title: String = "Message" {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    @IBInspectable var subPlaceholder: String = ""

    // MARK: - Props
    var titleFont: UIFont = UIFont.latoRegularFont(size: 16)
    var activeTitleFontsize = 9
    var borderRadius: CGFloat = 4
    var normalColorBorder: UIColor = .lightGray
    var activeColorBorder: UIColor = .lightGray
    var errorColorBorder: UIColor = .red
    var rightInset: CGFloat = 0
    
    override var text: String? {
        didSet {
            if (text?.isNotEmpty ?? false) && materialState != .edit {
                materialState = .hasText
            }
        }
    }

    var animateDuration: Double = 0.2
    
    var allowCopyPaste = true
    
    // MARK: - Private Props
    fileprivate var titleLeadMargin: CGFloat = 17
    private var materialState: TextfieldState = .noText {
        didSet {
            switch self.materialState {
            case .edit:
                self.updatePlaceholder(string: subPlaceholder)
                self.isUserInteractionEnabled = true
                if oldValue == .noText {
                    self.animatedEditing()
                    return
                }

                if oldValue == .hasText {
                    editingTextField()
                }

                if case .error = oldValue {
                    self.errorLabel.text = ""
                    self.editingTextField()
                }
            case .noText:
                self.updatePlaceholder(string: "")
                if oldValue == .edit {
                    self.errorLabel.text = ""
                    self.animatedNoTextFromEdit()
                }
            case .hasText:
                if self.titleLabel.transform.a == 1 {
                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: -4, y: 4 - self.titleLabel.frame.minY)
                    let ratioScale = CGFloat(self.activeTitleFontsize)/self.titleFont.pointSize
                    transform = transform.scaledBy(x: ratioScale, y: ratioScale)
                    self.titleLabel.transform = transform
                }
                self.errorLabel.text = ""
                self.titleLabel.textColor = .lightGray
                self.textFieldView.layer.borderColor = UIColor.lightGray.cgColor
                self.textFieldView.layer.borderWidth = self.materialState.borderWidth
                self.textFieldView.backgroundColor = self.materialState.backgroundColor
                self.resignFirstResponder()
                self.tintColor = .lightGray
            case .error(let message):
                showError(message: message)
            }
        }
    }

    // MARK: - Public functions

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func error(message: String) {
        if message.isNotEmpty && text?.isNotEmpty == true {
            self.materialState = .error(errorMessage: message)
        } else {
            if text?.isNotEmpty == true {
                self.materialState = .edit
            } else {
                self.materialState = .noText
            }
        }
    }

    func didEndEditing() {
        let text = self.text ?? ""
        materialState = text.isEmpty ? .noText : .hasText
    }

    // MARK: - Override
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: UIEdgeInsets(top: 0, left: 13, bottom: -10, right: rightInset))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: UIEdgeInsets(top: 0, left: 13, bottom: -10, right: rightInset))
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
            action == #selector(UIResponderStandardEditActions.paste(_:)) ||
            action == #selector(UIResponderStandardEditActions.cut(_:)){
            return allowCopyPaste
        }
        return super.canPerformAction(action, withSender: sender)
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        switch materialState {
        case .edit:
            if text == nil || (text ?? "").isEmpty {
                materialState = .noText
            } else {
                materialState = .hasText
            }
            return true
        case .error:
            return true
        default:
            return true
        }
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        switch materialState {
        case .noText, .hasText, .error:
            materialState = .edit
            return true
        default:
            return true
        }
    }

    // MARK: - Private func
    fileprivate func commonInit() {
        textColor = .darkGray
        addTextFieldView()
        addTitleLabel()
    }

    func addErrorLabel(parentView: UIView?) {
        // Add Error Label
        guard let superview = parentView else { return }
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont.latoRegularFont(size: 12)
        superview.addSubview(errorLabel)
        errorLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 2).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        superview.bottomAnchor.constraint(greaterThanOrEqualTo: errorLabel.bottomAnchor, constant: 2).isActive = true
        superview.layoutIfNeeded()
    }
    
    private func addTextFieldView() {
        // Add TextField View
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textFieldView)
        textFieldView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textFieldView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textFieldView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textFieldView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textFieldView.layer.borderWidth = self.materialState.borderWidth
        textFieldView.layer.borderColor = self.normalColorBorder.cgColor
        textFieldView.layer.cornerRadius = self.borderRadius
        textFieldView.clipsToBounds = true
        textFieldView.backgroundColor = materialState.backgroundColor
        textFieldView.layer.borderWidth = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.textFieldView.addGestureRecognizer(tap)
    }

    private func addTitleLabel() {
        // Add title Label
        titleLabel.font = titleFont
        titleLabel.textColor = UIColor.darkGray
        titleLabel.frame = CGRect(x: self.titleLeadMargin,
                                  y: (bounds.height)/2 - ((titleFont.pointSize + 3)/2),
                                  width: self.bounds.width - (titleLeadMargin*2),
                                  height: titleFont.pointSize + 3)
        textColor = self.textColor
        textFieldView.addSubview(titleLabel)
        self.titleLabel.setAnchorPoint(.zero)
    }

    @objc private func handleTap(tap: UITapGestureRecognizer) {
        becomeFirstResponder()
    }

    private func animatedEditing() {
        becomeFirstResponder()
        CATransaction.begin()

        CATransaction.setCompletionBlock({
            self.editingTextField()
        })

        UIView.animate(withDuration: animateDuration, animations: {
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: -4, y: 4 - self.titleLabel.frame.minY)
            let ratioScale = CGFloat(self.activeTitleFontsize)/self.titleFont.pointSize
            transform = transform.scaledBy(x: ratioScale, y: ratioScale)
            self.titleLabel.transform = transform
            self.textFieldView.backgroundColor = self.materialState.backgroundColor
        })

        CATransaction.commit()

    }

    private func showError(message: String) {
        if self.titleLabel.transform.a == 1 {
            UIView.animate(withDuration: animateDuration, animations: {
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: -4, y: 4 - self.titleLabel.frame.minY)
                let ratioScale = CGFloat(self.activeTitleFontsize)/self.titleFont.pointSize
                transform = transform.scaledBy(x: ratioScale, y: ratioScale)
                self.titleLabel.transform = transform
                self.textFieldView.backgroundColor = self.materialState.backgroundColor
            }) { isFinished in
                guard isFinished else {
                    return
                }
                self.textFieldView.layer.borderColor = self.errorColorBorder.cgColor
                self.titleLabel.textColor = self.errorColorBorder
                self.textFieldView.layer.borderWidth = self.materialState.borderWidth
                self.errorLabel.text = message
            }
        } else {
            self.textFieldView.layer.borderColor = self.errorColorBorder.cgColor
            self.titleLabel.textColor = self.errorColorBorder
            self.textFieldView.layer.borderWidth = self.materialState.borderWidth
            self.errorLabel.text = message
        }
    }

    private func editingTextField() {
        titleLabel.textColor = UIColor(hex: "28518D")
        textFieldView.layer.borderColor = UIColor(hex: "28518D").cgColor
        textFieldView.layer.borderWidth = materialState.borderWidth
        textFieldView.backgroundColor = materialState.backgroundColor
        tintColor = UIColor(hex: "28518D")
        if !(self.inputView == nil) {
            becomeFirstResponder()
        }
    }

    private func updatePlaceholder(string: String) {
        let textColor = UIColor.lightGray
        attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [
                NSAttributedString.Key.foregroundColor: textColor
        ])
        font = UIFont.latoRegularFont(size: 16)
    }

    private func animatedNoTextFromEdit() {
        resignFirstResponder()
        tintColor = .lightGray
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            guard self.materialState == .noText else {
                return
            }
            self.titleLabel.textColor = .darkGray
            self.textFieldView.layer.borderColor = UIColor.lightGray.cgColor
            self.textFieldView.layer.borderWidth = self.materialState.borderWidth
        })

        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: 0, y: 0)
            transform = transform.scaledBy(x: 1, y: 1)
            self.titleLabel.transform = transform
            self.textFieldView.backgroundColor = self.materialState.backgroundColor
        })

        CATransaction.commit()
    }
}
