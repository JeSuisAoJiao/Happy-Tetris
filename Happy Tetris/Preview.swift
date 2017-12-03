//
//  Preview.swift
//  Happy Tetris
//
//  Created by SHENGXinheng on 04/11/2017.
//  Copyright © 2017 SHENGXinheng. All rights reserved.
//

import UIKit

class Preview : UIView{
    var shape: MiniShape?
    var path = UIBezierPath()
    var delegate: HappyOption?
    var isHappy: Bool = false
    
    func initialize(delegate: HappyOption) {
        shape = MiniShape(size: self.bounds.size)
        self.delegate = delegate
    }
    
    func getNextShape() -> (shape: SHAPE, color: UIColor) {
        let currentShape: SHAPE
        if !isHappy {
            currentShape = (shape?.shape)!
        } else {
            currentShape = getHappyShape()
        }
        let currentColor = shape?.color
        shape?.generate()
        return (shape: currentShape, color: currentColor!)
    }
    
    func backToNormal() {
        isHappy = false
    }
    
    @IBAction func activeHappyMode(_ sender: UILongPressGestureRecognizer) {
        isHappy = true
        delegate?.doHappy()
    }
    
    func getHappyShape() -> SHAPE {
        let (blank, nb_col) = (delegate?.getBlank())!
        let nb_row = blank.count / nb_col
        var col = Array<Int>(repeating: 0, count: nb_col)
        for i in 0..<nb_col {
            for j in 0..<nb_row{
                if blank[j * nb_col + i] {
                    col[i] += 1
                } else {
                    break
                }
            }
        }
        var max1 = 0
        var max2 = 0
        var max3 = 0
        var index1 = [Int]()
        var index2 = [Int]()
        var index3 = [Int]()
        for i in 0..<nb_col {
            if max1 < col[i]{
                max1 = col[i]
            }
        }
        max2 = max1 - 1
        max3 = max2 - 1
        for i in 0..<nb_col {
            if max1 == col[i]{
                index1.append(i)
            } else if max2 == col[i]{
                index2.append(i)
            } else if max3 == col[i] {
                index3.append(i)
            }
        }
        let index = index1[0]
        if index - 1 >= 0 {
            if index2.contains(index - 1) {
                if index + 1 < nb_col {
                    if index1.contains(index + 1) {
                        return .Z
                    } else if index2.contains(index + 1) {
                        return .T
                    } else {
                        if index - 2 >= 0 {
                            if index2.contains(index - 2) {
                                return .J
                            } else{
                                return .S
                            }
                        } else {
                            return .S
                        }
                    }
                } else {
                    return .S
                }
            } else if index3.contains(index - 1){
                if index + 1 < nb_col {
                    if index1.contains(index + 1) {
                        return .O
                    } else if index2.contains(index + 1) {
                        return .Z
                    } else {
                        return .L
                    }
                } else {
                    return .L
                }
            } else {
                if index + 1 < nb_col {
                    if index1.contains(index + 1) {
                        return .O
                    } else if index2.contains(index + 1) {
                        return .Z
                    } else if index3.contains(index + 1){
                        return .J
                    } else {
                        return .I
                    }
                } else {
                    return .I
                }
            }
        } else {
            if index1.contains(index + 1) {
                if index1.contains(index + 2) {
                    if index1.contains(index + 3){
                        return .I
                    } else {
                        return .J
                    }
                } else if index2.contains(index + 2){
                    return .S
                } else {
                    return .O
                }
            } else if index2.contains(index + 1) {
                if index2.contains(index + 2) {
                    return .L
                } else {
                    return .T
                }
            } else if index3.contains(index + 1) {
                return .J
            } else {
                return .I
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        if shape == nil {
            super.draw(rect)
        } else {
            backgroundColor?.set()
            path.fill(with: CGBlendMode.normal, alpha: 1)
            path.stroke(with: CGBlendMode.normal, alpha: 1)
            path.removeAllPoints()
            if isHappy {
                return
            }
            backgroundColor?.setStroke()
            for i in 0...3 {
                path.append(UIBezierPath(rect: CGRect(x: (shape?.blocs[i].coor.x)!, y: (shape?.blocs[i].coor.y)!, width: (shape?.length)!, height: (shape?.length)!)))
            }
            shape?.color.setFill()
            path.fill(with: CGBlendMode.normal, alpha: 1)
            path.stroke(with: CGBlendMode.normal, alpha: 1)
        }
    }
}

class MiniBloc {
    var coor: CGPoint
    
    init() {
        coor = CGPoint()
    }
    
    func generate(x: CGFloat, y: CGFloat) {
        coor = CGPoint(x: x, y: y)
    }
    
    func generate(bloc: MiniBloc, diff: CGPoint, length: CGFloat) {
        coor = CGPoint(x: bloc.coor.x + length * diff.x, y: bloc.coor.y + length * diff.y)
    }
}

class MiniShape {
    let y: CGFloat = 2
    let size: CGSize
    let colors = [UIColor(hexString: "#FCC11A"), UIColor(hexString: "#22A5D3"), UIColor(hexString: "#F15A24"), UIColor(hexString: "#B86BCB"), UIColor(hexString: "#00ADAD"), UIColor(hexString: "#FF931E")]
    
    var shape: SHAPE
    var blocs = [MiniBloc]()
    var length: CGFloat?
    var coef = [[CGPoint]]()
    var color: UIColor
    
    
    init(size: CGSize) {
        coef.append([CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0)])
        coef.append([CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 0)])
        coef.append([CGPoint(x: -1, y: 1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 0)])
        coef.append([CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 0)])
        coef.append([CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 1)])
        coef.append([CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)])
        coef.append([CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 1)])
        
        blocs.append(MiniBloc())
        blocs.append(MiniBloc())
        blocs.append(MiniBloc())
        blocs.append(MiniBloc())
        
        shape = SHAPE(rawValue: Int(arc4random_uniform(7)))!
        //shape = SHAPE.O
        color = colors[Int(arc4random_uniform(6))]!
        self.size = size
        generateBlocs()
    }
    
    func generate() {
        shape = SHAPE(rawValue: Int(arc4random_uniform(7)))!
        //shape = SHAPE.O
        color = colors[Int(arc4random_uniform(6))]!
        generateBlocs()
    }
    
    private func generateBlocs() {
        switch shape {
        case .L:
            length = (size.height - y * 2) / 3
            blocs[0].generate(x: (size.width - length! * 2)/2, y: y)
        case .J:
            length = (size.height - y * 2) / 3
            blocs[0].generate(x: (size.width - length! * 2)/2 + length!, y: y)
        case .T:
            length = (size.height - y * 2) / 2
            blocs[0].generate(x: (size.width - length! * 3)/2 + length!, y: y)
        case .O:
            length = (size.height - y * 2) / 2
            blocs[0].generate(x: (size.width - length! * 2)/2, y: y)
        case .I:
            length = (size.height - y * 2) / 4
            blocs[0].generate(x: (size.width - length!)/2, y: y)
        case .S:
            length = (size.height - y * 2) / 3
            blocs[0].generate(x: (size.width - length! * 2)/2, y: y)
        case .Z:
            length = (size.height - y * 2) / 3
            blocs[0].generate(x: (size.width - length! * 2)/2 + length!, y: y)
        }
        for i in 1...3 {
            blocs[i].generate(bloc: blocs[i-1], diff: coef[shape.rawValue][i-1], length: length!)
        }
    }
}
