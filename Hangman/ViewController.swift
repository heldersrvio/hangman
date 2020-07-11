//
//  ViewController.swift
//  Hangman
//
//  Created by Helder on 11/07/20.
//  Copyright © 2020 Helder de Melo Sérvio Filho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var wordList: [String] = []
    var currentWord = "" {
        didSet {
            wordGuessField.text = currentWord.map{_ in "_"}.joined(separator: " ")
            if currentWord.count > 7 {
                wordGuessField.font = UIFont.systemFont(ofSize: 60 - CGFloat(currentWord.count - 7) * 10)
            }
        }
    }
    var timesFailed = 0 {
        didSet {
            triesLeftLabel.text = "Tries left: \(8 - timesFailed)"
        }
    }
    var guessedLetters: [Character] = []
    var wordGuessField: UITextField!
    var triesLeftLabel: UILabel!
    var letterButtons: [UIButton] = []
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        triesLeftLabel = UILabel()
        triesLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        triesLeftLabel.text = "Tries left: 8"
        triesLeftLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(triesLeftLabel)
        
        wordGuessField = UITextField()
        wordGuessField.isUserInteractionEnabled = false
        wordGuessField.translatesAutoresizingMaskIntoConstraints = false
        wordGuessField.font = UIFont.systemFont(ofSize: 60)
        view.addSubview(wordGuessField)
        
        let letterButtonsView = renderLetterButtons()
        view.addSubview(letterButtonsView)
        
        NSLayoutConstraint.activate([
            wordGuessField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordGuessField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            wordGuessField.widthAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.widthAnchor, constant: -10),
            triesLeftLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            triesLeftLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            letterButtonsView.widthAnchor.constraint(equalToConstant: 330),
            letterButtonsView.heightAnchor.constraint(equalToConstant: 160),
            letterButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letterButtonsView.topAnchor.constraint(equalTo: wordGuessField.bottomAnchor, constant: 60)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadWordList), with: nil)
    }
    
    @objc func loadWordList() {
        if let wordsFilePath = Bundle.main.path(forResource: "words", ofType: "txt") {
            if let fileWords = try? String(contentsOfFile: wordsFilePath).components(separatedBy: " ").filter({!$0.contains("-")}){
                wordList = fileWords
                performSelector(onMainThread: #selector(newWord), with: nil, waitUntilDone: false)
            }
        }
    }
    
    @objc func newWord() {
        if let wordListRandomElement = wordList.randomElement()?.uppercased() {
            currentWord = wordListRandomElement
        }
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        sender.isHidden = true
        
        if let letter = sender.titleLabel?.text {
            if currentWord.contains(letter) {
                wordGuessField.text = currentWord.map{
                    character in
                    if String(character) == letter {
                        return letter
                    } else if guessedLetters.contains(character) {
                        return String(character)
                    }
                    return "_"
                }.joined(separator: " ")
                guessedLetters.append(Character(letter))
                
                if wordGuessField.text?.filter({$0 == "_"}).count == 0 {
                    displayWonMessage()
                }
            } else {
                timesFailed += 1
                
                if timesFailed == 8 {
                    displayLostMessage()
                }
            }
        }
    }
    
    func newLevel() {
        for button in letterButtons {
            button.isHidden = false
        }
        timesFailed = 0
        guessedLetters = []
        newWord()
    }
    
    func displayWonMessage() {
        let ac = UIAlertController(title: "You won!", message: "Congratulations. Now play once again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
           [weak self] _ in
           self?.newLevel()
       })
        present(ac, animated: true)
    }
    
    func displayLostMessage() {
        let ac = UIAlertController(title: "You lost", message: "The correct word was \(currentWord)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self] _ in
            self?.newLevel()
        })
        present(ac, animated: true)
    }
    
    func renderLetterButtons() -> UIView{
        let letterButtonsView = UIView()
        letterButtonsView.translatesAutoresizingMaskIntoConstraints = false
        for letterCode in 65...90 {
            let letterButton = UIButton(type: .roundedRect)
            letterButton.backgroundColor = .systemGreen
            letterButton.setTitleColor(.white, for: .normal)
            letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            letterButton.layer.cornerRadius = 5
            if let letter = Unicode.Scalar(letterCode) {
                letterButton.setTitle(String(letter), for: .normal)
            }
            let row: Int
            let column: Int = (letterCode < 89) ? (letterCode - 65) % 8 : (letterCode - 65) % 8 + 3
            switch (letterCode) {
            case 65...72:
                row = 0
            case 73...80:
                row = 1
            case 81...88:
                row = 2
            default:
                row = 3
            }
            let frame = CGRect(x: column * 40, y: row * 32, width: 38, height: 30)
            letterButton.frame = frame
            letterButtons.append(letterButton)
            letterButtonsView.addSubview(letterButton)
        }
        return letterButtonsView
    }


}

