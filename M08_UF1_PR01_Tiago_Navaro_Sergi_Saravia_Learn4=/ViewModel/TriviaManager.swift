import Foundation

class TriviaManager: ObservableObject {
    @Published var trivies: [Trivia] = []  // Array per desar totes les preguntes
    @Published var errorMessage: String?

    private let apiURL = "https://the-trivia-api.com/v2/questions"

    // Funció per carregar les dades des de l'API
    func fetchTrivies() {
        guard let url = URL(string: apiURL) else {
            errorMessage = "URL no vàlida"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error de xarxa: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No s'han rebut dades de l'API"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    // Deserialitzar el JSON com un array de Trivia
                    let fetchedTrivies = try decoder.decode([Trivia].self, from: data)
                    
                    // Assignar les preguntes al array `trivies`
                    self?.trivies = fetchedTrivies
                    
                    self?.errorMessage = nil
                } catch {
                    self?.errorMessage = "Error en deserialitzar el JSON: \(error)"
                }
            }
        }

        task.resume()
    }
}
