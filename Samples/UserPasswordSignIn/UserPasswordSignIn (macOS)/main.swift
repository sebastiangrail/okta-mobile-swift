//
// Copyright (c) 2022-Present, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import Foundation
import ArgumentParser
import OktaOAuth2

#if swift(>=5.6)
typealias Command = AsyncParsableCommand
#else
typealias Command = ParsableCommand
#endif

@main
struct UserPasswordSignIn: Command {
    @Option(help: "The application's issuer URL.")
    var issuer: String
    
    @Option(help: "The application's client ID.")
    var clientId: String
    
    @Option(help: "The scopes to use.")
    var scopes: String = "openid profile"
    
    #if swift(>=5.6)
    mutating func run() async throws {
        guard #available(macOS 12, *) else {
            print("'user-password-sign-in' isn't supported on this platform.")
            return
        }
        
        let flow = try createFlow()
        let token = try await flow.start(username: try promptUsername(),
                                         password: try promptPassword())
        printUserInfo(using: token)
    }
    #else
    mutating func run() throws {
        guard #available(macOS 12, *) else {
            print("'user-password-sign-in' isn't supported on this platform.")
            return
        }
 
        let flow = try createFlow()
        
        let group = DispatchGroup()
        group.enter()
        flow.start(username: try promptUsername(),
                   password: try promptPassword()) { result in
            defer { group.leave() }
            switch result {
            case .success(let token):
                printUserInfo(using: token)
            case .failure(let error):
                print(error)
            }
        }
        _ = group.wait(timeout: .now() + 30)
    }
    #endif
}
