struct DetailView: View {
    @State var trivia: Trivia
    @Environment(\.dismiss) var dismiss
    var onSave: (Trivia) -> Void

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Pregunta")) {
                    TextField("Texto de la pregunta", text: $trivia.pregunta.text)
                }

                Section(header: Text("Categoria")) {
                    TextField("Categoria", text: $trivia.categoria)
                }

                Section(header: Text("Respostes")) {
                    TextField("Resposta correcta", text: $trivia.respostaCorrecta)
                    ForEach(trivia.respostesIncorrectes.indices, id: \.self) { index in
                        TextField("Resposta incorrecta \(index + 1)", text: $trivia.respostesIncorrectes[index])
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(trivia)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edita la pregunta")
        .navigationBarTitleDisplayMode(.inline)
    }
}

