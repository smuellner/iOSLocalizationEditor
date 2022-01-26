import Foundation

class Deepl {

    static var shared = Deepl()

    private init() {
    }

    var authKey: String?
    var isSupported: Bool {
        authKey?.isEmpty == false
    }

    func localize(text: String, language: String, _ completion: @escaping (String) -> Void) {
        guard var components = URLComponents(string: "https://api-free.deepl.com/v2/translate") else {
            return
        }

        let queryItemApiKey = URLQueryItem(name: "auth_key", value: authKey)
        let queryItemText = URLQueryItem(name: "text", value: text)
        let queryItemLanguage = URLQueryItem(name: "target_lang", value: language)
        components.queryItems = [queryItemApiKey, queryItemText, queryItemLanguage]

        guard let url = components.url else {
            return
        }

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url) { data, response, error in
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                return
            }
            guard let data = data, error == nil else {
                debugPrint("Could not load \(url)", String(describing: error))
                return
            }
            if let translated = try? JSONDecoder().decode(Translated.self, from: data),
               let translation = translated.translations.first?.text {
                DispatchQueue.main.async {
                    completion(translation)
                }
            } else {
                debugPrint("Invalid Response: \(String(describing: data))")
            }
        }

        task.resume()
    }

    struct Translated: Codable {
        let translations: [Translation]
    }

    struct Translation: Codable {
        let detectedSourceLanguage: String
        let text: String

        enum CodingKeys: String, CodingKey {
            case detectedSourceLanguage = "detected_source_language"
            case text
        }
    }
}
