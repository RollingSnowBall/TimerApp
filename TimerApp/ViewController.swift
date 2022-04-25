//
//  ViewController.swift
//  TimerApp
//
//  Created by JUNO on 2022/04/25.
//

import UIKit
import AudioToolbox

enum TimerStatus{
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    
    var currentSecond = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configStartBtn()
    }
    
    func setTimerInfoViewVisible(isHidden: Bool){
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    func configStartBtn(){
        self.startBtn.setTitle("시작", for: .normal)
        self.startBtn.setTitle("일시정지", for: .selected)
    }
    
    func startTimer(){
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                let hour = self.currentSecond / 3600
                let min = (self.currentSecond % 3600) / 60
                let sec = (self.currentSecond % 3600) % 60
                
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, min, sec)
                self.progressView.progress = Float(self.currentSecond) / Float(self.duration)
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                
                self.currentSecond -= 1
                
                if self.currentSecond <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer(){
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelBtn.isEnabled = false
        //self.setTimerInfoViewVisible(isHidden: true)
        //self.datePicker.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
        self.startBtn.isSelected = false
        self.timer?.cancel()
        self.timer = nil
    }

    @IBAction func tapCancelBtn(_ sender: UIButton) {
        switch timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapStartBtn(_ sender: UIButton) {
        self.duration = Int(datePicker.countDownDuration)
        switch timerStatus {
        case .start:
            self.timerStatus = .pause
            self.startBtn.isSelected = false
            self.timer?.suspend()
            
        case .end:
            self.currentSecond = self.duration
            self.timerStatus = .start
            //self.setTimerInfoViewVisible(isHidden: false)
            //self.datePicker.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.startBtn.isSelected = true
            self.cancelBtn.isEnabled = true
            self.startTimer()
            
        case .pause:
            self.timerStatus = .start
            self.startBtn.isSelected = true
            self.timer?.resume()
        }
    }
}

