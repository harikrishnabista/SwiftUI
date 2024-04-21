import SwiftUI
import Speech
import AVFoundation

struct TranscribeView: View {
    @State private var isRecording = false

    @StateObject var vm: TranscribeViewModel = TranscribeViewModel()
    
    var body: some View {
        VStack {
            
            if let recognizedText = vm.recognizedText {
                Text(recognizedText)
                    .padding()
            }
            
            Button(action: {
                
                if self.isRecording {
                    vm.stopRecording()
                } else {
                    vm.startRecording()
                }
                
                self.isRecording.toggle()
                
            }) {
                Text(self.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(self.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

class TranscribeViewModel: ObservableObject {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var recognizedText: String?
    
    func startRecording() {
      
        let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start because of an error: \(error)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                print(result.bestTranscription.formattedString)
                self.recognizedText = result.bestTranscription.formattedString
            } else if let error = error {
                print("Recognition task error: \(error)")
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
    }
}

#Preview {
    TranscribeView()
}
