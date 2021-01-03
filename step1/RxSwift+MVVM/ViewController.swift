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

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: SYNC

    // RxSwift유도 과정
    
    class 나중에생기는데이터<T> {
        // task가 실행된 다음에 f가 실행된다.
        private let task : (@escaping (T) -> Void) -> Void

        // 나중에생기는데이터가 만들어지면 task가 지정된다.
        init(task : @escaping (@escaping (T) -> Void) -> Void) {
            self.task = task
        }

        // 나중에오면 task를 실행한다.
        func 나중에오면(_ f: @escaping (T) -> Void) {
            task(f)
        }
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        downloadJSON(MEMBER_LIST_URL).나중에오면 { dataString in
            self.editView.text = dataString
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }
    }
    
    func downloadJSON(_ URLAddress: String) -> 나중에생기는데이터<String?> {
        // 본체
        return 나중에생기는데이터 { f in
            // 할일들을 적어라
            DispatchQueue.global().async {
                let url = URL(string: URLAddress)!
                let data = try! Data(contentsOf: url)
                let json = String(data:data,encoding: .utf8)
                
                DispatchQueue.main.async {
                    f(json)
                }
            }
//            let url = URL(string : URLAddress)!
//            URLSession.shared.dataTask(with: url) { (data, _, err) in
//                if let data = data, let json = String(data:data,encoding: .utf8){
//                    DispatchQueue.main.async {
//                        f(json)
//                    }
//                }
//            }
        }
//
//        return Observable.create() { emitter in
//            let url = URL(string : URLAddress)!
//            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
//                guard err == nil else {
//                    emitter.onError(err!)
//                    return
//                }
//
//                if let data = data , let json = String(data:data,encoding: .utf8) {
//                    emitter.onNext(json)
//                }
//
//                emitter.onCompleted()
//            }
//
//            task.resume()
//
//            return Disposables.create() {
//                task.cancel()
//            }
//        }
    }
    
}
