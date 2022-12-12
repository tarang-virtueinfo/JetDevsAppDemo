//
//  LoginViewModel.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 10/12/2022.
//

import Foundation
import RxCocoa
import RxSwift

protocol LoginViewModelInputs {
    
    func didChange(email: String)
    func didChange(password: String)
    var submit: PublishRelay<Void> { get }
}

protocol LoginViewModelOutputs {
    
    var isEmailValid: PublishRelay<ValidationResult> { get }
    var isPasswordValid: PublishRelay<ValidationResult> { get }
    var isEnableLoginButton: PublishRelay<Bool> { get }
    var loginResult: Observable<LoginResponse> { get }
    var signingIn: Observable<Bool> { get }
}

protocol LoginViewModelTypes: LoginViewModelInputs, LoginViewModelOutputs {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

final class LoginViewModel: LoginViewModelTypes {
    
    var inputs: LoginViewModelInputs { self }
    var outputs: LoginViewModelOutputs { self }
    var submit: PublishRelay<Void> = PublishRelay()
    var isEmailValid: PublishRelay<ValidationResult> = PublishRelay()
    var isPasswordValid: PublishRelay<ValidationResult> = PublishRelay()
    var isEnableLoginButton: PublishRelay<Bool> = PublishRelay()
    var loginResult: Observable<LoginResponse>
    var signingIn: Observable<Bool>
    
    private let disposeBag = DisposeBag()
    private var didChangeEmailProperty = PublishSubject<String>()
    private var didChangePasswordProperty = PublishSubject<String>()
    
    init(
        useCase: LoginUseCase = DefaultLoginUseCase(),
        validateUseCase: LoginValidateUseCase = DefaultLoginValidateUseCase()
    ) {
        didChangeEmailProperty.map({ validateUseCase.validateEmail($0)})
            .bind(to: isEmailValid)
            .disposed(by: disposeBag)
        
        didChangePasswordProperty.map({ validateUseCase.validatePassword($0) })
            .bind(to: isPasswordValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isEmailValid, isPasswordValid).map { email, password in
            return email.isValid && password.isValid
        }
        .bind(to: isEnableLoginButton)
        .disposed(by: disposeBag)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        let emailAndPassword = Observable.combineLatest(didChangeEmailProperty.share(),
                                                        didChangePasswordProperty.share()) {
            (email: $0, password: $1)
        }
        
        loginResult = submit.withLatestFrom(emailAndPassword)
            .flatMapFirst({ pair in
                return useCase.login(pair.email, password: pair.password)
                    .observeOn(MainScheduler.instance)
                    .trackActivity(signingIn)
            })
    }
    
    func didChange(email: String) {
        didChangeEmailProperty.onNext(email)
    }
    
    func didChange(password: String) {
        didChangePasswordProperty.onNext(password)
    }
}
