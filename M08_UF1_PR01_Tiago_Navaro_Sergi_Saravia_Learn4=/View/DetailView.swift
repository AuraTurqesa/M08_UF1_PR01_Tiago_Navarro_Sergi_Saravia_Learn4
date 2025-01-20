
import SwiftUI

struct DetailView: View {
    var trivia: Trivia  // Recibimos un objeto `Trivia`

    var body: some View {
        VStack(alignment: .leading) {
            Text("Pregunta: \(trivia.pregunta.text)")
                .font(.title)
                .padding(.bottom)

            Text("Categoría: \(trivia.categoria)")
                .font(.subheadline)
                .padding(.bottom)

            Text("Dificultad: \(trivia.dificultat)")
                .font(.subheadline)
                .padding(.bottom)

            Text("Respuestas Incorrectas:")
                .font(.subheadline)
                .padding(.top)
            
            ForEach(trivia.respostesIncorrectes, id: \.self) { respuesta in
                Text("- \(respuesta)")
                    .font(.body)
                    .padding(.leading)
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Detalles de la Pregunta", displayMode: .inline)
    }
}
