# Swift SDK for Palta MPP

This SDK is used to manage access to paid features in iOS apps.

## Plugin system
This SDK allows simultaneous access to several revenue management systems. Their data is combined together in the output. Currently, 3 systems are supported: Palta MPP, RevenueCat and Palta legacy web payments.
### Palta MPP
To setup a Palta MPP plugin, you need to know an API key and a host for your API instance:
```
PBPurchasePlugin(apiKey: "<API_KEY>", environment: URL(string: "https://api.example.com")!)
```
### RevenueCat
To setup RevenueCat, you need only its API key:
```
RCPurchasePlugin(apiKey: "<API_KEY>")
```
### Palta legacy web payments
You need your app's web subscription id:
```
PBLegacyPurchasePlugin(webSubscriptionID: "")
```

## Geting started
First, you need to initialize the SDK with all plugins that you're going to use:
```
PaltaPurchases.instance.setup(with: [
    PBPurchasePlugin(...),
    RCPurchasePlugin(...),
    PBLegacyPurchasePlugin(...)
])
```

As soon as you know your user ID, you perform login:
```
PaltaPurchases.instance.logIn(appUserId: .string("some-id"), completion: { _ in })
```

When user logs out, you call logout method:
```
 PaltaPurchases.instance.logOut()
```

You can also hide `PaltaPurchases` instance under `PaltaPurchasesProtocol`.

## Checking user's access and subscriptions
There's 2 ways of checking users access. First, you can checkout all info about the user at once, including both enabled features and payment info about them. Second, you can checkout only enabled features and get subscriptions information separately.
### Getting all at once
```
PaltaPurchases.instance.getPaidFeatures { result in
    switch result {
    case .success(let paidFeatures):
        print(paidFeatures.hasActiveFeature(with: "premium"))
        print(paidFeatures.activeFeatures.first?.pricePointIdent)
        
    case .failure(let error):
        print(error)
    }
}
```

### Getting features info only
```
PaltaPurchases.instance.getFeatures { result in
    switch result {
    case .success(let features):
        print(paidFeatures.hasActiveFeature(with: "premium"))
        
    case .failure(let error):
        print(error)
    }
}
```

### Getting subscriptions info only
```
PaltaPurchases.instance.getSubscriptions { result in
    switch result {
    case .success(let subscriptions):
        print(subscriptions.first?.state)
        print(subscriptions.first?.price)
        
    case .failure(let error):
        print(error)
    }
}
```

## Selling new subscriptions and products
### Getting available subscriptions and products
You can retrieve both App Store products (through RevenueCat) and Palta price points (through MPP).
```
PaltaPurchases.instance.getProductsAndPricePoints(with: ["some_id"]) { result in
    switch result {
    case .success(let products):
        print(products)
        
    case .failure(let error):
        print(error)
    }
}
```
### Performing a purchase
You can sell only App Store products with this SDK. Payments through Palta MPP should be made on web. If you attempt to pass an instance of `Product` corresponding to MPP's price point, you will get an error `PaymentsError.webPaymentsNotSupported`.
```
PaltaPurchases.instance.purchase(product, with: nil) { result in
    switch result {
    case .success(let purchase):
        print(purchase.paidFeatures.hasActiveFeature(with: "name"))
        
    case .failure(let error):
        print(error)
    }
}
```

You can also use `purchase2` method to get lightweight result without subscriptions info.

## Development
See [development guide](DEVELOPMENT.md).
