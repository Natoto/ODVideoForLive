//
//  EHRWebView.h
//

#import <UIKit/UIKit.h>

@protocol EHRWebViewDelegate <NSObject>

@optional

-(BOOL)webView:(UIWebView *)webView willSendRequest:(NSURLRequest *)request;

@end

@interface EHRWebView : UIWebView


@property (nonatomic,assign) id<EHRWebViewDelegate> webViewDelegate;

@property (nonatomic,assign) BOOL enableLog;

@end
