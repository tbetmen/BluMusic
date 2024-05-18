//
//  SearchService.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation

struct SearchEndpoint {
    static func search(_ query: String) -> APIEndpoint<SearchResponseDTO> {
        APIEndpoint(
            path: APIPath.search.rawValue,
            method: .get,
            queryParameters: [
                "term": query,
                "limit": "10",
                "media": "music",
            ]
        )
    }
}

protocol SearchServiceInterface {
    @discardableResult
    func search(
        _ query: String,
        completion: @escaping (Result<[SongItem], Error>) -> Void
    ) -> APIServiceCancellableInterface?
}

final class SearchService {
    private let transferService: DataTransferServiceInterface

    init(transferService: DataTransferServiceInterface = DataTransferService()) {
        self.transferService = transferService
    }
}

extension SearchService: SearchServiceInterface {
    func search(
        _ query: String,
        completion: @escaping (Result<[SongItem], Error>) -> Void
    ) -> APIServiceCancellableInterface? {
        let endpoint = SearchEndpoint.search(query)
        return transferService.request(with: endpoint) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toEntity()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
