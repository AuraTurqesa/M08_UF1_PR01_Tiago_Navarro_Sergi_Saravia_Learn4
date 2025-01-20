import Foundation

class TriviaManager: ObservableObject {
    @Published var trivies: [Trivia] = []  // Lista de trivias
    @Published var errorMessage: String?  // Mensaje de error opcional
    @Published var create: [Created] = [] // Lista de trivias creadas por el usuario

    private let apiURL = "https://the-trivia-api.com/v2/questions"
    
    /// Método para agregar una trivia personalizada
    func addTrivia(
        categoria: String,
        id: String,
        tags: [String],
        dificultat: String,
        regions: [String],
        esNiche: Bool,
        pregunta: Pregunta,
        respostaCorrecta: String,
        respostesIncorrectes: [String],
        tipus: String,
        puntsAcumulats: Int = 0
    ) {
        let newTrivia = Trivia(
            categoria: categoria,
            id: id,
            tags: tags,
            dificultat: dificultat,
            regions: regions,
            esNiche: esNiche,
            pregunta: pregunta,
            respostaCorrecta: respostaCorrecta,
            respostesIncorrectes: respostesIncorrectes,
            tipus: tipus,
            puntsAcumulats: puntsAcumulats
        )
        trivies.append(newTrivia)  // Agregar la trivia al array
    }
    
    /// Método para cargar trivias desde la API
    func fetchTrivies() {
        guard let url = URL(string: apiURL) else {
            errorMessage = "URL no válida"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error de red: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No se recibieron datos de la API"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let fetchedTrivies = try decoder.decode([Trivia].self, from: data)
                    self?.trivies = fetchedTrivies
                    self?.errorMessage = nil
                } catch {
                    self?.errorMessage = "Error al decodificar JSON: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
}
