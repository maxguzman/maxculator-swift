//  Created by Max Guzman on 4/22/16.
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change status bar to light when dark background
        // first add this to info.plist: View controller-based status bar appearance = NO
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // revert status bar to default
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    @IBOutlet fileprivate weak var display: UILabel!
    @IBOutlet fileprivate weak var subScreen: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit == "." {
                if textCurrentlyInDisplay.range(of: ".") == nil {
                    display.text = textCurrentlyInDisplay + digit
                }
            } else {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        subScreen.text = brain.description
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain.resetCalculator()
        displayValue = 0.0
        userIsInTheMiddleOfTyping = false
        subScreen.text = " "
    }
}
