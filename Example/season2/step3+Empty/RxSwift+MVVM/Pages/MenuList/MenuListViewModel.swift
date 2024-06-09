//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by Jinyoung Yoo on 6/9/24.
//  Copyright © 2024 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

// Observable<T> -> Observable 생성(create, just, from) 시 외부에서 값을 변경시킬 수 없다.
// PublishSubject<T> -> 외부에서 해당 값을 변경 시킬 수 있다.
class MenuListViewModel {
    var menuObservable = PublishSubject<[Menu]>()
    
    lazy var itemsCount = menuObservable.map { $0.map { $0.count }.reduce(0, +) }
    lazy var totalPrice = menuObservable.map { $0.map { $0.price * $0.count }.reduce(0, +) }
    
    init() {
        let menus = [
            Menu(name: "튀김1", price: 100, count: 0),
            Menu(name: "튀김2", price: 200, count: 0),
            Menu(name: "튀김3", price: 300, count: 0),
            Menu(name: "튀김4", price: 400, count: 0),
            Menu(name: "튀김5", price: 500, count: 0),
        ]
        
        self.menuObservable.onNext(menus)
    }
}

