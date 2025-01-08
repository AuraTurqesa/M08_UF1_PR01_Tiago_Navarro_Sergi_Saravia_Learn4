import Foundation

class TriviaManager: ObservableObject {
    @Published var preguntes: [Trivia] = []
    
    // Función para cargar preguntas desde la API
    class TriviaManager: ObservableObject {
        static let shared = TriviaManager() // Instància compartida (singleton)
        
        @Published var preguntes: [Trivia] = [] // Array global de preguntes
        
        private init() {} // Impedir que es creïn noves instàncies
        
        func carregarPreguntes(completat: @escaping (Bool) -> Void) {
            let urlString = "https://the-trivia-api.com/v2/questions"
            guard let url = URL(string: urlString) else {
                print("URL no vàlida")
                completat(false)
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Error en la sol·licitud: \(error)")
                    completat(false)
                    return
                }

                guard let data = data else {
                    print("No s'han rebut dades")
                    completat(false)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let preguntesRecibides = try decoder.decode([Trivia].self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.preguntes = preguntesRecibides
                        completat(true)
                    }
                } catch {
                    print("Error al decodificar les dades: \(error)")
                    completat(false)
                }
            }.resume()
        }
    }
}

class Puntuacio: ObservableObject {
    
}
