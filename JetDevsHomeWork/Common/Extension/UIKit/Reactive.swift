
import UIKit.UITextField
import RxSwift
import RxCocoa

extension Reactive where Base: CustomTextfield {
    
    var errorMessage: Binder<String> {
        return Binder(base, binding: { textField, message in
            textField.error(message: message)
        })
    }
}
