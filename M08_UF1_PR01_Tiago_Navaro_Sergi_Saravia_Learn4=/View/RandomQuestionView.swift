import SwiftUI

struct RandomQuestionView: View {
    @StateObject private var triviaManager = TriviaManager()  // Crear el gestor de preguntes
    @State private var randomTrivia: Trivia? = nil  // Variable per emmagatzemar la pregunta aleatòria
    @State private var options: [String] = []  // Opcions de resposta
    @State private var selectedAnswer: String? = nil  // Resposta seleccionada per l'usuari
    @State private var puntsAcumulats: Int = 0  // Variable per emmagatzemar els punts acumulats

    var body: some View {
        VStack {
            // Mostrar els punts acumulats a la part superior
            Text("Punts: \(puntsAcumulats)")
                .font(.title2)
                .padding()

            if let randomTrivia = randomTrivia {
                Text(randomTrivia.pregunta.text)  // Mostrar el text de la pregunta aleatòria
                    .font(.body)  // Mida de la lletra més petita
                    .padding()

                // Mostrar les opcions de resposta
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedAnswer = option  // Assignar la resposta seleccionada
                        checkAnswer(selectedAnswer)  // Comprovar si la resposta és correcta
                    }) {
                        Text(option)
                            .font(.body)  // Mida de la lletra més petita per a les opcions
                            .padding()
                            .background(selectedAnswer == option ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(2)
                    }
                }
            } else {
                Text("Carregant pregunta aleatòria...")  // Missatge quan la pregunta encara no s'ha carregat
                    .font(.body)  // Mida de la lletra més petita
                    .padding()
            }

            Button(action: {
                fetchRandomTrivia()  // Funció per obtenir una pregunta aleatòria
            }) {
                Text("Mostrar una altra pregunta aleatòria")
                    .font(.body)  // Mida de la lletra més petita
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .onAppear {
            triviaManager.fetchTrivies()  // Carregar totes les preguntes des de l'API quan es carrega la vista
        }
    }

    // Funció per obtenir una pregunta aleatòria de l'array
    func fetchRandomTrivia() {
        if let randomTrivia = triviaManager.trivies.randomElement() {
            self.randomTrivia = randomTrivia
            self.options = shuffleOptions(correctAnswer: randomTrivia.respostaCorrecta, incorrectAnswers: randomTrivia.respostesIncorrectes)
        }
    }

    // Funció per barallar les opcions (correcta + incorrectes)
    func shuffleOptions(correctAnswer: String, incorrectAnswers: [String]) -> [String] {
        var allOptions = incorrectAnswers
        allOptions.append(correctAnswer)  // Afegir la resposta correcta a les opcions
        return allOptions.shuffled()  // Barallar les opcions
    }

    // Funció per comprovar si la resposta seleccionada és correcta
    func checkAnswer(_ answer: String?) {
        if let correctAnswer = randomTrivia?.respostaCorrecta, answer == correctAnswer {
            puntsAcumulats += 1  // Incrementar els punts si la resposta és correcta
        }
    }
}
