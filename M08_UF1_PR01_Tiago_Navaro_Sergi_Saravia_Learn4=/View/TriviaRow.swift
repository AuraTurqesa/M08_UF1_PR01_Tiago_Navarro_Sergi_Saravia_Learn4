import SwiftUI

struct TriviaRow: View {
    let trivia: Trivia  // La pregunta que es passarà des de la vista principal

    var body: some View {
        VStack(alignment: .leading) {
            Text(trivia.pregunta.text)  // Mostrar el text de la pregunta
                .font(.headline)
                .padding(.bottom, 5)

            HStack {
                Text("Categoria: \(trivia.categoria)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Dificultat: \(trivia.dificultat.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 5)

            Text("Respostes incorrectes:")
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.bottom, 5)

            ForEach(trivia.respostesIncorrectes, id: \.self) { answer in
                Text(answer)
                    .font(.body)
                    .padding(.bottom, 2)
            }

            Button(action: {
                // Aquí pots afegir l'acció per manipular els punts
                print("Resposta correcta: \(trivia.respostaCorrecta)")
            }) {
                Text("Respon a la pregunta")
                    .font(.body)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
