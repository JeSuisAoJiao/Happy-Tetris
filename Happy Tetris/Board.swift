//
//  Board.swift
//  Happy Tetris
//
//  Created by SHENGXinheng on 02/11/2017.
//  Copyright © 2017 SHENGXinheng. All rights reserved.
//

import UIKit

class Board: UIView {
    var paths = [UIBezierPath]()
    var colors = [UIColor]()
    var nb_col: Int?
    var nb_row: Int?
    var top: Int?
    var blocLength: CGFloat?
    
    func initialzePath(blocLength: CGFloat) {
        self.blocLength = blocLength
        nb_col = Int(self.bounds.size.width / blocLength)
        nb_row = Int(self.bounds.size.height / blocLength)
        for _ in 0..<nb_row! * nb_col! {
            paths.append(UIBezierPath())
            colors.append(UIColor.clear)
        }
        top = nb_row
    }
    
    func reset() {
        paths.removeAll()
        colors.removeAll()
        self.setNeedsDisplay()
        for _ in 0..<nb_row! * nb_col! {
            paths.append(UIBezierPath())
            colors.append(UIColor.clear)
        }
        top = nb_row
    }
    
    func addBloc(bloc: Bloc, index: Int) {
        if top! > index / nb_col! {
            top = index / nb_col!
        }
        /*if !(paths![index].isEmpty) {
            paths![index].removeAllPoints()
        }*/
        paths[index] = UIBezierPath(rect: CGRect(x: bloc.coor.x, y: bloc.coor.y, width: bloc.length, height: bloc.length))
        colors[index] = bloc.color
    }
    
    func checkRows(blank: inout [Bool], score: inout Int){
        usleep(500000)
        var n: Int
        var blankRows: [Int] = [Int]()
        for r in (top!...(nb_row! - 1)).reversed() {
            n = 0
            for c in 0..<nb_col! {
                if colors[r * nb_col! + c] == UIColor.clear{
                    break
                } else{
                    n += 1
                }
            }
            if n == nb_col {
                blankRows.append(r)
                for c in 0..<nb_col! {
                    blank[r * nb_col! + c] = true
                    colors[r * nb_col! + c] = UIColor.clear
                }
            }
        }
        if !blankRows.isEmpty {
            let count = blankRows.count
            score += (count * 50)
            var i = 0
            var rowToReplace = blankRows[i]
            var rowToMove = rowToReplace - 1
            while rowToMove >= top! {
                if i + 1 < count {
                    if rowToMove == blankRows[i+1] {
                        rowToMove -= 1
                        i += 1
                        continue
                    }
                }
                for j in 0..<nb_col!{
                    
                    paths[rowToReplace * nb_col! + j] = UIBezierPath(cgPath: paths[rowToMove * nb_col! + j].cgPath)
                    if !paths[rowToReplace * nb_col! + j].isEmpty {
                        paths[rowToReplace * nb_col! + j].apply(CGAffineTransform(translationX: 0, y: CGFloat(rowToReplace - rowToMove) * blocLength!))
                    }
                    colors[rowToReplace * nb_col! + j] = colors[rowToMove * nb_col! + j]
                    colors[rowToMove * nb_col! + j] = UIColor.clear
                    blank[rowToReplace * nb_col! + j] = blank[rowToMove * nb_col! + j]
                    blank[rowToMove * nb_col! + j] = true
                }
                rowToReplace -= 1
                rowToMove -= 1
            }
            top = rowToReplace + 1
            DispatchQueue.main.async{
                self.setNeedsDisplay()
            }
        }
        /*DispatchQueue.main.async {
            self.setNeedsDisplay()
        }*/
    }
    
    override func draw(_ rect: CGRect) {
        //print("draw")
        if paths.isEmpty{
            super.draw(rect)
        } else {
            backgroundColor?.setStroke()
            for i in 0..<nb_row! * nb_col! {
                if !(paths[i].isEmpty) {
                    colors[i].setFill()
                    paths[i].fill(with: CGBlendMode.normal, alpha: 1)
                    paths[i].stroke(with: CGBlendMode.normal, alpha: 1)
                }
            }
        }
    }
}
