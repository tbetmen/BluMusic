//
//  MockDataTransferService.swift
//  BluMusicTests
//
//  Created by Muhammad M. Munir on 19/05/24.
//

import Foundation
@testable import BluMusic

final class MockDataTransferService: DataTransferServiceInterface {
    var isSuccess: Bool = false
    var dto: SearchResponseDTO

    init(dto: SearchResponseDTO) {
        self.dto = dto
    }

    func request<T, E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> APIServiceCancellableInterface? where T : Decodable, T == E.Response, E : ResponseRequestable {
        if isSuccess {
            completion(.success(dto as! T))
        } else {
            completion(.failure(DataTransferError.noResponse))
        }
        return nil
    }

    func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> APIServiceCancellableInterface? where E : ResponseRequestable, E.Response == () {
        return nil
    }
}
