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
    
        private let readTxt = ["옛날 옛날 한 옛날에 백두산에 호랑이가 살고있었는데, ",
                               "어느 날 한 소년이 산에 오르고 있었어요. ",
                               "그 소년을 본 호랑이는 소년 앞에 나타났어요."]
        
        var chkTxtCnt = 0
    
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
            
            self.LbText.text = readTxt[chkTxtCnt]
            
//            let orgTxt = "옛날 옛날 한 옛날에 백두산!!에 . \n 호랑이가 살고있었어요! 옛날이지만요.."
//            let arrOrgS = Array(orgTxt)
//
//            let chkTxt = self.stringDelSpecialSymbol("옛 날 옛날 한옛날에 백두산에 호랑이가 살고있었어요")
//
//            var chkCnt = 0;
//
//            for chkS in chkTxt
//            {
//                //특수문자는 인덱스만 증가시키고 비교는 X
//                while(self.stringDelSpecialSymbol(String(arrOrgS[chkCnt])) == "")
//                {
//
//                    chkCnt+=1
//
//                    if(chkCnt>=orgTxt.count-1)
//                    {
//                        break
//                    }
//                }
//
//                //문자가 서로 같을경우 인덱스 증가.
//                if(String(chkS) == String(arrOrgS[chkCnt]))
//                {
//                    chkCnt+=1
//
//                    //원본글 마지막에서 특수문자가 있을수도 있기떄문에 체크 후 있으면 인덱스 증가.
//                    while(self.stringDelSpecialSymbol(String(arrOrgS[chkCnt])) == "")
//                    {
//                        chkCnt+=1
//
//                        if(chkCnt>orgTxt.count-1)
//                        {
//                            break
//                        }
//                    }
//
//                    continue
//                }
//
//            }
//
//            print(orgTxt.substring(to:orgTxt.index(orgTxt.startIndex, offsetBy:chkCnt)))

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
                
                var speechTotalTxt = "" // 비교할 총 음성 텍스트
                var readTotalChkTxt = "" // 비교할 총 스피치할 텍스트?
                
                var speechTxt = "" //음성 텍스트
                var readChkTxt = ""    //스피치 할 텍스트.
                
                if result != nil {
                    
                    
                    if(self.chkTxtCnt < self.readTxt.count)
                    {
                        speechTotalTxt = self.stringDelSpecialSymbol(result?.bestTranscription.formattedString ?? "")
                                            
                        readChkTxt = self.readTxt[self.chkTxtCnt]
                        
                        
                        
                        //이미 인식한 문장의 경우는 제외하고 비교.
                        for i in 0..<self.chkTxtCnt {
                            readTotalChkTxt+=self.stringDelSpecialSymbol(self.readTxt[i])
                        }
                        speechTxt = speechTotalTxt.replacingOccurrences(of: readTotalChkTxt, with: "")
                        
                        
                        
                        
                        
                        /* 특수문자를 제거하지 않은 원본문장에서 비교하여 해당 문자열 꺼내오기 */
                        let orgTxt = readChkTxt
                        let arrOrgS = Array(orgTxt)
                        
                        let chkTxt = self.stringDelSpecialSymbol(speechTxt)
                        
                        var chkCnt = 0;
                        
                        for chkS in chkTxt
                        {
                            //특수문자는 인덱스만 증가시키고 비교는 X
                            while(self.stringDelSpecialSymbol(String(arrOrgS[chkCnt])) == "")
                            {
                                
                                chkCnt+=1
                                
                                if(chkCnt>=orgTxt.count-1)
                                {
                                    break
                                }
                            }
                            
                            //문자가 서로 같을경우 인덱스 증가.
                            if(String(chkS) == String(arrOrgS[chkCnt]))
                            {
                                chkCnt+=1
                                
                                //원본글 마지막에서 특수문자가 있을수도 있기떄문에 체크 후 있으면 인덱스 증가.
                                while(self.stringDelSpecialSymbol(String(arrOrgS[chkCnt])) == "")
                                {
                                    chkCnt+=1
                                    
                                    if(chkCnt>orgTxt.count-1)
                                    {
                                        break
                                    }
                                }
                                
                                continue
                            }
                            
                        }
                        
                        print(orgTxt.substring(to:orgTxt.index(orgTxt.startIndex, offsetBy:chkCnt)))
                        speechTxt = orgTxt.substring(to:orgTxt.index(orgTxt.startIndex, offsetBy:chkCnt))
                        
                        
                        
                        
                        
                        
                        
                        //self.LbSpeech.text = ""//speechTxt
                        
                        
                        
                        
                                                    /* -- 같은 문장의 경우 하이라이트 처리. -- */
                        
                        // NSMutableAttributedString Type으로 바꾼 text를 저장
                        let attributedStr = NSMutableAttributedString(string: readChkTxt)

                        // text의 range 중에서 스피치 한 글자는 UIColor를 blue로 변경
                        attributedStr.addAttribute(.foregroundColor, value: UIColor.blue, range: (readChkTxt as NSString).range(of: speechTxt))
                        
                        // 설정이 적용된 text를 label의 attributedText에 저장
                        self.LbText.attributedText = attributedStr
                        
                        
                        isFinal = (result?.isFinal)!
                    }
                    
                    
                    if((readChkTxt == speechTxt) && self.chkTxtCnt <= self.readTxt.count)
                    {
                        
                        
                        
                        if(self.chkTxtCnt >= self.readTxt.count)
                        {
                            isFinal = true
                            
                            self.audioEngine.stop()
                            self.recognitionRequest?.endAudio()
                            self.BtnSpeech.isEnabled = false
                            self.BtnSpeech.setTitle("Start", for: .normal)
                            
                        }else {
                            self.chkTxtCnt+=1
                            speechTxt = ""
                        }
                    }
                    
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

