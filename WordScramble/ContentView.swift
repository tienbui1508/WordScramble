//
//  ContentView.swift
//  WordScramble
//
//  Created by Tien Bui on 24/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    @State private var score = 0

    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }

                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(word), \(word.count) letters")
                        }
                    }
                }
                    .navigationTitle(rootWord)
                    .onSubmit(addNewWord)
                    .onAppear(perform: startGame)
                    .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Reset game", action: startGame)
                }
            }
            Text("Score: \(score)")
                .font(.title)
                .bold()
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up!")
            return
        }

        guard !isStartWord(word: answer) else {
            wordError(title: "Start word used", message: "You can't use the start word")
            return
        }

        guard !isTooShort(word: answer) else {
            wordError(title: "Word too short", message: "Your answer must have at least 3 letters")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }

        score += answer.count

        newWord = ""
    }

    func startGame() {
        newWord = ""
        usedWords.removeAll()
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from the bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isStartWord(word: String) -> Bool {
        word == rootWord
    }

    func isTooShort(word: String) -> Bool {
        word.count < 3
    }

    func isPossible(word: String) -> Bool {
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

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
