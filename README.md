# SignConnect (iOS)

**A privacy-first, native assistive communication tool for the deaf and non-verbal community.**

SignConnect iOS is a complete re-architecture of the original web platform, designed specifically for modern Apple hardware. By leveraging the Neural Engine on iPhone 15 Pro and newer devices, SignConnect moves all intelligence—speech recognition, response generation, and semantic search—**entirely on-device**.

## Why Native?

* **100% Privacy:** No conversation data ever leaves the device. All processing happens locally.
* **Offline Capable:** Works perfectly without an internet connection—crucial for reliability in daily life.
* **Zero Latency:** Eliminates network round-trips for faster, more natural conversation flows.
* **No Subscription:** By removing cloud API costs, the app is sustainable as a one-time purchase.

## Key Features

* **Real-time Transcription:** Uses Apple's `SFSpeechRecognizer` for instant, offline speech-to-text.
* **Apple Intelligence Integration:** Powered by the `FoundationModels` framework (`SystemLanguageModel`) to generate context-aware, empathetic responses.
* **Local RAG (Retrieval-Augmented Generation):** Implements a custom on-device vector search using `NaturalLanguage` embeddings and the `Accelerate` framework to match user scenarios.
* **Structured Output:** Generates strictly typed Swift data for predictable UI suggestions using `@Generable` macros.

## Tech Stack

* **Language:** Swift 6
* **UI Framework:** SwiftUI
* **Data Persistence:** SwiftData
* **AI/LLM:** FoundationModels (Apple Intelligence)
* **Speech:** Speech Framework (SFSpeechRecognizer)
* **Vector Search:** NaturalLanguage + Accelerate (vDSP)
* **Minimum OS:** iOS 18.1+

## Hardware Requirements

To support the on-device `SystemLanguageModel`, this application requires devices capable of running **Apple Intelligence**:

* **iPhone:** iPhone 15 Pro, iPhone 15 Pro Max, or iPhone 16 series (and newer).
* **iPad:** M1 iPad Air/Pro (and newer).
* **Mac:** M1 MacBook Air/Pro (and newer).

## Getting Started

### Prerequisites
* Xcode 16.0+
* An Apple Developer Account (for on-device testing capabilities)

### Installation
1.  Clone the repository:
    ```bash
    git clone [https://github.com/HowDiggy/SignConnect-iOS.git](https://github.com/HowDiggy/SignConnect-iOS.git)
    ```
2.  Open `SignConnect.xcodeproj` in Xcode.
3.  Ensure your signing team is selected in the Project Settings.
4.  Build and run on a physical device (Simulators do not support full Neural Engine capabilities).

---
**Author:** Paulo Jauregui
