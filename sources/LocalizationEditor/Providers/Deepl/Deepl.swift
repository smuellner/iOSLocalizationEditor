import Foundation

class Deepl {

    static var shared = Deepl()

    private init() {
    }

    var authKey: String?
    var isSupported: Bool {
        authKey?.isEmpty == false
    }

    func localize(text: String, targetLanguage: String, _ completion: @escaping ([Translation]) -> Void, failed: @escaping (Error) -> Void) {
        localize(text: text, targetLanguage: targetLanguage, sourceLanguage: nil, completion, failed: failed)
    }

    func localize(text: String,
                  targetLanguage: String,
                  sourceLanguage: String?,
                  _ completion: @escaping ([Translation]) -> Void,
                  failed: @escaping (Error) -> Void) {
        guard var components = URLComponents(string: "https://api-free.deepl.com/v2/translate") else {
            failed(TranslationError.invalidRequest)
            return
        }

        let queryItemApiKey = URLQueryItem(name: "auth_key", value: authKey)
        let queryItemText = URLQueryItem(name: "text", value: text)
        let queryItemTargetLanguage = URLQueryItem(name: "target_lang", value: targetLanguage)
        if let sourceLanguage = sourceLanguage {
            let queryItemSourceLanguage = URLQueryItem(name: "source_lang", value: sourceLanguage)
            components.queryItems = [
                queryItemApiKey,
                queryItemText,
                queryItemSourceLanguage,
                queryItemTargetLanguage
            ]
        } else {
            components.queryItems = [
                queryItemApiKey,
                queryItemText,
                queryItemTargetLanguage
            ]
        }

        guard let url = components.url else {
            failed(TranslationError.invalidRequest)
            return
        }

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url) { data, response, error in
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                DispatchQueue.main.async { failed(TranslationError.statusCode(code: status)) }
                return
            }
            guard let data = data, error == nil else {
                debugPrint("Could not load \(url)", String(describing: error))
                DispatchQueue.main.async { failed(TranslationError.error(error: error)) }
                return
            }
            if let translated = try? JSONDecoder().decode(Translated.self, from: data) {
                let translations = translated.translations
                DispatchQueue.main.async { completion(translations) }
            } else {
                debugPrint("Invalid Response: \(String(describing: data))")
                DispatchQueue.main.async { failed(TranslationError.invalidResponse) }
            }
        }

        task.resume()
    }

    enum TranslationError: Error {
        case invalidRequest
        case error(error: Error?)
        case statusCode(code: Int)
        case invalidResponse
    }
}
