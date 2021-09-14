//
//  iPhoneNumberField.swift
//  iPhoneNumberField
//
//  Created by Seyed Mojtaba Hosseini Zeidabadi on 10/23/20.
//  Copyright © 2020 Chenzook. All rights reserved.
//
//  StackOverflow: https://stackoverflow.com/story/mojtabahosseini
//  Linkedin: https://linkedin.com/in/MojtabaHosseini
//  GitHub: https://github.com/MojtabaHs
//

import SwiftUI
import PhoneNumberKit

/// A text field view representable structure that formats the user's phone number as they type.
public struct iPhoneNumberField: UIViewRepresentable {
    
    /// The formatted phone number `String`.
    /// This variable writes to the binding provided in the initializer.
    @Binding public var text: String
    @State private var displayedText: String

    /// The maximum number of digits the phone number field allows. 🔢
    internal var maxDigits: Int?

    /// The font of the phone number field. 🔡
    internal var font: UIFont?

    /// The phone number field's "clear button" mode. 🚫
    internal var clearButtonMode: UITextField.ViewMode = .never

    /// The text displayed in the phone number field when no number has been typed yet.
    /// Setting this `nil` will display a default phone number as the placeholder.
    private let placeholder: String?

    /// Whether the country flag should be displayed in the phone number field. 🇦🇶
    internal var showFlag: Bool = false

    /// Whether tapping the flag should show a sheet containing all of the country flags. 🏴‍☠️
    internal var selectableFlag: Bool = false

    /// Whether the country code should be automatically filled for the end user. ➕
    internal var autofillPrefix: Bool = false

    /// Whether the country code should be automatically displayed for the end user. 🎓
    internal var previewPrefix: Bool = false

    /// Change the default prefix number by setting the region. 🇮🇷
    internal var defaultRegion: String?

    /// The color of the text of the phone number field. 🎨
    internal var textColor: UIColor?
    
    /// The color of the phone number field's cursor and highlighting. 🖍
    internal var accentColor: UIColor?

    /// The color of the number (excluding country code) portion of the placeholder.
    internal var numberPlaceholderColor: UIColor?

    /// The color of the country code portion of the placeholder color.
    internal var countryCodePlaceholderColor: UIColor?

    /// The visual style of the phone number field. 🎀
    /// For now, this uses `UITextField.BorderStyle`. Updates on this modifier to come.
    internal var borderStyle: UITextField.BorderStyle = .none
    
    /// Whether or not the `text` property will be formatted.
    ///
    /// When set to `false`, the binding is set to an empty string until a valid number is detected.
    /// When set to `true`, the binding displays exactly what is in the text field.
    internal var formatted: Bool = true

    /// An action to perform when editing on the phone number field begins. ▶️
    /// The closure requires a `PhoneNumberTextField` parameter, which is the underlying `UIView`, that you can change each time this is called, if desired.
    internal var onBeginEditingHandler = { (view: PhoneNumberTextField) in }

    /// An action to perform when any characters in the phone number field are changed. 💬
    /// The closure requires a `PhoneNumberTextField` parameter, which is the underlying `UIView`, that you can change each time this is called, if desired.
    internal var onEditingChangeHandler = { (view: PhoneNumberTextField) in }

    /// An action to perform when any characters in the phone number field are changed. ☎️
    /// The closure requires a `PhoneNumber` parameter, that you can change each time this is called, if desired.
    internal var onPhoneNumberChangeHandler = { (phoneNumber: PhoneNumber?) in }

    /// An action to perform when editing on the phone number field ends. ⏹
    /// The closure requires a `PhoneNumberTextField` parameter, which is the underlying `UIView`, that you can change each time this is called, if desired.
    internal var onEndEditingHandler = { (view: PhoneNumberTextField) in }
    
    /// An action to perform when the phone number field is cleared. ❌
    /// The closure requires a `PhoneNumberTextField` parameter, which is the underlying `UIView`, that you can change each time this is called, if desired.
    internal var onClearHandler = { (view: PhoneNumberTextField) in }
    
    /// An action to perform when the return key on the phone number field is pressed. ↪️
    /// The closure requires a `PhoneNumberTextField` parameter, which is the underlying `UIView`, that you can change each time this is called, if desired.
    internal var onReturnHandler = { (view: PhoneNumberTextField) in }

    /// A closure that requires a `PhoneNumberTextField` object to be configured in the body. ⚙️
    public var configuration = { (view: PhoneNumberTextField) in }
    
    @Environment(\.layoutDirection) internal var layoutDirection: LayoutDirection
    /// The horizontal alignment of the phone number field.
    internal var textAlignment: NSTextAlignment?
    
    /// Whether the phone number field clears when editing begins. 🎬
    internal var clearsOnBeginEditing = false
    
    /// Whether the phone number field clears when text is inserted. 👆
    internal var clearsOnInsertion = false
    
    /// Whether the phone number field is enabled for interaction. ✅
    internal var isUserInteractionEnabled = true

    public init(_ title: String? = nil,
                text: Binding<String>,
                formatted: Bool = true,
                configuration: @escaping (UIViewType) -> () = { _ in } ) {

        self.placeholder = title
        self.formatted = formatted
        self._text = text
        self._displayedText = State(initialValue: text.wrappedValue)
        self.configuration = configuration
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> PhoneNumberTextField {
        let uiView = UIViewType()
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.addTarget(context.coordinator,
                         action: #selector(Coordinator.textViewDidChange),
                         for: .editingChanged)
        uiView.delegate = context.coordinator

		NotificationCenter.default.addObserver(
			context.coordinator,
			selector: #selector(context.coordinator.textDidChangeNotification),
			name: UITextField.textDidChangeNotification,
			object: uiView
		)

        uiView.withExamplePlaceholder = placeholder == nil
		uiView.textContentType = .telephoneNumber
		
        if let defaultRegion = defaultRegion {
            uiView.partialFormatter.defaultRegion = defaultRegion
        }
        
        return uiView
    }

    public func updateUIView(_ uiView: PhoneNumberTextField, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)

        uiView.text = displayedText
        uiView.font = font
        uiView.maxDigits = maxDigits
        uiView.clearButtonMode = clearButtonMode
        uiView.placeholder = placeholder
        uiView.borderStyle = borderStyle
        uiView.textColor = textColor
        uiView.withFlag = showFlag
        uiView.withDefaultPickerUI = selectableFlag
        uiView.withPrefix = previewPrefix
        uiView.withExamplePlaceholder = autofillPrefix || (placeholder != nil)
        // if autofillPrefix { uiView.resignFirstResponder() } // Workaround touch autofill issue
        uiView.tintColor = accentColor
        
        if let defaultRegion = defaultRegion {
            uiView.partialFormatter.defaultRegion = defaultRegion
        }
        if let numberPlaceholderColor = numberPlaceholderColor {
            uiView.numberPlaceholderColor = numberPlaceholderColor
        }
        if let countryCodePlaceholderColor = countryCodePlaceholderColor {
            uiView.countryCodePlaceholderColor = countryCodePlaceholderColor
        }
        if let textAlignment = textAlignment {
            uiView.textAlignment = textAlignment
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
			displayedText: $displayedText,
			formatted: formatted,
			onBeginEditing: onBeginEditingHandler,
			onEditingChange: onEditingChangeHandler,
			onPhoneNumberChange: onPhoneNumberChangeHandler,
			onEndEditing: onEndEditingHandler,
			onClear: onClearHandler,
			onReturn: onReturnHandler
		)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        internal init(
            text: Binding<String>,
            displayedText: Binding<String>,
            formatted: Bool,
            onBeginEditing: @escaping (PhoneNumberTextField) -> () = { (view: PhoneNumberTextField) in },
            onEditingChange: @escaping (PhoneNumberTextField) -> () = { (view: PhoneNumberTextField) in },
            onPhoneNumberChange: @escaping (PhoneNumber?) -> () = { (view: PhoneNumber?) in },
            onEndEditing: @escaping (PhoneNumberTextField) -> () = { (view: PhoneNumberTextField) in },
            onClear: @escaping (PhoneNumberTextField) -> () = { (view: PhoneNumberTextField) in },
            onReturn: @escaping (PhoneNumberTextField) -> () = { (view: PhoneNumberTextField) in } )
        {
            self.text = text
            self.displayedText = displayedText
            self.formatted = formatted
            self.onBeginEditing = onBeginEditing
            self.onEditingChange = onEditingChange
            self.onPhoneNumberChange = onPhoneNumberChange
            self.onEndEditing = onEndEditing
            self.onClear = onClear
            self.onReturn = onReturn
        }

        var text: Binding<String>
        var displayedText: Binding<String>
        var formatted: Bool

        var onBeginEditing = { (view: PhoneNumberTextField) in }
        var onEditingChange = { (view: PhoneNumberTextField) in }
        var onPhoneNumberChange = { (phoneNumber: PhoneNumber?) in }
        var onEndEditing = { (view: PhoneNumberTextField) in }
        var onClear = { (view: PhoneNumberTextField) in }
        var onReturn = { (view: PhoneNumberTextField) in }

		// listen for changes from country selector
		@objc func textDidChangeNotification(notification: Notification) {
			guard
				let textField = notification.object as? PhoneNumberTextField,
				displayedText.wrappedValue != textField.text
			else { return }

			DispatchQueue.main.async {
				self.textViewDidChange(textField)
			}
		}

        @objc public func textViewDidChange(_ textField: UITextField) {
            guard let textField = textField as? PhoneNumberTextField else {
                return assertionFailure("Undefined state")
            }
            
            // Updating the binding
            if formatted {
                // Display the text exactly if unformatted
                text.wrappedValue = textField.text ?? ""
            } else {
                if let number = textField.phoneNumber {
                    // If we have a valid number, update the binding
                    let country = String(number.countryCode)
                    let nationalNumber = String(number.nationalNumber)
                    text.wrappedValue = "+" + country + nationalNumber
                } else {
                    // Otherwise, maintain an empty string
                    text.wrappedValue = ""
                }
            }
            
            displayedText.wrappedValue = textField.text ?? ""
            onEditingChange(textField)
            onPhoneNumberChange(textField.phoneNumber)
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            onBeginEditing(textField as! PhoneNumberTextField)
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            onEndEditing(textField as! PhoneNumberTextField)
        }
        
        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            displayedText.wrappedValue = ""
            onClear(textField as! PhoneNumberTextField)
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onReturn(textField as! PhoneNumberTextField)
            return true
        }
    }
}
