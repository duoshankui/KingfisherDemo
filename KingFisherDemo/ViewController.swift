//
//  ViewController.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2020/6/2.
//  Copyright © 2020 DoubleK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        
        /**
         https://img2.baidu.com/it/u=3228549874,2173006364&fm=26&fmt=auto&gp=0.jpg
         */
        let url = "https://img2.baidu.com/it/u=3228549874,2173006364&fm=26&fmt=auto&gp=0.jpg"
        imgView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "vehicle_transport_icon"))
        view.addSubview(imgView)
        imgView.center = view.center
        
        let btn = UIButton(type: .custom)
        btn.kf.setBtnImage(with: URL(string: ""))
        
        
        barrierMethod()
        
    }
}

extension ViewController {
    
    /// dispatch_barrier_async 、dispatch_barrier_sync区别
    /// https://juejin.cn/post/6844903767419125774
    func barrierMethod() {
        /// 并行队列
        let barrierQueue = DispatchQueue(label: "TestBarrierQueue", attributes: .concurrent)
        
        ///
        print("开始")
        barrierQueue.async {
            /// 任务一
            for i in 0..<2 {
                print("我是任务一，\(i)-来自线程\(Thread.current)")
            }
        }
        
        barrierQueue.async {
            /// 任务二
            for i in 0..<2 {
                print("我是任务二，\(i)-来自线程\(Thread.current)")
            }
//            sleep(2)
        }
        
        print("执行中")
        barrierQueue.async(flags: .barrier) {
            print("分割线--来自线程\(Thread.current)")
        }
        
//        barrierQueue.sync(flags: .barrier) {
//            print("分割线--来自线程\(Thread.current)")
//        }
        
        barrierQueue.async {
            /// 任务三
            /// 任务二
            for i in 0..<2 {
                print("我是任务三，\(i)-来自线程\(Thread.current)")
            }
        }
        
        print("结束了")
    }
}
