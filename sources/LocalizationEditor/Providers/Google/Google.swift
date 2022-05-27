import Foundation

class Google {

    static var shared = Google()

    private init() {
    }

    func website(text: String,
                 targetLanguage: String,
                 sourceLanguage: String = "") -> URL? {
        guard let website = URL(string: "https://translate.google.com/?sl=\(sourceLanguage)&tl=\(targetLanguage)&text=\(text)&op=translate") else {
            return nil
        }
        return website
    }
}
