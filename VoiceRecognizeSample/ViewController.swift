//
//  ViewController.swift
//  VoiceRecognizeSample
//
//  Created by 伊志嶺朝輝 on 2019/09/01.
//  Copyright © 2019 TomRock. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import SoundAnalysis

class ViewController: UIViewController {
	
	private var engine = AVAudioEngine()
	// Serial dispatch queue used to analyze incoming audio buffers.
	let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
	var streamAnalyzer:SNAudioStreamAnalyzer?
	var isRecognizeing = false {
		didSet{
			if self.isRecognizeing {
				self.startAndStopButton.setTitle("Stop", for: .normal)
			}else {
				self.startAndStopButton.setTitle("Start", for: .normal)
			}
		}
	}
	@IBOutlet weak var startAndStopButton: UIButton!
	@IBOutlet weak var resultLabel: UILabel!
	
	override func viewDidLoad() {
		Logger.info()
		super.viewDidLoad()
		
		let input = engine.inputNode
		let format = engine.inputNode.inputFormat(forBus: 0)
		engine.inputNode.volume = 0.0
		
		let soundAnalysisModel = SoundAnalysisModel()
		let model = soundAnalysisModel.model
		
		streamAnalyzer = SNAudioStreamAnalyzer(format: format)
		
		do {
			let request = try SNClassifySoundRequest(mlModel: model)
			try self.streamAnalyzer?.add(request, withObserver: self)
		} catch {
			Logger.error("Setting voice recognize is Failed")
			startAndStopButton.isEnabled = false
			return
		}
		
		input.installTap(onBus: AVAudioNodeBus(), bufferSize: 8192, format: format) { buffer, time in
			self.analysisQueue.async {
				self.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
			}
			
		}
		
		isRecognizeing = false
		registerUIControlEvent()
		
	}
	
	private func registerUIControlEvent(){
		startAndStopButton.addTarget(self, action: #selector(startOrStopRecognizeVoice), for: .touchUpInside)
	}
	
	@objc func startOrStopRecognizeVoice(){
		Logger.info()
		if isRecognizeing {
			Logger.info("Stop recognizeing voice")
			engine.stop()
			isRecognizeing = false
			startAndStopButton.setTitle("Start", for: .normal)
		}else {
			do {
				Logger.info("Start recognizeing voice")
				try engine.start()
				isRecognizeing = true
			} catch {
				Logger.error("Start recognizeing voice is Failed")
				isRecognizeing = false
			}
		}
	}
}

extension ViewController: SNResultsObserving {
	func request(_ request: SNRequest, didProduce result: SNResult) {
		// 解析結果のTopを取得する
		guard let result = result as? SNClassificationResult, let classification = result.classifications.first else{
			Logger.error("Get voice recognize result is Failed")
			return
		}
		
		let formattedTime = String(format: "%.2f", result.timeRange.start.seconds)
		Logger.debug("Analysis result for audio at time: \(formattedTime)")
		
		let confidence = classification.confidence * 100.0
		let percent = String(format: "%.2f%%", confidence)
		
		DispatchQueue.main.async {
			let resultString = "\(classification.identifier)\n\(percent)%"
			self.resultLabel.text = resultString
			self.resultLabel.sizeToFit()
			Logger.debug(resultString)
		}
	}
	
    func request(_ request: SNRequest, didFailWithError error: Error) {
		Logger.error("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
		Logger.info("The request completed successfully!")
    }
}

