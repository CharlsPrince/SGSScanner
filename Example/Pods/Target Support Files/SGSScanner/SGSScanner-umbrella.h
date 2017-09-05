#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SGSScanner.h"
#import "SGSScannerDelegate.h"
#import "SGSScannerView.h"
#import "SGSScannerViewController.h"
#import "NSBundle+SGSScanner.h"
#import "SGSScanPreviewStyle.h"
#import "SGSScanPreviewView.h"
#import "SGSScanUtil.h"
#import "SGSScanUtilDelegate.h"

FOUNDATION_EXPORT double SGSScannerVersionNumber;
FOUNDATION_EXPORT const unsigned char SGSScannerVersionString[];

