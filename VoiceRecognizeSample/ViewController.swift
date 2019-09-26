//
//  ViewController.swift
//  VoiceRecognizeSample
//
//  Created by 伊志嶺朝輝 on 2019/09/01.
//  Copyright © 2019 TomRock. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	
	private var engine = AVAudioEngine()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let input = engine.inputNode
		let output = engine.mainMixerNode
		let format = engine.inputNode.inputFormat(forBus: 0)
		let delayUnit = AVAudioUnitDelay()
		delayUnit.delayTime = 2
		engine.attach(delayUnit)
		
		engine.inputNode.volume = 0.0
		
		engine.connect(input, to: delayUnit, format: format)
		engine.connect(delayUnit, to:output, format: format)
	}
	
	@IBAction func micSwitchValueChanged(_ sw: UISwitch) {
		if sw.isOn {
			try! engine.start()
		}else {
			engine.stop()
		}
	}
	
	@IBAction func micVolumeSliderValueChanged(_ slider: UISlider) {
		engine.inputNode.volume = slider.value / slider.maximumValue
	}
	
}

