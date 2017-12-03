//
//  Bloc.swift
//  Happy Tetris
//
//  Created by SHENGXinheng on 31/10/2017.
//  Copyright © 2017 SHENGXinheng. All rights reserved.
//

import UIKit

// ************** Default shapes **********************************
//                                          _
//    _         _                          |_|     _           _
//   |_|       |_|       _        ___      |_|    |_|_       _|_|
//   |_|_     _|_|     _|_|_     |_|_|     |_|    |_|_|     |_|_|
//   |_|_|   |_|_|    |_|_|_|    |_|_|     |_|      |_|     |_|
//
// ****************************************************************

// Index
//                                          0
//    0         0                           1     0            0
//    1         1        0        0 1       2     1 2        2 1
//    2 3     3 2      1 2 3      3 2       3       3        3

enum SHAPE : Int {
    case L = 0, J, T, O, I, S, Z
}


// ****** Bloc ********
//
//    coor.____
//        |    |
//        |____|
//        length
//
// ********************
class Bloc {
    var coor: CGPoint
    let nb_col: Int
    let length: CGFloat
    let color: UIColor
    
    init(index: Int, nb_col: Int, length: CGFloat, color: UIColor) {
        self.nb_col = nb_col
        self.length = length
        coor = CGPoint()
        self.color = color
        refresh(index: index)
    }
    
    func refresh(index: Int) {
        let col = index % nb_col;
        let row = index / nb_col;
        coor = CGPoint(x: CGFloat(col) * length, y: CGFloat(row) * length)
    }
}

// Clockwise rotation
class Rotation {
    var centerIndex: Int = -1
    var map: [Int: Int]
    let nb_col: Int
    
    init(nb_col: Int) {
        self.nb_col = nb_col
        map = [:]
        map[-nb_col*2] = 2
        map[-2] = -nb_col*2
        map[2] = nb_col*2
        map[nb_col*2] = -2
        map[-nb_col-1] = -nb_col+1
        map[-nb_col] = 1
        map[-nb_col+1] = nb_col+1
        map[1] = nb_col
        map[nb_col+1] = nb_col-1
        map[nb_col] = -1
        map[nb_col-1] = -nb_col-1
        map[-1] = -nb_col
    }
    
    func setCenter(index: Int) {
        centerIndex = index
    }
    
    func leftShift() {
        if centerIndex >= 0 {
            centerIndex -= 1
        }
    }
    
    func rightShift() {
        if centerIndex >= 0 {
            centerIndex += 1
        }
    }
    
    func downShift() {
        if centerIndex >= 0 {
            centerIndex += nb_col
        }
    }
    
    func upShift() {
        if centerIndex >= nb_col {
            centerIndex -= nb_col
        }
    }
    
    func rotate(index: Int) -> Int{
        if centerIndex < 0 {
            return index
        }
        if let diff = map[index - centerIndex] {
            return centerIndex + diff
        }
        return index
    }
}

class Shape: UIView{
    let blocLength: CGFloat
    let nb_col: Int
    let nb_row: Int
    
    var shape: SHAPE
    var color: UIColor
    var indices: [Int]
    var rotation: Rotation
    var blocs: [Bloc]
    var half: CGFloat
    var path: UIBezierPath
    var show: Bool
    
    init(shape: SHAPE, color: UIColor, length: CGFloat, board: UIView) {
        self.shape = shape
        self.color = color
        blocLength = length
        self.nb_col = Int(board.bounds.size.width/blocLength)
        self.nb_row = Int(board.bounds.size.height/blocLength)
        half = 0
        show = true
        rotation = Rotation(nb_col: nb_col)
        indices = [Int]()
        blocs = [Bloc]()
        path = UIBezierPath()
        super.init(frame: CGRect(x: 0, y: 0, width: board.bounds.size.width, height: board.bounds.size.height))
        self.backgroundColor = UIColor.clear
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset(shape: SHAPE, color: UIColor) {
        self.shape = shape
        self.color = color
        half = 0
        show = true
        initialize()
    }
    
    private func initialize() {
        let topIndex = nb_col / 2
        switch shape {
        case .L:
            indices = [topIndex - 1, topIndex - 1 + nb_col, topIndex - 1 + nb_col * 2, topIndex + nb_col * 2];
            rotation.setCenter(index: indices[1])
        case .J:
            indices = [topIndex, topIndex + nb_col, topIndex + nb_col * 2, topIndex + nb_col * 2 - 1];
            rotation.setCenter(index: indices[1])
        case .T:
            indices = [topIndex, topIndex - 1 + nb_col, topIndex + nb_col, topIndex + nb_col + 1];
            rotation.setCenter(index: indices[0])
        case .O:
            indices = [topIndex - 1, topIndex, topIndex + nb_col, topIndex + nb_col - 1];
        case .I:
            indices = [topIndex, topIndex + nb_col, topIndex + nb_col * 2, topIndex + nb_col * 3];
            rotation.setCenter(index: indices[1])
        case .S:
            indices = [topIndex, topIndex + nb_col, topIndex + nb_col + 1, topIndex + nb_col * 2 + 1];
            rotation.setCenter(index: indices[1])
        case .Z:
            indices = [topIndex, topIndex + nb_col, topIndex + nb_col - 1, topIndex + nb_col * 2 - 1];
            rotation.setCenter(index: indices[1])
        }
        blocs = [Bloc(index: indices[0], nb_col: nb_col, length: blocLength, color: color),
                Bloc(index: indices[1], nb_col: nb_col, length: blocLength, color: color),
                Bloc(index: indices[2], nb_col: nb_col, length: blocLength, color: color),
                Bloc(index: indices[3], nb_col: nb_col, length: blocLength, color: color)]
    }
    
    private func refreshBlocs() {
        for i in 0...3 {
            blocs[i].refresh(index: indices[i])
        }
    }
    
    func leftTanslate(blank: [Bool]){
        var success = true
        for i in 0...3 {
            indices[i] -= 1
            if (indices[i] + 1) % nb_col == 0 || !blank[indices[i]] {
                success = false
            }
        }
        if !success {
            for i in 0...3{
                indices[i] += 1
            }
            return
        }
        rotation.leftShift()
        refreshBlocs()
    }
    
    func rightTanslate(blank: [Bool]){
        var success = true
        for i in 0...3 {
            indices[i] += 1
            if indices[i] % nb_col == 0 || !blank[indices[i]] {
                success = false
            }
        }
        if !success {
            for i in 0...3{
                indices[i] -= 1
            }
            return
        }
        rotation.rightShift()
        refreshBlocs()
    }
    
    func stepDown(blank: [Bool]) -> Bool{
        if half == 0 {
            var success = true
            for i in 0...3 {
                indices[i] += nb_col
                if indices[i] >= nb_row * nb_col || !blank[indices[i]] {
                    success = false
                }
            }
            if !success {
                show = false
                for i in 0...3 {
                    indices[i] -= nb_col
                }
                return success
            }
            half = blocLength / 2
            rotation.downShift()
            refreshBlocs()
        } else {
            half = 0
        }
        return true
    }
    
    func rotate(blank: [Bool]) {
        if shape == .O {
            return
        }
        var tempIndices = Array(repeating: 0, count: 4)
        var success = true
        var left = 0
        var right = 0
        for i in 0...3 {
            tempIndices[i] = rotation.rotate(index: indices[i])
            if nb_col - (tempIndices[i] % nb_col) <= 2 && rotation.centerIndex % nb_col < 2 {
                right = nb_col - (tempIndices[i] % nb_col)
            } else if nb_col - (rotation.centerIndex % nb_col) <= 2 && tempIndices[i] % nb_col < 2 {
                left = tempIndices[i] % nb_col + 1
            }
        }
        if left > 0 {
            for i in 0...3 {
                tempIndices[i] -= left
                if !blank[tempIndices[i]]{
                    success = false
                }
            }
            if success {
                for i in 0...3 {
                    indices[i] = tempIndices[i]
                }
                rotation.leftShift()
                if left == 2 {
                    rotation.leftShift()
                }
                refreshBlocs()
            }
        } else if right > 0 {
            for i in 0...3 {
                tempIndices[i] += right
                if !blank[tempIndices[i]]{
                    success = false
                }
            }
            if success {
                for i in 0...3 {
                    indices[i] = tempIndices[i]
                }
                rotation.rightShift()
                if right == 2 {
                    rotation.rightShift()
                }
                refreshBlocs()
            }
        } else {
            var up = 0
            var down = 0
            for i in 0...3 {
                if !blank[tempIndices[i]]{
                    success = false
                    if tempIndices[i] % nb_col < indices[i] % nb_col {
                        right += 1
                    } else if tempIndices[i] % nb_col > indices[i] % nb_col {
                        left += 1
                    }
                    if tempIndices[i] / nb_col < indices[i] / nb_col {
                        down += 1
                    } else if tempIndices[i] / nb_col > indices[i] / nb_col {
                        up += 1
                    }
                }
            }
            if !success {
                success = true
                if right > left {
                    for i in 0...3 {
                        if (tempIndices[i] + 1) % nb_col == 0 || !blank[tempIndices[i] + 1]{
                            success = false
                        }
                    }
                    if success {
                        for i in 0...3 {
                            indices[i] = tempIndices[i] + 1
                        }
                        rotation.rightShift()
                        refreshBlocs()
                        return
                    }
                } else if left > right{
                    for i in 0...3 {
                        if tempIndices[i] % nb_col == 0 || !blank[tempIndices[i] - 1]{
                            success = false
                        }
                    }
                    if success {
                        for i in 0...3 {
                            indices[i] = tempIndices[i] - 1
                        }
                        rotation.leftShift()
                        refreshBlocs()
                        return
                    }
                }
                success = true
                if up > down {
                    for i in 0...3 {
                        if tempIndices[i] / nb_col == 0 || !blank[tempIndices[i] - nb_col]{
                            success = false
                        }
                    }
                    if success {
                        for i in 0...3 {
                            indices[i] = tempIndices[i] - nb_col
                        }
                        rotation.upShift()
                        refreshBlocs()
                        return
                    }
                } else if down > up {
                    for i in 0...3 {
                        if tempIndices[i] / nb_col == nb_row - 1 || !blank[tempIndices[i] + nb_col]{
                            success = false
                        }
                    }
                    if success {
                        for i in 0...3 {
                            indices[i] = tempIndices[i] + nb_col
                        }
                        rotation.downShift()
                        refreshBlocs()
                        return
                    }
                }
            } else {
                for i in 0...3 {
                    indices[i] = tempIndices[i]
                }
                refreshBlocs()
            }
        }
    }
    
    private func draw() {
        var rect: CGRect
        for i in 0...3 {
            rect = CGRect(x: blocs[i].coor.x, y: blocs[i].coor.y - half, width: blocLength, height: blocLength)
            path.append(UIBezierPath(rect: rect))
        }
        color.setFill()
        path.fill(with: CGBlendMode.normal, alpha: 1)
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).setStroke()
        path.stroke(with: CGBlendMode.normal, alpha: 1)
    }
    
    private func erase() {
        path.fill(with: CGBlendMode.clear, alpha: 1)
        path.stroke(with: CGBlendMode.clear, alpha: 1)
        path.removeAllPoints()
    }
    
    override func draw(_ rect: CGRect) {
        erase()
        if show {
            draw()
        }
    }
}
