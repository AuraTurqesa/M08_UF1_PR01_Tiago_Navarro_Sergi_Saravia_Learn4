import Foundation

// Model per a les dades de l'API
struct Trivia: Codable {
    let categoria: String
    let dificultat: String
    let pregunta: String
    let respostaCorrecta: String
    let respostesIncorrectes: [String]
    var puntsAcumulats: Int = 0

    enum CodingKeys: String, CodingKey {
        case categoria = "category"
        case dificultat = "difficulty"
        case pregunta = "question"
        case respostaCorrecta = "correctAnswer"
        case respostesIncorrectes = "incorrectAnswers"
    }
    
    // Decodificación personalizada para acceder a `question.text`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoria = try container.decode(String.self, forKey: .categoria)
        dificultat = try container.decode(String.self, forKey: .dificultat)
        respostaCorrecta = try container.decode(String.self, forKey: .respostaCorrecta)
        respostesIncorrectes = try container.decode([String].self, forKey: .respostesIncorrectes)

        // Extraer la pregunta de `question.text`
        let preguntaContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pregunta)
        pregunta = try preguntaContainer.decode(String.self, forKey: .pregunta)
    }
}

// Model per a una pregunta en el joc
struct Game {
    let pregunta: String
    let opcions: [String]
    let respostaCorrecta: String
    var puntuacio: Int = 0
}

// Model per a la puntuació final
struct Puntuacio {
    let punts: Int
    let preguntesRespostes: [PreguntaResposta]
}

// Model per a cada pregunta i resposta del joc
struct PreguntaResposta {
    let pregunta: String
    let resposta: String
    let respostaCorrecta: String
    let esCorrecte: Bool
}
