//
// Copyright (c) 2023-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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
import AuthFoundation

extension OpenIdConfiguration {
    var oobAuthenticateEndpoint: URL? {
        tokenEndpoint.url(replacing: "/token", with: "/oob-authenticate")
    }
}

struct OOBResponse: Codable {
    let oobCode: String
    let expiresIn: TimeInterval
    let interval: TimeInterval
    let channel: DirectAuthenticationFlow.OOBChannel
    let bindingMethod: BindingMethod
}

struct OOBAuthenticateRequest {
    let url: URL
    let clientConfiguration: OAuth2Client.Configuration
    let loginHint: String
    let channelHint: DirectAuthenticationFlow.OOBChannel
    
    init(openIdConfiguration: OpenIdConfiguration,
         clientConfiguration: OAuth2Client.Configuration,
         loginHint: String,
         channelHint: DirectAuthenticationFlow.OOBChannel) throws
    {
        guard let url = openIdConfiguration.oobAuthenticateEndpoint else {
            throw OAuth2Error.cannotComposeUrl
        }
        
        self.url = url
        self.clientConfiguration = clientConfiguration
        self.loginHint = loginHint
        self.channelHint = channelHint
    }
}

enum BindingMethod: String, Codable {
    case none
}

extension OOBAuthenticateRequest: APIRequest, APIRequestBody {
    typealias ResponseType = OOBResponse

    var httpMethod: APIRequestMethod { .post }
    var contentType: APIContentType? { .formEncoded }
    var acceptsType: APIContentType? { .json }
    var bodyParameters: [String: Any]? {
        var result: [String: Any] = [
            "client_id": clientConfiguration.clientId,
            "login_hint": loginHint,
            "channel_hint": channelHint.rawValue
        ]
        
        if let parameters = clientConfiguration.authentication.additionalParameters {
            result.merge(parameters, uniquingKeysWith: { $1 })
        }

        return result
    }
}
