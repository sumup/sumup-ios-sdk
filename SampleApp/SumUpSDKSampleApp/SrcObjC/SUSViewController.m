//
//  SUSViewController.m
//  SumUpSDKSampleAPP
//
//  Created by Felix Lamouroux on 29.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import "SUSViewController.h"
#import <SumUpSDK/SumUpSDK.h>

@interface SUSViewController ()<UITextFieldDelegate>
@property BOOL appeared;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTotal;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogout;
@property (weak, nonatomic) IBOutlet UIButton *buttonCharge;
@property (weak, nonatomic) IBOutlet UIButton *buttonPreferences;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlTipping;
@property (weak, nonatomic) IBOutlet UISwitch *switchSkipReceiptScreen;

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
    [SMPSumUpSDK presentLoginFromViewController:self
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
    [SMPSumUpSDK presentCheckoutPreferencesFromViewController:self
                                                     animated:YES
                                                   completion:^(BOOL success, NSError *_Nullable error) {
                                                       if (!success || error) {
                                                           [self showResultsString:@"not logged in"];
                                                       }
                                                   }];
}

- (IBAction)buttonChargeTapped:(id)sender {
    // check total and currency code
    NSString *total = [[self textFieldTotal] text];
    NSString *currencyCode = [[SMPSumUpSDK currentMerchant] currencyCode];

    if (([total doubleValue] <= 0) || ![currencyCode length]) {
        [self showResultsString:@"not logged in"];
        return;
    }

    SMPCheckoutRequest *request;

    request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithString:total]
                                             title:self.textFieldTitle.text
                                      currencyCode:currencyCode
                                    paymentOptions:SMPPaymentOptionAny];

    // Tip is optional. Default is no tip.
    NSInteger selectedTipSegment = self.segmentedControlTipping.selectedSegmentIndex;

    if (selectedTipSegment > 0) {
        [request setTipAmount:[[self tipAmounts] objectAtIndex:selectedTipSegment]];
    }

    // Skip receipt screen if toggle is set to on
    if (self.switchSkipReceiptScreen.isOn) {
        [request setSkipScreenOptions:SMPSkipScreenOptionSuccess];
    }

    // the foreignTransactionID is an optional parameter and can be used
    // to retrieve a transaction from SumUp's API. See -[SMPCheckoutRequest foreignTransactionID]
    [request setForeignTransactionID:[NSString stringWithFormat:@"your-unique-identifier-%@", [[NSProcessInfo processInfo] globallyUniqueString]]];

    [SMPSumUpSDK checkoutWithRequest:request fromViewController:self completion:^(SMPCheckoutResult *result, NSError *error) {
        if ([error.domain isEqualToString:SMPSumUpSDKErrorDomain] && (error.code == SMPSumUpSDKErrorAccountNotLoggedIn)) {
            [self showResultsString:@"not logged in"];
            return;
        }

        NSMutableArray<NSString *> *strings = [NSMutableArray array];
        [strings addObject:[NSString stringWithFormat:@"%@ - %@", result.success ? @"Thank you" : @"No charge", result.transactionCode ? : @"no transaction"]];

        if (result.transactionCode) {
            // get optional tip amount
            NSNumber *tipAmount = result.additionalInfo[@"tip_amount"];

            // display tip only if greater than zero
            if ([tipAmount isKindOfClass:[NSNumber class]] && (tipAmount.doubleValue > 0)) {
                [strings addObject:[NSString stringWithFormat:@"%@ (incl. %@ tip) %@", result.additionalInfo[@"amount"], tipAmount, result.additionalInfo[@"currency"]]];
            } else {
                [strings addObject:[NSString stringWithFormat:@"%@ %@ (no tip)", result.additionalInfo[@"amount"], result.additionalInfo[@"currency"]]];
            }
        }

        [self showResultsString:[strings componentsJoinedByString:@"\n"]];

        if (result.success) {
            [self.textFieldTitle setText:nil];
        }
    }];

    // something went wrong checkout was not started
    if (![SMPSumUpSDK checkoutInProgress]) {
        [self showResultsString:@"failed to start checkout"];
    }
}

- (IBAction)buttonLogoutTapped:(id)sender {
    [SMPSumUpSDK logoutWithCompletionBlock:^(BOOL success, NSError *error) {
        [self updateButtonState];
    }];
}

- (void)updateButtonState {
    BOOL isLoggedIn = [SMPSumUpSDK isLoggedIn];

    [[self buttonLogin] setEnabled:!isLoggedIn];
    [[self buttonLogout] setEnabled:isLoggedIn];

    // real apps should usually disable these actions when the user
    // is not logged in - we keep them enabled to demonstrate the
    // error handling

    // [[self buttonCharge] setEnabled:isLoggedIn];
    // [[self buttonPreferences] setEnabled:isLoggedIn];

    [self addCurrencyToTextField];

    [self updateTipControl];
}

#pragma mark - Tipping

- (void)updateTipControl {
    BOOL isLoggedIn = [SMPSumUpSDK isLoggedIn];

    [self.segmentedControlTipping setHidden:!isLoggedIn];
    [self.segmentedControlTipping removeAllSegments];

    for (NSDecimalNumber *tip in [self tipAmounts]) {
        BOOL isZero = [tip isEqual:[NSDecimalNumber zero]];
        NSString *title = isZero ? @"No tip" : [NSString stringWithFormat:@"%@ %@", tip, [[SMPSumUpSDK currentMerchant] currencyCode]];
        [self.segmentedControlTipping insertSegmentWithTitle:title atIndex:self.segmentedControlTipping.numberOfSegments animated:YES];
    }

    [self.switchSkipReceiptScreen setEnabled:isLoggedIn];
}

/// some examples of tip amounts in merchant currency units
- (NSArray<NSDecimalNumber *> *)tipAmounts {
    NSString *currencyCode = [[SMPSumUpSDK currentMerchant] currencyCode];

    if (!currencyCode.length) {
        return @[];
    }

    if ([currencyCode isEqualToString:SMPCurrencyCodeSEK]) {
        return @[[NSDecimalNumber zero],
                 [NSDecimalNumber decimalNumberWithMantissa:20 exponent:0 isNegative:NO],
                 [NSDecimalNumber decimalNumberWithMantissa:40 exponent:0 isNegative:NO],
                 ];
    } else if ([currencyCode isEqualToString:SMPCurrencyCodeBRL]) {
        return @[[NSDecimalNumber zero],
                 [NSDecimalNumber decimalNumberWithMantissa:5 exponent:0 isNegative:NO],
                 [NSDecimalNumber decimalNumberWithMantissa:10 exponent:0 isNegative:NO],
                 ];
    }

    return @[[NSDecimalNumber zero],
             [NSDecimalNumber decimalNumberWithMantissa:2 exponent:0 isNegative:NO],
             [NSDecimalNumber decimalNumberWithMantissa:5 exponent:0 isNegative:NO],
             ];
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
    SMPMerchant *merchant = [SMPSumUpSDK currentMerchant];
    [label setText:[merchant currencyCode] ? : @"---"];
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
        // we assume a checkout is imminent
        // let the SDK know to e.g. wake a connected terminal
        [SMPSumUpSDK prepareForCheckout];
        
        [self.textFieldTitle becomeFirstResponder];
    } else if ([SMPSumUpSDK isLoggedIn]) {
        [self buttonChargeTapped:nil];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
