//
//  ViewModel.swift
//  RxSwiftIn4Hours
//
//  Created by Jinyoung Yoo on 6/21/24.
//  Copyright © 2024 n.code. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {

    let emailText = BehaviorRelay<String>(value: "")
    let pwdText = BehaviorRelay<String>(value: "")
    
    // PublishSubject으로 하게 되면 초기값을 설정하지 못하므로 BehaviorSubject 사용
    let isEmailValid = BehaviorRelay<Bool>(value: false)
    let isPasswordValid = BehaviorRelay<Bool>(value: false)
    
    init() {
        _ = emailText.distinctUntilChanged()
            .map(checkEmailValid)
            .bind(to: isEmailValid)
        
        _ = pwdText.distinctUntilChanged()
            .map(checkPasswordValid)
            .bind(to: isPasswordValid)
    }
    
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}
