import SwiftUI

struct DetailView: View {
    var trivia: Trivia  // Recibimos un objeto `Trivia`

    var body: some View {
        GeometryReader {_ in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pregunta: \(trivia.pregunta.text)")
                        .font(.title)
                        .padding(.bottom)

                    Text("Categoría: \(trivia.categoria)")
                        .font(.subheadline)
                        .padding(.bottom)

                    Text("Dificultad: \(trivia.dificultat)")
                        .font(.subheadline)
                        .padding(.bottom)

                    Text("Tipo: \(trivia.tipus)")
                        .font(.subheadline)
                        .padding(.bottom)

                    Text("Es Nicho: \(trivia.esNiche ? "Sí" : "No")")
                        .font(.subheadline)
                        .padding(.bottom)

                    Text("Respuestas Correctas:")
                        .font(.headline)
                        .padding(.top)

                    Text("Correcta: \(trivia.respostaCorrecta)")
                        .font(.body)
                        .padding(.bottom)

                    Text("Respuestas Incorrectas:")
                        .font(.headline)

                    ForEach(trivia.respostesIncorrectes, id: \.self) { respuesta in
                        Text("- \(respuesta)")
                            .font(.body)
                            .padding(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                    

                    if trivia.regions.isEmpty {
                        Text("No hay regiones asignadas")
                            .font(.body)
                    } else {
                        Text("Regiones:")
                            .font(.headline)
                            .padding(.top)
                        ForEach(trivia.regions, id: \.self) { region in
                            Text("- \(region)")
                                .font(.body)
                                .padding(.leading)
                        }
                    }
                
                }
                .padding()
            }
        }
            
        .navigationBarTitle("Detalles de la Pregunta", displayMode: .inline)
    }
}
