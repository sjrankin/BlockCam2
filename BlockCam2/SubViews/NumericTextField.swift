//
//  NumericTextField.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/4/21.
//

import Foundation
import SwiftUI

//https://www.dabblingbadger.com/blog/2021/4/6/tips-and-tricks-for-making-the-most-of-textfield-in-swiftui
struct NumericTextField<T>: UIViewRepresentable
{
    private var Title: String
    @Binding var Value: T
    private var Formatter: NumberFormatter
    @State var ErrorMessage = ""
    private var KeyboardType: UIKeyboardType
    
    init(Title: String = "", Value: Binding<T>,
         Formatter: NumberFormatter, KeyboardType: UIKeyboardType)
    {
        self.Title = Title
        self._Value = Value
        self.Formatter = Formatter
        self.KeyboardType = KeyboardType
    }
    
    class Coordinator: NSObject, UITextFieldDelegate
    {
        @Binding var value: T
        var formatter: NumberFormatter
        @Binding var errorMessage: String
        
        init(value: Binding<T>, formatter: NumberFormatter, errorMessage: Binding<String>)
        {
            self._value = value
            self.formatter = formatter
            self._errorMessage = errorMessage
        }
        
        func textFor<T>(value: T) -> String?
        {
            return formatter.string(for: value)
        }
        
        func scrubbedText(currentText: String) -> String
        {
            switch formatter.numberStyle
            {
                case .currency:
                    if let prefix = formatter.currencySymbol,
                       !currentText.contains(prefix),
                       !currentText.isEmpty
                    {
                        return prefix + currentText
                    }
                case .percent: ()
                    if !currentText.contains("%")
                    {
                        return currentText + "%"
                    }
                default:
                    ()
            }
            return currentText
        }
        
        func showAlert(errorMessage: String, view: UIView)
        {
            let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
            if let parentController = view.parentViewController
            {
                parentController.present(alert, animated: true)
            }
        }
        
        //MARK: UITextFieldDelegate methods
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField)
        {
            guard let currentText = textField.text else
            {
                return
            }
            let string = scrubbedText(currentText: currentText)
            
            var valueContainer: AnyObject?
            var errorContainer: NSString?
            formatter.getObjectValue(&valueContainer, for: string, errorDescription: &errorContainer)
            
            if let errorString = errorContainer as String?
            {
                if let stringVal = formatter.string(for: value)
                {
                    textField.text = stringVal
                }
                else
                {
                    textField.text = nil
                }
                showAlert(errorMessage: errorString, view: textField as UIView)
                return
            }
            
            if let newValue = valueContainer as? T,
               errorContainer == nil
            {
                self.value = newValue
            }
        }
    }
    
    func makeUIView(context: Context) -> UITextField
    {
        let Field = UITextField()
        Field.delegate = context.coordinator
        if !Title.isEmpty
        {
            Field.placeholder = Title
        }
        Field.setContentHuggingPriority(.defaultHigh, for: .vertical)
        Field.keyboardType = KeyboardType
        Field.borderStyle = .roundedRect
        return Field
    }
    
    func makeCoordinator() -> Coordinator
    {
        return Coordinator(value: $Value, formatter: Formatter, errorMessage: $ErrorMessage)
    }
    
    func updateUIView(_ uiView: UITextField, context: Context)
    {
        uiView.text = context.coordinator.textFor(value: Value)
    }
}

//https://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller
extension UIView
{
    var parentViewController: UIViewController?
    {
        var parentResponder: UIResponder? = self
        while parentResponder != nil
        {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController
            {
                return viewController
            }
        }
        return nil
    }
}
