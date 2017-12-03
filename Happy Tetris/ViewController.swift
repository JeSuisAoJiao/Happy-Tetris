//
//  ViewController.swift
//  Happy Tetris
//
//  Created by SHENGXinheng on 31/10/2017.
//  Copyright © 2017 SHENGXinheng. All rights reserved.
//

import UIKit

protocol HappyOption {
    func doHappy()
    func getBlank() -> (blank: [Bool], nb_col: Int)
}

class ViewController: UIViewController, HappyOption {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var preview: Preview!
    @IBOutlet weak var board: Board!
    var startStopButton = UIButton()
    var restartButton = UIButton()
    var mode1Button = UIButton()
    var mode2Button = UIButton()
    
    let blocLength: CGFloat = 25
    var blank = [Bool]()
    var running = true
    var shape: Shape?
    var timer: Timer?
    var timeUpdater: Timer?
    var time: Int = 0
    var mode: MODE = .EASY
    var gameOver: Bool = false
    var shapeSettled: Bool = true {
        didSet{
            if shapeSettled && !oldValue{
                score += 10
                newShape()
            }
        }
    }
    var score: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blank = Array<Bool>(repeating: true, count: Int(board.bounds.size.height * board.bounds.size.width / blocLength / blocLength))
        board.initialzePath(blocLength: blocLength)
        preview.initialize(delegate: self)
        timeUpdater = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        newShape()
        addOptions()
    }
    
    func addOptions() {
        let buttonHeight = board.bounds.size.height / 3
        let buttonWidth = board.bounds.size.width
        
        startStopButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        startStopButton.backgroundColor = UIColor.clear
        startStopButton.titleLabel?.font = startStopButton.titleLabel?.font.withSize(100)
        startStopButton.addTarget(self, action: #selector(optionTapped), for: UIControlEvents.touchUpInside)
        shape?.addSubview(startStopButton)
        
        restartButton = UIButton(frame: CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight))
        restartButton.backgroundColor = UIColor.clear
        restartButton.titleLabel?.font = restartButton.titleLabel?.font.withSize(100)
        restartButton.addTarget(self, action: #selector(optionTapped), for: UIControlEvents.touchUpInside)
        shape?.addSubview(restartButton)
        
        mode1Button = UIButton(frame: CGRect(x: 0, y: buttonHeight * 2, width: buttonWidth / 2, height: buttonHeight))
        mode1Button.backgroundColor = UIColor.clear
        mode1Button.titleLabel?.font = mode1Button.titleLabel?.font.withSize(40)
        mode1Button.addTarget(self, action: #selector(optionTapped), for: UIControlEvents.touchUpInside)
        shape?.addSubview(mode1Button)
        
        mode2Button = UIButton(frame: CGRect(x: buttonWidth / 2, y: buttonHeight * 2, width: buttonWidth / 2, height: buttonHeight))
        mode2Button.backgroundColor = UIColor.clear
        mode2Button.titleLabel?.font = mode2Button.titleLabel?.font.withSize(40)
        mode2Button.addTarget(self, action: #selector(optionTapped), for: UIControlEvents.touchUpInside)
        shape?.addSubview(mode2Button)
    }
    
    func restart() {
        gameOver = false
        timer?.invalidate()
        board.reset()
        blank = Array<Bool>(repeating: true, count: Int(board.bounds.size.height * board.bounds.size.width / blocLength / blocLength))
        score = 0
        time = 0
        newShape()
        if !startStopButton.isEnabled {
            startStopButton.isEnabled = true
        }
    }
    
    @objc func updateTime() {
        if running {
            if time < 3600 {
                time += 1
                DispatchQueue.main.async {
                    self.timeLabel.text = String(format: "%02d:%02d", self.time / 60, self.time % 60)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newShape() {
        shapeSettled = false
        let shapeInfo = preview.getNextShape()
        preview.setNeedsDisplay()
        if shape == nil {
            shape = Shape(shape: shapeInfo.shape, color: shapeInfo.color, length: blocLength, board: board)
            board.addSubview(shape!)
            board.setNeedsDisplay()
        } else {
            shape?.reset(shape: shapeInfo.shape, color: shapeInfo.color)
            for i in 0...3 {
                if !blank[(shape?.indices[i])!]{
                    gameOver = true
                    optionTapped(sender: startStopButton)
                    return
                }
            }
            shape?.setNeedsDisplay()
        }
        switch mode {
        case .EASY:
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
        case .NORMAL:
            if time < 180 {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            } else if time < 360 {
                timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            } else if time < 480{
                timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            }
        case .HARD:
            if time < 240 {
                timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
            }
        case .HAPPY:
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(stepDown), userInfo: nil, repeats: true)
        }
    }
    
    @objc func stepDown() {
        if running {
            if (shape?.stepDown(blank: blank))! {
                shape?.setNeedsDisplay()
            } else {
                //shape?.setNeedsDisplay()
                timer?.invalidate()
                refreshBoard()
            }
        }
    }
    
    private func refreshBoard() {
        var bloc: Bloc
        for index in (shape?.indices)! {
            blank[index] = false
            bloc = Bloc(index: index, nb_col: Int(board.bounds.size.width / blocLength), length: blocLength, color: (shape?.color)!)
            board.addBloc(bloc: bloc, index: index)
        }
        board.setNeedsDisplay()
        DispatchQueue.global(qos: .userInitiated).async {
            self.board.checkRows(blank: &self.blank, score: &self.score)
        }
        self.shapeSettled = true
    }

    @IBAction func leftTapped(_ sender: UIButton) {
        if running {
            shape?.leftTanslate(blank: blank)
            shape?.setNeedsDisplay()
        }
    }
    
    @IBAction func downTapped(_ sender: UIButton) {
        if running {
            timer?.invalidate()
            while (shape?.stepDown(blank: blank))! {}
            //shape?.setNeedsDisplay()
            refreshBoard()
        }
    }
    
    @IBAction func rotateTapped(_ sender: UIButton) {
        if running {
            shape?.rotate(blank: blank)
            shape?.setNeedsDisplay()
        }
    }
    
    @IBAction func rightTapped(_ sender: UIButton) {
        if running {
            shape?.rightTanslate(blank: blank)
            shape?.setNeedsDisplay()
        }
    }
    
    @objc func optionTapped(sender: UIButton) {
        if sender.backgroundColor == UIColor.clear {
            running = false
            startStopButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            if gameOver {
                startStopButton.titleLabel?.font = startStopButton.titleLabel?.font.withSize(40)
                startStopButton.setTitle("\(score)", for: UIControlState.normal)
                startStopButton.isEnabled = false
            }else {
                startStopButton.titleLabel?.font = startStopButton.titleLabel?.font.withSize(100)
                startStopButton.setTitle("▶", for: UIControlState.normal)
            }
            restartButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            restartButton.setTitle("↻", for: UIControlState.normal)
            mode1Button.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            if mode == .EASY{
                mode1Button.setTitle(MODE.NORMAL.rawValue, for: UIControlState.normal)
            }
            else {
                mode1Button.setTitle(MODE.EASY.rawValue, for: UIControlState.normal)
            }
            mode2Button.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
            if mode == .HARD{
                mode2Button.setTitle(MODE.NORMAL.rawValue, for: UIControlState.normal)
            }
            else {
                mode2Button.setTitle(MODE.HARD.rawValue, for: UIControlState.normal)
            }
        } else {
            running = true
            if sender == restartButton {
                if mode == .HAPPY {
                    mode = .NORMAL
                    preview.backToNormal()
                }
                restart()
            } else if sender == mode1Button || sender == mode2Button{
                mode = MODE(rawValue: sender.currentTitle!)!
                preview.backToNormal()
                restart()
            }
            startStopButton.backgroundColor = UIColor.clear
            startStopButton.setTitle("", for: UIControlState.normal)
            restartButton.backgroundColor = UIColor.clear
            restartButton.setTitle("", for: UIControlState.normal)
            mode1Button.backgroundColor = UIColor.clear
            mode1Button.setTitle("", for: UIControlState.normal)
            mode2Button.backgroundColor = UIColor.clear
            mode2Button.setTitle("", for: UIControlState.normal)
        }
    }
    
    func doHappy() {
        if !running {
            running = true
            mode = .HAPPY
            restart()
            startStopButton.backgroundColor = UIColor.clear
            startStopButton.setTitle("", for: UIControlState.normal)
            restartButton.backgroundColor = UIColor.clear
            restartButton.setTitle("", for: UIControlState.normal)
            mode1Button.backgroundColor = UIColor.clear
            mode1Button.setTitle("", for: UIControlState.normal)
            mode2Button.backgroundColor = UIColor.clear
            mode2Button.setTitle("", for: UIControlState.normal)
        }
    }
    
    func getBlank() -> (blank: [Bool], nb_col: Int) {
        return (blank, Int(board.bounds.size.width / blocLength))
    }
    
}

enum MODE: String {
    case EASY = "Easy", NORMAL = "Normal", HARD = "Hard", HAPPY = "Happy"
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000FF) >> 0) / 255
                    a = 1
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
