//
//  TextReadingModeView.swift
//  VisualAssist
//
//  OCR-based text reading with batch frame processing
//

import SwiftUI
import AVFoundation

struct TextReadingModeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var textRecognitionService = TextRecognitionService()
    @StateObject private var cameraService = CameraService()
    @StateObject private var liveTextProcessor = LiveTextProcessor()
    
    @State private var isFrozen = false
    @State private var isLiveReading = false
    @State private var recognizedText = ""
    @State private var isReading = false
    @State private var showDebug = false
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewWithFocus(cameraService: cameraService)
                .ignoresSafeArea()
                .opacity(isFrozen ? 0.5 : 1.0)
            
            // Detected text overlay
            if !recognizedText.isEmpty && isFrozen {
                textOverlay
            }
            
            // Controls
            VStack {
                topBar
                
                // Debug info
                if showDebug {
                    debugPanel
                }
                
                Spacer()
                
                // Live reading indicator
                if isLiveReading && !isFrozen {
                    liveReadingIndicator
                }
                
                // Text display area
                if !recognizedText.isEmpty {
                    textDisplayArea
                }
                
                controlButtons
            }
            .padding()
        }
        .onAppear {
            cameraService.startSession()
            appState.hapticService.play(.modeSwitch)
            appState.speechService.speak("Text reading mode. Point camera at text.")
            
            // Setup live text processor
            liveTextProcessor.speechService = appState.speechService
            liveTextProcessor.hapticService = appState.hapticService
            liveTextProcessor.textRecognitionService = textRecognitionService
            liveTextProcessor.onTextUpdated = { text in
                recognizedText = text
            }
            
            // Setup frame callback for live reading - capture frames continuously
            cameraService.onFrameCaptured = { image in
                if isLiveReading && !isFrozen {
                    liveTextProcessor.addFrame(image)
                }
            }
        }
        .onDisappear {
            cameraService.stopSession()
            appState.speechService.stop()
            liveTextProcessor.stop()
        }
    }
    
    // MARK: - Debug Panel
    
    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔧 BATCH DEBUG")
                .font(.caption.bold())
                .foregroundColor(.yellow)
            Text("Frames collected: \(liveTextProcessor.framesCollected)")
            Text("Batches processed: \(liveTextProcessor.batchCount)")
            Text("Queue size: \(liveTextProcessor.queueSize)")
            Text("Speaking: \(liveTextProcessor.isSpeaking ? "Yes" : "No")")
        }
        .font(.system(.caption2, design: .monospaced))
        .foregroundColor(.white)
        .padding(8)
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: { appState.switchMode(to: .home) }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
            }
            .accessibilityLabel("Back to home")
            
            Spacer()
            
            // Debug toggle
            Button(action: { showDebug.toggle() }) {
                Image(systemName: "ladybug")
                    .foregroundColor(showDebug ? .yellow : .white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            
            // Status
            HStack(spacing: 8) {
                if isLiveReading && !isFrozen {
                    Circle()
                        .fill(liveTextProcessor.isSpeaking ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                }
                Image(systemName: isFrozen ? "camera.fill" : (isLiveReading ? "eye.fill" : "viewfinder"))
                Text(isFrozen ? "Frozen" : (isLiveReading ? "Live OCR" : "Live"))
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Live Reading Indicator
    
    private var liveReadingIndicator: some View {
        VStack(spacing: 8) {
            HStack {
                if liveTextProcessor.isSpeaking {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.orange)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                }
                
                Text(liveTextProcessor.isSpeaking ? "Reading text..." : "Scanning (\(liveTextProcessor.framesCollected) frames)...")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            if liveTextProcessor.queueSize > 0 {
                Text("\(liveTextProcessor.queueSize) more to read")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(liveTextProcessor.isSpeaking ? Color.orange.opacity(0.3) : Color.green.opacity(0.3))
        .cornerRadius(25)
    }
    
    // MARK: - Text Overlay
    
    private var textOverlay: some View {
        GeometryReader { geometry in
            ForEach(textRecognitionService.textBlocks) { block in
                let rect = block.boundingBox.applying(
                    CGAffineTransform(scaleX: geometry.size.width, y: geometry.size.height)
                        .translatedBy(x: 0, y: 1)
                        .scaledBy(x: 1, y: -1)
                )
                
                Rectangle()
                    .strokeBorder(Color.green, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }
    
    // MARK: - Text Display Area
    
    private var textDisplayArea: some View {
        ScrollView {
            Text(recognizedText)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        VStack(spacing: 12) {
            // Main action row
            HStack(spacing: 16) {
                // Freeze/Unfreeze
                AccessibleButton(
                    icon: isFrozen ? "camera.fill" : "camera.viewfinder",
                    label: isFrozen ? "Unfreeze" : "Freeze",
                    color: .blue
                ) {
                    toggleFreeze()
                }
                
                // Read/Stop - now also stops live reading speech
                AccessibleButton(
                    icon: (isReading || liveTextProcessor.isSpeaking) ? "stop.fill" : "play.fill",
                    label: (isReading || liveTextProcessor.isSpeaking) ? "Stop" : "Read",
                    color: (isReading || liveTextProcessor.isSpeaking) ? .red : .green,
                    size: .large
                ) {
                    toggleReading()
                }
                
                // Live Reading Toggle
                AccessibleButton(
                    icon: isLiveReading ? "eye.slash.fill" : "eye.fill",
                    label: isLiveReading ? "Stop Live" : "Live Read",
                    color: isLiveReading ? .orange : .purple
                ) {
                    toggleLiveReading()
                }
            }
            
            // Speed controls row
            HStack(spacing: 20) {
                Button(action: { adjustSpeed(faster: false) }) {
                    HStack {
                        Image(systemName: "tortoise.fill")
                        Text("Slower")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                }
                
                Button(action: { adjustSpeed(faster: true) }) {
                    HStack {
                        Image(systemName: "hare.fill")
                        Text("Faster")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleFreeze() {
        isFrozen.toggle()
        
        if isFrozen {
            isLiveReading = false
            liveTextProcessor.stop()
            
            Task {
                if let image = cameraService.captureCurrentFrame() {
                    recognizedText = await textRecognitionService.recognizeText(in: image)
                    appState.hapticService.play(.success)
                    
                    if recognizedText.isEmpty {
                        appState.speechService.speak("No text detected.")
                    } else {
                        let wordCount = recognizedText.components(separatedBy: .whitespaces).count
                        appState.speechService.speak("Found \(wordCount) words. Tap Read to hear.")
                    }
                }
            }
        } else {
            recognizedText = ""
            textRecognitionService.clearResults()
            appState.speechService.speak("Camera unfrozen")
        }
    }
    
    private func toggleReading() {
        // Stop any ongoing speech (both manual and live)
        if isReading || liveTextProcessor.isSpeaking {
            appState.speechService.stop()
            liveTextProcessor.clearQueue()
            isReading = false
            return
        }
        
        // Start reading frozen text
        if !recognizedText.isEmpty && !isLiveReading {
            isReading = true
            appState.speechService.speak(recognizedText) {
                isReading = false
            }
        } else if recognizedText.isEmpty {
            appState.speechService.speak("No text to read.")
        }
    }
    
    private func toggleLiveReading() {
        isLiveReading.toggle()
        
        if isLiveReading {
            isFrozen = false
            liveTextProcessor.start()
            appState.speechService.speak("Live reading started. I will read text as I see it.")
            appState.hapticService.play(.success)
        } else {
            liveTextProcessor.stop()
            appState.speechService.stop()
            appState.speechService.speak("Live reading stopped")
            appState.hapticService.play(.tap)
        }
    }
    
    private func adjustSpeed(faster: Bool) {
        appState.speechService.adjustRate(faster: faster)
        appState.hapticService.play(.tap)
    }
}

// MARK: - Live Text Processor with Batch Processing

@MainActor
class LiveTextProcessor: ObservableObject {
    @Published var framesCollected = 0
    @Published var batchCount = 0
    @Published var isSpeaking = false
    @Published var queueSize = 0
    
    var speechService: SpeechService?
    var hapticService: HapticService?
    var textRecognitionService: TextRecognitionService?
    var onTextUpdated: ((String) -> Void)?
    
    private var isActive = false
    private var frameBuffer: [CGImage] = []
    private var textQueue: [String] = []
    private var lastSpokenText = ""
    private var batchTimer: Timer?
    private let batchInterval: TimeInterval = 2.5  // Collect frames for 2.5 seconds
    private let maxFramesPerBatch = 5  // Process up to 5 frames per batch
    
    func start() {
        isActive = true
        frameBuffer = []
        textQueue = []
        lastSpokenText = ""
        framesCollected = 0
        batchCount = 0
        isSpeaking = false
        queueSize = 0
        
        // Start batch timer
        startBatchTimer()
    }
    
    func stop() {
        isActive = false
        batchTimer?.invalidate()
        batchTimer = nil
        frameBuffer = []
        textQueue = []
        framesCollected = 0
        isSpeaking = false
        queueSize = 0
    }
    
    func clearQueue() {
        textQueue = []
        queueSize = 0
        isSpeaking = false
    }
    
    private func startBatchTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.processBatch()
            }
        }
    }
    
    nonisolated func addFrame(_ image: CGImage) {
        Task { @MainActor in
            guard isActive else { return }
            
            // Keep only the most recent frames
            if frameBuffer.count >= maxFramesPerBatch {
                frameBuffer.removeFirst()
            }
            frameBuffer.append(image)
            framesCollected = frameBuffer.count
        }
    }
    
    private func processBatch() {
        guard isActive, !frameBuffer.isEmpty else { return }
        guard let service = textRecognitionService else { return }
        
        let framesToProcess = Array(frameBuffer.suffix(maxFramesPerBatch))
        frameBuffer.removeAll()
        framesCollected = 0
        batchCount += 1
        
        print("[LiveText] Processing batch \(batchCount) with \(framesToProcess.count) frames")
        
        Task {
            // Process all frames and collect texts
            var detectedTexts: [String] = []
            
            for frame in framesToProcess {
                let text = await service.recognizeText(in: frame)
                let cleaned = cleanText(text)
                if !cleaned.isEmpty {
                    detectedTexts.append(cleaned)
                }
            }
            
            guard !detectedTexts.isEmpty else {
                print("[LiveText] Batch \(batchCount): No text detected")
                return
            }
            
            // Find the most common/stable text (appears most frequently)
            let stableText = findMostStableText(detectedTexts)
            
            print("[LiveText] Batch \(batchCount): Stable text found (\(stableText.count) chars)")
            
            // Check if different from last spoken
            let similarity = textSimilarity(stableText, lastSpokenText)
            
            if similarity < 0.7 {  // Text is different enough
                lastSpokenText = stableText
                
                // Add to queue
                await MainActor.run {
                    textQueue.append(stableText)
                    queueSize = textQueue.count
                    onTextUpdated?(stableText)
                    
                    // Start speaking if not already
                    if !isSpeaking {
                        speakNextInQueue()
                    }
                }
            } else {
                print("[LiveText] Batch \(batchCount): Text too similar to last spoken (similarity: \(Int(similarity * 100))%)")
            }
        }
    }
    
    private func speakNextInQueue() {
        guard isActive, !textQueue.isEmpty else {
            isSpeaking = false
            queueSize = 0
            return
        }
        
        let text = textQueue.removeFirst()
        queueSize = textQueue.count
        isSpeaking = true
        
        hapticService?.play(.tap)
        speechService?.speak(text, mode: .natural) { [weak self] in
            Task { @MainActor in
                // When done, speak next in queue
                self?.speakNextInQueue()
            }
        }
    }
    
    private func findMostStableText(_ texts: [String]) -> String {
        guard !texts.isEmpty else { return "" }
        
        // If only one text, return it
        if texts.count == 1 { return texts[0] }
        
        // Find the text that is most similar to others (centroid)
        var bestText = texts[0]
        var bestScore: Double = 0
        
        for text in texts {
            var totalSimilarity: Double = 0
            for other in texts where text != other {
                totalSimilarity += textSimilarity(text, other)
            }
            let avgSimilarity = totalSimilarity / Double(texts.count - 1)
            
            if avgSimilarity > bestScore {
                bestScore = avgSimilarity
                bestText = text
            }
        }
        
        return bestText
    }
    
    private func cleanText(_ text: String) -> String {
        let cleaned = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        let wordCount = cleaned.components(separatedBy: " ").count
        return wordCount >= 3 ? cleaned : ""
    }
    
    private func textSimilarity(_ text1: String, _ text2: String) -> Double {
        guard !text1.isEmpty && !text2.isEmpty else { return 0 }
        
        let words1 = Set(text1.lowercased().components(separatedBy: " "))
        let words2 = Set(text2.lowercased().components(separatedBy: " "))
        
        let intersection = words1.intersection(words2)
        let union = words1.union(words2)
        
        guard !union.isEmpty else { return 0 }
        return Double(intersection.count) / Double(union.count)
    }
}

// MARK: - Camera Preview with Focus

struct CameraPreviewWithFocus: UIViewRepresentable {
    @ObservedObject var cameraService: CameraService
    
    func makeUIView(context: Context) -> FocusableCameraView {
        let view = FocusableCameraView()
        view.cameraService = cameraService
        return view
    }
    
    func updateUIView(_ uiView: FocusableCameraView, context: Context) {
        uiView.updatePreviewLayer()
    }
}

class FocusableCameraView: UIView {
    var cameraService: CameraService? {
        didSet {
            setupPreviewLayer()
            setupTapGesture()
        }
    }
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var focusIndicator: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    @MainActor
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        showFocusIndicator(at: point)
        cameraService?.focusAt(point: point, in: bounds.size)
    }
    
    private func showFocusIndicator(at point: CGPoint) {
        focusIndicator?.removeFromSuperview()
        
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        indicator.center = point
        indicator.layer.borderColor = UIColor.yellow.cgColor
        indicator.layer.borderWidth = 2
        indicator.layer.cornerRadius = 40
        indicator.alpha = 0
        
        addSubview(indicator)
        focusIndicator = indicator
        
        UIView.animate(withDuration: 0.2, animations: {
            indicator.alpha = 1
            indicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                indicator.alpha = 0
            }) { _ in
                indicator.removeFromSuperview()
            }
        }
    }
    
    @MainActor
    func setupPreviewLayer() {
        guard let cameraService = cameraService else { return }
        
        previewLayer?.removeFromSuperlayer()
        
        let layer = cameraService.previewLayer
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        previewLayer = layer
        
        backgroundColor = .black
        cameraService.startSession()
    }
    
    func updatePreviewLayer() {
        previewLayer?.frame = bounds
    }
}

#Preview {
    TextReadingModeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
