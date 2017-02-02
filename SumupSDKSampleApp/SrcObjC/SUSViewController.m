//
//  SUSViewController.m
//  SumupSDKSampleAPP
//
//  Created by Felix Lamouroux on 29.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import "SUSViewController.h"
#import <SumupSDK/SumupSDK.h>

@interface SUSViewController () <UITextFieldDelegate>
@property BOOL appeared;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTotal;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogout;
@property (weak, nonatomic) IBOutlet UIButton *buttonCharge;
@property (weak, nonatomic) IBOutlet UIButton *buttonPreferences;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SUSViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // on first appear present login
    if (!self.appeared) {
        [self buttonLoginTapped:nil];
        [self setAppeared:YES];
    }
}

- (IBAction)buttonLoginTapped:(id)sender {
    [SumupSDK presentLoginFromViewController:self
                                    animated:YES
                             completionBlock:^(BOOL success, NSError *error) {
                                 if (error) {
                                     // errors are handled within the SDK, there should be no need
                                     // for your app to display any error message
                                 }
                                 
                                 [self updateButtonState];
                                 
                             }];
}

- (IBAction)buttonOpenPreferencesTapped:(id)sender {
    [SumupSDK presentCheckoutPreferencesFromViewController:self
                                                  animated:YES
                                                completion:^(BOOL success, NSError * _Nullable error) {
                                                    if (!success || error) {
                                                        [self showResultsString:@"not logged in"];
                                                    }
                                                }];
}

- (IBAction)buttonChargeTapped:(id)sender {
    // check total and currency code
    NSString *total = [[self textFieldTotal] text];
    NSString *currencyCode = [[SumupSDK currentMerchant] currencyCode];
    
    if (([total doubleValue] <= 0) || ![currencyCode length]) {
        [self showResultsString:@"not logged in"];
        return;
    }
    
    SMPCheckoutRequest *request;

    request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithString:total]
                                             title:self.textFieldTitle.text
                                      currencyCode:currencyCode
                                    paymentOptions:SMPPaymentOptionAny];
    
    // the foreignTransactionID is an optional parameter and can be used
    // to retrieve a transaction from SumUp's API. See -[SMPCheckoutRequest foreignTransactionID]
    [request setForeignTransactionID:[NSString stringWithFormat:@"your-unique-identifier-%@", [[NSProcessInfo processInfo] globallyUniqueString]]];
    
    [SumupSDK checkoutWithRequest:request fromViewController:self completion:^(SMPCheckoutResult *result, NSError *error) {
        if ([error.domain isEqualToString:SMPSumupSDKErrorDomain] && (error.code == SMPSumupSDKErrorAccountNotLoggedIn)) {
            [self showResultsString:@"not logged in"];
            return;
        }
        
        [self showResultsString:[NSString stringWithFormat:@"%@ - %@", result.success ? @"Thank you" : @"No charge", result.transactionCode]];
        
        if (result.success) {
            [self.textFieldTitle setText:nil];
        }
    }];
    
    // something went wrong checkout was not started
    if (![SumupSDK checkoutInProgress]) {
        [self showResultsString:@"failed to start checkout"];
    }
}

- (IBAction)buttonLogoutTapped:(id)sender {
    [SumupSDK logoutWithCompletionBlock:^(BOOL success, NSError *error) {
        [self updateButtonState];
    }];
}

- (void)updateButtonState {
    BOOL isLoggedIn = [SumupSDK isLoggedIn];
    [[self buttonLogin] setEnabled:!isLoggedIn];
    [[self buttonLogout] setEnabled:isLoggedIn];

    // real apps should usually disable these actions when the user
    // is not logged in - we keep them enabled to demonstrate the
    // error handling

    // [[self buttonCharge] setEnabled:isLoggedIn];
    // [[self buttonPreferences] setEnabled:isLoggedIn];

    [self addCurrencyToTextField];
}

#pragma mark -
#pragma mark - Beautify UI

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCurrencyToTextField];
    [self updateButtonState];
    [self.label setAlpha:0.0];
    [self.versionLabel setText:[NSString stringWithFormat:@"v%@.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
}

- (void)addCurrencyToTextField {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [label setFont:self.textFieldTotal.font];
    SMPMerchant *merchant = [SumupSDK currentMerchant];
    [label setText:[merchant currencyCode]?:@"---"];
    [label sizeToFit];
    [label setBounds:CGRectInset(label.bounds, -5, 0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [[self textFieldTotal] setRightView:label];
    [[self textFieldTotal] setRightViewMode:UITextFieldViewModeAlways];
}

- (void)showResultsString:(NSString *)result {
    [self.label setText:result];
    [UIView animateWithDuration:1.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.label setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:2.0
                                             options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [self.label setAlpha:0.0];
                                          } completion:nil];
                     }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldTotal) {
        [self.textFieldTitle becomeFirstResponder];
    } else if ([SumupSDK isLoggedIn]) {
        [self buttonChargeTapped:nil];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}
@end
