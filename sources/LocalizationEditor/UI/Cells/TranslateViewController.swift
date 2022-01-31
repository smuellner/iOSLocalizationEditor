//
//  TranslateViewController.swift
//  LocalizationEditor
//
//  Created by Sascha Müllner on 26.01.22.
//  Copyright © 2022 Igor Kulman. All rights reserved.
//

import Cocoa

protocol TranslateViewControllerDelegate: AnyObject {
    func userDidUpdateLocalizationString(language: String, key: String, with value: String, message: String?)
    func close()
}

public class TranslateViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var textView: NSTextView!

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
    }

    weak var delegate: TranslateViewControllerDelegate?

    var language: String?

    var value: LocalizationString?

    func set(language: String?, value: LocalizationString?, delegate: TranslateViewControllerDelegate?) {
        self.language = language
        self.value = value
        self.delegate = delegate
        translate()
    }

    private func translate() {
        guard let language = language else {
            return
        }
        guard let value = value else {
            return
        }
        let text = value.key
        progressIndicator.startAnimation(self)
        Deepl.shared.localize(text: text, language: language) { [weak self] translations in
            guard let self = self else {
                return
            }
            self.progressIndicator.stopAnimation(self)
            self.add(title: value.key)
            self.add(subTitle: value.message)
            self.addNewline()
            for translation in translations {
                self.add(link: translation.text)
            }
            self.addNewline()
        } failed: { [weak self] error in
            guard let self = self else {
                return
            }
            self.progressIndicator.stopAnimation(self)
            self.add(title: value.key)
            self.add(subTitle: error.localizedDescription)
        }
    }

    public func add(title: String?) {
        guard let title = title else {
            return
        }
        let font = NSFont.systemFont(ofSize: 23)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        add(attributedString: attributedString)
    }

    public func add(subTitle: String?) {
        guard let subTitle = subTitle else {
            return
        }
        let font = NSFont.systemFont(ofSize: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.gray,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: subTitle, attributes: attributes)
        add(attributedString: attributedString)
    }

    public func addNewline() {
        add(attributedString: NSAttributedString(string: "\n"))
    }

    public func add(link: String) {
        let font = NSFont.systemFont(ofSize: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSMutableAttributedString(string: "\t\(link)", attributes: attributes)
        if let range = attributedString.string.range(of: link) {
            let nsRange = NSRange(range, in: link)
            attributedString.addAttribute(.link, value: link, range: nsRange)
            add(attributedString: attributedString)
        }
    }

    public func add(attributedString: NSAttributedString) {
        let combination = NSMutableAttributedString()
        combination.append(self.textView.attributedString())
        combination.append(NSAttributedString(string: "\n"))
        combination.append(attributedString)
        self.textView.textStorage?.setAttributedString(combination)
    }

    public func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        guard let text = link as? String else {
            return false
        }
        guard let language = self.language else {
            return false
        }
        guard let value = self.value else {
            return false
        }
        self.delegate?.userDidUpdateLocalizationString(
            language: language,
            key: value.key,
            with: text,
            message: value.message)
        return true
    }

    @IBAction private func closeButtonTapped(_ sender: NSButton) {
        self.delegate?.close()
    }
}
