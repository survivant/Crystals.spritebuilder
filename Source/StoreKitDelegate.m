//
//  StoreKitDelegate.m
//  Crystals
//
//  Created by Ian Fischer on 9/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "StoreKitDelegate.h"

@implementation StoreKitDelegate

- (id)init
{
    self = [super init];
    if (self) {
        [self setupIAP];
    }
    return self;
}

- (void) setupIAP
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                         withExtension:@"plist"];
    NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    
    StoreKitDelegate *delegate  = [[StoreKitDelegate alloc] init];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:delegate];
    
    [delegate validateProductIdentifiers:productIdentifiers];
}

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    
    if (NO) {
        // This won't work if your app isn't set up with the App Store, so let's not do it.
        [productsRequest start];
    }
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
    
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"Found an invalid identifier: %@", invalidIdentifier);
    }
    
    NSLog(@"This is where you would display a real UI. Instead, we are going to just trigger a purchase.");
    if ([self.products count] > 0) {
        [self purchaseProduct:self.products[0]];
    }
}

- (void)purchaseProduct:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    NSLog(@"This is where you would do something to your app based on the receipt: %@, %@", receiptURL, receiptData);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Failed transaction: %@", transaction);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"This is where you would do something to your app to restore the transaction: %@", transaction);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end