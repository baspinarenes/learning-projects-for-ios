//
//  ContentView.swift
//  WordScramble
//
//  Created by Enes Başpınar on 2.09.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var derivedWords:  [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isShowingError = false
    
    var body: some View {
        NavigationStack {
            Text("Score: \(score)")
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit(addNewWord)
                }
                
                Section {
                    ForEach(derivedWords, id: \.self) { word in
                        HStack(alignment: .center) {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("New word") {
                    startGame()
                }
            }
            .alert(errorTitle, isPresented: $isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear(perform: startGame)
        }
        .background(.red)
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else { return }
        guard answer != rootWord else { return }

        guard !isAlreadyUsedWord(for: answer) else {
            prepareErrorContent(title: "Word used already", message: "Be more orginal")
            return
        }
        
        guard isPossibleWord(for: answer) else {
            prepareErrorContent(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isRealWord(for: answer) else {
            prepareErrorContent(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        score += newWord.count * (derivedWords.count + 1)
        
        withAnimation {
            derivedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    func clearPreviousData() {
        derivedWords.removeAll()
        newWord = ""
        score = 0
    }
    
    func startGame() {
        clearPreviousData()
        
        if let startWordsFileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWordsFileContent = try? String(contentsOf: startWordsFileUrl) {
                let words = startWordsFileContent.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "silkworm"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isAlreadyUsedWord(for word: String) -> Bool { derivedWords.contains(word) }
    
    func isPossibleWord(for word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isRealWord(for word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func prepareErrorContent(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isShowingError = true
    }
}

#Preview {
    ContentView()
}
