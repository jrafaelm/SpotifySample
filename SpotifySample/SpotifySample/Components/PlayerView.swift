//
//  PlayerView.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import UIKit
import SnapKit

class PlayerView: UIView {
    fileprivate var btnPlayPause: UIButton?
    fileprivate var slider: UISlider?
    var timer: Timer?

    var btnPlayTapped: (Bool) -> Void = { _ in }
    var didSlide: (Double) -> Void = { _ in }
    var track: Track? {
        didSet {
            slider?.maximumValue = Float(track?.durationInMilis ?? 0.0)
            slider?.isEnabled = true
            slider?.value = 0.0
            btnPlayPause?.isEnabled = true
            btnPlayPause?.isSelected = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        btnPlayPause = UIButton()
        btnPlayPause?.isEnabled = false
        self.addSubview(btnPlayPause!)
        btnPlayPause?.snp.makeConstraints({ (make) -> Void in
            make.leading.equalTo(self).offset(8)
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-8)
            make.width.equalTo(56)
        })
        btnPlayPause?.setTitleColor(UIColor.black, for: .normal)
        btnPlayPause?.setTitleColor(UIColor.lightGray, for: .highlighted)
        btnPlayPause?.setTitle("Play", for: .normal)
        btnPlayPause?.setTitle("Pause", for: .selected)
        btnPlayPause?.addTarget(self, action: #selector(buttonPlayTapped(sender:)), for: .touchUpInside)
        slider = UISlider()
        slider?.isEnabled = false
        self.addSubview(slider!)
        slider?.snp.makeConstraints({ (make) -> Void in
            make.leading.equalTo(btnPlayPause!.snp.trailing).offset(8)
            make.trailing.equalTo(self).offset(-8)
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-8)
        })

        slider?.addTarget(self, action: #selector(sliderDidChange(sender:)), for: .valueChanged)
    }


    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }


    @objc fileprivate func updateTimer() {
        slider?.setValue(((slider?.value ?? 0.0) + 1000.0), animated: true)
        if slider?.value == slider?.maximumValue {
            buttonPlayTapped(sender: btnPlayPause!)
        }
    }

    @objc fileprivate func buttonPlayTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        btnPlayTapped(sender.isSelected)
        if sender.isSelected {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
        }
    }

    @objc fileprivate func sliderDidChange(sender: UISlider) {
        if !sender.isTracking {
            didSlide(Double(sender.value))
            if slider?.value == slider?.maximumValue {
                buttonPlayTapped(sender: btnPlayPause!)
            }
        }
    }

}
