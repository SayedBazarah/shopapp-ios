//
//  AccountViewModel.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 12/6/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import RxSwift

class AccountViewModel: BaseViewModel {
    private let customerUseCase = CustomerUseCase()
    private let loginUseCase = LoginUseCase()
    private let logoutUseCase = LogoutUseCase()
    private let shopUseCase = ShopUseCase()
    
    var policies = Variable<[Policy]>([Policy]())
    var customer = Variable<Customer?>(nil)
    
    // MARK: - Private
    
    private func getCustomer() {
        let showHud = customer.value == nil
        state.onNext(.loading(showHud: showHud))
        customerUseCase.getCustomer { [weak self] (customer, error) in
            if let error = error {
                self?.state.onNext(.error(error: error))
            }
            if let customer = customer {
                self?.customer.value = customer
                self?.state.onNext(.content)
            }
        }
    }
    
    private func processResponse(with shopItem: Shop) {
        var policiesItems = [Policy]()
        if let privacyPolicy = shopItem.privacyPolicy, privacyPolicy.body?.isEmpty == false {
            policiesItems.append(privacyPolicy)
        }
        if let refundPolicy = shopItem.refundPolicy, refundPolicy.body?.isEmpty == false {
            policiesItems.append(refundPolicy)
        }
        if let termsOfService = shopItem.termsOfService, termsOfService.body?.isEmpty == false {
            policiesItems.append(termsOfService)
        }
        policies.value = policiesItems
    }
    
    // MARK: - Internal
    
    func loadCustomer() {
        loginUseCase.getLoginStatus { (isLoggedIn) in
            if isLoggedIn {
                getCustomer()
            }
        }
    }
    
    func loadPolicies() {
        shopUseCase.getShop { [weak self] (shop) in
            self?.processResponse(with: shop)
        }
    }
    
    func logout() {
        logoutUseCase.logout { [weak self] (isLoggedOut) in
            if isLoggedOut {
                self?.customer.value = nil
            }
        }
    }
}
