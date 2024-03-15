//
//  ShowcaseService.swift
//  
//
//  Created by Vyacheslav Beltyukov on 15/03/2024.
//

import Foundation
import PaltaCore

protocol ShowcaseService {
    func getPricePoints(
        with ids: Set<String>,
        for userId: UserId,
        completion: @escaping (Result<[WebPricePoint], PaymentsError>) -> Void
    )
}

final class ShowcaseServiceImpl: ShowcaseService {
    private let locale = Locale(identifier: "en-US")
    
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }
    
    func getPricePoints(
        with ids: Set<String>,
        for userId: UserId,
        completion: @escaping (Result<[WebPricePoint], PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest.getPricePoints(environment, userId, ids)
        
        httpClient.perform(request) { [weak self] (result: Result<PricePointsResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                self?.process(response, to: completion)
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
    
    private func process(_ response: PricePointsResponse, to completion: @escaping (Result<[WebPricePoint], PaymentsError>) -> Void) {
        completion(
            .success(
                response.pricePoints.compactMap(map)
            )
        )
    }
    
    private func map(_ pricePoint: PricePointInternal) -> WebPricePoint? {
        switch pricePoint.type {
        case .intro:
            return mapIntro(pricePoint)
        case .introNext:
            return mapIntroNext(pricePoint)
        case .lifetime:
            return mapOneTime(pricePoint)
        case .freebie:
            return mapFreebie(pricePoint)
        }
    }
    
    private func mapIntro(_ pricePoint: PricePointInternal) -> WebPricePoint? {
        guard
            let price = pricePoint.introTotalPrice.flatMap({ Decimal(string: $0, locale: locale) }),
            let periodType = pricePoint.introPeriodType.flatMap(mapPeriodType),
            let periodValue = pricePoint.introPeriodValue
        else {
            return nil
        }
        
        return WebPricePoint(
            ident: pricePoint.ident,
            name: pricePoint.name,
            payment: .intro(
                .init(
                    price: price,
                    period: SubscriptionPeriod(value: periodValue, unit: periodType),
                    currencyCode: pricePoint.currencyCode
                )
            )
        )
    }
    
    private func mapFreebie(_ pricePoint: PricePointInternal) -> WebPricePoint? {
        WebPricePoint(
            ident: pricePoint.ident,
            name: pricePoint.name,
            payment: .freebie
        )
    }
    
    private func mapIntroNext(_ pricePoint: PricePointInternal) -> WebPricePoint? {
        guard
            let price = pricePoint.introTotalPrice.flatMap({ Decimal(string: $0, locale: locale) }),
            let periodType = pricePoint.introPeriodType.flatMap(mapPeriodType),
            let periodValue = pricePoint.introPeriodValue,
            let nextPrice = pricePoint.nextTotalPrice.flatMap({ Decimal(string: $0, locale: locale) }),
            let nextPeriodType = pricePoint.nextPeriodType.flatMap(mapPeriodType),
            let nextPeriodValue = pricePoint.nextPeriodValue
        else {
            return nil
        }
        
        return WebPricePoint(
            ident: pricePoint.ident,
            name: pricePoint.name,
            payment: .subscription(
                .init(
                    introPrice: price,
                    introPeriod: SubscriptionPeriod(value: periodValue, unit: periodType),
                    price: nextPrice,
                    period: SubscriptionPeriod(value: nextPeriodValue, unit: nextPeriodType),
                    currencyCode: pricePoint.currencyCode
                )
            )
        )
    }
    
    private func mapOneTime(_ pricePoint: PricePointInternal) -> WebPricePoint? {
        guard
            let price = pricePoint.introTotalPrice.flatMap({ Decimal(string: $0, locale: locale) })
        else {
            return nil
        }
        
        return WebPricePoint(
            ident: pricePoint.ident,
            name: pricePoint.name,
            payment: .oneTime(
                .init(price: price, currencyCode: pricePoint.currencyCode)
            )
        )
    }
    
    private func mapPeriodType(_ type: String) -> SubscriptionPeriod.Unit? {
        switch type {
        case "day":
            return .day
        case "week":
            return .week
        case "month":
            return .month
        case "year":
            return .year
        default:
            return nil
        }
    }
}
