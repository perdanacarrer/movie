//
//  SignUpView.swift
//  movie
//
//  Created by oscar perdana on 08/06/24.
//

import SwiftUI
import CoreData
import CryptoKit

struct SignUpView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "hand.wave")
            }
            .padding(.bottom, 10)

            Text("Sign Up for more features.")
                .foregroundColor(.black)
                .font(.body)
                .padding(.bottom, 30)

            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Spacer()
            Button(action: {
                signUp()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Username Already Exists"),
                    message: Text("Please choose a different username."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.bottom, 20)
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
    
    private func signUp() {
        guard !username.isEmpty && !password.isEmpty else { return }
        let hashedUsername = username.MD5()
        let hashedPassword = password.MD5()
        if CoreDataManager.shared.saveUser(username: hashedUsername, password: hashedPassword) {
            DispatchQueue.main.async {
                guard presentationMode.wrappedValue.isPresented else { return }
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            showingAlert = true
        }
    }
}
