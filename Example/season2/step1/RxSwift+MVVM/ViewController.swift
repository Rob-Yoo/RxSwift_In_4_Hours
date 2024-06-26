//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
//    var disposable = [Disposable]()
    var disposable = DisposeBag() // 위 Disposable 배열과 viewWillDisappear 메서드에서의 dispose 메서드가 호출된 로직을 한번에 처리해줌
    // 즉, DiposeBag을 가지고 있는 객체가 사라지면 자동으로 dispose 메서드가 호출된 것과 동일한 동작을 함

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        disposable.forEach { $0.dispose() } // 뷰가 사라질 때 비동기 작업 모두 취소시킬 수 있음
//    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe (비동기 코드 실행)
    // 3. onNext (데이터 전달)

    // 4번 혹은 5번 상태일 때 동작 끝(subscribe가 재호출되기 전까지 재사용 X) -> Observable의 클로저가 소멸됨
    // 4. onCompleted / onError
    // 5. Disposed
    
    
    func downloadJson(url: String) -> Observable<String?> {
        // 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }
                
                if let rawData = data, let json = String(data: rawData, encoding: .utf8) {
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
        }
    }
    
    func download(url: String) -> Observable<String?> {
        // return Observable.just("Hello") // 아래 5줄의 코드를 just 하나로 끝낼 수 있음 (이때, 한 번 밖에 emitt 하지 못함)
        return Observable.from(["Hello", "World"]) // 배열 안에 있는 요소를 한 번씩 emitt 함 (Hello 한번, World 한번)
//        return Observable.create() { emitter in
//            emitter.onNext("Hello")
//            emitter.onCompleted()
//            return Disposables.create()
//        }
    }
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        let observable = downloadJson(url: MEMBER_LIST_URL) // 비동기 코드 실행 전
        
//        let disposable = observable.subscribe { event in // subscribe 오퍼레이터가 호출되면 observable의 비동기 코드 실행
//                switch event {
//                case .next(let json):
//                    DispatchQueue.main.async {
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//                case .error(_):
//                    break
//                case .completed:
//                    break
//                }
//            }
        
// ----------------------------------------------------------------------

        // 위 subscribe 코드를 짧게 끝낼 수 있음
//        let d = downloadJson(url: MEMBER_LIST_URL)
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            })
        
        // d.dispose() -> 비동기 코드 실행 중간에 취소시킬 수 있음
        // disposable.append(d)
//        disposable.insert(d) // -> DisposeBag에 넣기
        
// ------------------------------------------------------------------------
        // -> disposable.insert() 코드를 선언형으로 바꿈
        downloadJson(url: MEMBER_LIST_URL)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            .disposed(by: disposable)
    }
}
