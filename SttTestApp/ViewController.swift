//
//  ViewController.swift
//  SttTestApp
//
//  Created by 최은화 on 2021/04/01.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var LbText: UILabel!
    @IBOutlet weak var LbSpeech: UILabel!
    @IBOutlet weak var BtnSpeech: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        private let audioEngine = AVAudioEngine()
        
        @IBAction func speechToText(_ sender: Any) {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                BtnSpeech.isEnabled = false
                BtnSpeech.setTitle("Start", for: .normal)
            } else {
                startRecording()
                BtnSpeech.setTitle("Stop", for: .normal)
            }
        }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            speechRecognizer?.delegate = self

        }
        func startRecording() {
            
            if recognitionTask != nil {
                recognitionTask?.cancel()
                recognitionTask = nil
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                
                var isFinal = false
                
                var speechTxt = "" //음성 텍스트
                var readTxt = ""    //스피치 할 텍스트.
                
                if result != nil {
                    
                    speechTxt = self.stringDelSpecialSymbol(result?.bestTranscription.formattedString ?? "")
                    readTxt = self.stringDelSpecialSymbol(self.LbText.text ?? "")
                    
                    self.LbSpeech.text = speechTxt
                    isFinal = (result?.isFinal)!
                    
                    // NSMutableAttributedString Type으로 바꾼 text를 저장
                    let attributedStr = NSMutableAttributedString(string: readTxt)

                    // text의 range 중에서 스피치 한 글자는 UIColor를 blue로 변경
                    attributedStr.addAttribute(.foregroundColor, value: UIColor.blue, range: (readTxt as NSString).range(of: speechTxt))

                    // 설정이 적용된 text를 label의 attributedText에 저장
                    self.LbText.attributedText = attributedStr
                    
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.BtnSpeech.isEnabled = true
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
            LbSpeech.text = "Say something, I'm listening!"
            
        }
    
    //특수문자 및 공백, 개행 제거.
    func stringDelSpecialSymbol(_ str:String) -> String{
        let str_ = str.replacingOccurrences(of: "\n", with: "").components(separatedBy: ["~","!","@",",","."," "]).joined()
        
        return str_
        
    }
       
        func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
            if available {
                BtnSpeech.isEnabled = true
            } else {
                BtnSpeech.isEnabled = false
            }
        }
}

