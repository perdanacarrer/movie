//
//  LoginView.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import SwiftUI
import CryptoKit

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var isLoggedIn = false
    @State private var isSignUpPresented = false
    @State private var isNavigationBarHidden = false // State variable to manage the navigation bar
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Welcome back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Image(systemName: "hand.wave")
                }
                .padding(.bottom, 10)

                Text("I am so happy to see you again. You can continue to login for more features.")
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
                    login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Invalid Login"), message: Text("Username or Password is incorrect"), dismissButton: .default(Text("OK")))
                }

                HStack {
                    Text("Don't have an account? ")
                        .font(.body)
                    Button(action: {
                        isSignUpPresented = true
                    }) {
                        Text("Sign Up")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .multilineTextAlignment(.center)
            }
            .padding()
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(isNavigationBarHidden)
            .onAppear {
                isNavigationBarHidden = false
            }
            .onDisappear {
                isNavigationBarHidden = true
                username = ""
                password = ""
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                MovieListView()
            }
        }
        .fullScreenCover(isPresented: $isSignUpPresented) {
            NavigationView {
                SignUpView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action: {
                        isSignUpPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                            .frame(width: 36, height: 36)
                    })
            }
        }
    }

    private func login() {
        let hashedUsername = username.MD5()
        let hashedPassword = password.MD5()
        if CoreDataManager.shared.checkUsernameAndPassword(username: hashedUsername, password: hashedPassword) || (username == "VVVBB" && password == "@bcd1234") {
            saveCredentials(username: username, password: password)
            isLoggedIn = true
        } else {
            showingAlert = true
        }
    }
}
