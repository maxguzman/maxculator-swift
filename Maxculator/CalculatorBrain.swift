//
//  CalculatorBrain.swift
//  Maxculator
//
//  Created by Max Guzman on 5/3/16.
//  Copyright © 2016 Robot Dream. All rights reserved.
//

import Foundation

func factorial(_ number: Double) -> Double {
    if (number <= 1) {
        return 1
    }
    return number * factorial(number - 1)
}

class CalculatorBrain {
    
    fileprivate var accumulator = 0.0
    fileprivate var internalProgram = [AnyObject]()
    
    var description = ""
    var isPartialResult = false
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func resetCalculator() {
        accumulator = 0.0
        pending = nil
        description = ""
        isPartialResult = false
        internalProgram.removeAll()
    }
    
    fileprivate var operations: Dictionary<String,Operation> =  [
        "π" : Operation.constant(.pi),
        "e" : Operation.constant(M_E),
        "rand" : Operation.constant(Double(arc4random())),
        "%" : Operation.unaryOperation({ $0 / 100 }),
        "+/−" : Operation.unaryOperation({ -$0 }),
        "1/x" : Operation.unaryOperation({ 1/$0 }),
        "x!" : Operation.unaryOperation({ factorial($0) }),
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "log" :Operation.unaryOperation(log),
        "×" : Operation.binaryOperation( * ),
        "÷" : Operation.binaryOperation({ $0 != 0.0 ? $0 / $1 : $0 }),
        "+" : Operation.binaryOperation( + ),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "xʸ" : Operation.binaryOperation({ pow($0, $1) }),
        "=" : Operation.equals
    ]

    fileprivate enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                accumulator = function(accumulator)
            case .binaryOperation(let function):
                if isPartialResult {description.remove(at: description.characters.index(before: description.endIndex))} else { description = "" }
                description += String(accumulator) + " " + symbol + " …"
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                isPartialResult = true
            case .equals:
                if isPartialResult {
                    description.remove(at: description.characters.index(before: description.endIndex))
                    description += String(accumulator) + " " + symbol
                    executePendingBinaryOperation()
                    isPartialResult = false
                }
                print(internalProgram)
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            resetCalculator()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    
}
