//
//  EHRWebView.m
//

#import "EHRWebView.h"
#import "OCGumbo+Query.h"

@interface UIWebView(UIWebView_PrivateAPI)

- (BOOL)webView:(id)arg1 resource:(id)arg2 canAuthenticateAgainstProtectionSpace:(id)arg3 forDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didCancelAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didReceiveAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didFailLoadingWithError:(id)arg3 fromDataSource:(id)arg4;
- (void)webView:(id)arg1 resource:(id)arg2 didFinishLoadingFromDataSource:(id)arg3;

- (id)webView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5;
- (id)webView:(id)arg1 connectionPropertiesForResource:(id)arg2 dataSource:(id)arg3;

- (id)webThreadWebView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5;

@end

@implementation EHRWebView

-(instancetype)init{
    if (self=[super init]) {
//        self.enableLog=YES;
    }
    return self;
}

#pragma mark UIWebView Private
- (void)__logWebDataSource:(id)webDataSource
{
    if (self.enableLog) {
        NSLog(@"  * dataSource = %@", webDataSource);
        NSLog(@"    * dataSource.initialRequest = %@", [webDataSource valueForKey:@"initialRequest"]);
        NSLog(@"    * dataSource.request = %@", [webDataSource valueForKey:@"request"]);
        NSLog(@"    * dataSource.response = %@", [webDataSource valueForKey:@"request"]);
        NSLog(@"    * dataSource.isLoading = %d", [webDataSource isLoading]);
        NSLog(@"    * dataSource.pageTitle = %@", [webDataSource valueForKey:@"pageTitle"]);
        NSLog(@"    * dataSource.textEncodingName = %@", [webDataSource valueForKey:@"textEncodingName"]);
        NSLog(@"    * dataSource.webArchive = %@", [webDataSource valueForKey:@"webArchive"]);
        NSLog(@"    * dataSource.mainResource = %@", [webDataSource valueForKey:@"mainResource"]);
        //        NSLog(@"    * dataSource.data = %@", [webDataSource valueForKey:@"data"]);
//        NSData *webViewData=[webDataSource valueForKey:@"data"];
//        if (webViewData) {
//            NSLog(@"    * dataSource.data = %@", [[NSString alloc]initWithData:webViewData encoding:NSUTF8StringEncoding]);
//        }
    }
}

- (BOOL)webView:(id)arg1 resource:(id)arg2 canAuthenticateAgainstProtectionSpace:(id)arg3 forDataSource:(id)arg4
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        NSLog(@"  * protectionSpace = %@", arg3);
        [self __logWebDataSource:arg4];
    }
    
    return [super webView:arg1 resource:arg2 canAuthenticateAgainstProtectionSpace:arg3 forDataSource:arg4];
}

- (void)webView:(id)arg1 resource:(id)arg2 didCancelAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        NSLog(@"  * authenticationChallenge = %@", arg3);
        [self __logWebDataSource:arg4];
    }
    
    [super webView:arg1 resource:arg2 didCancelAuthenticationChallenge:arg3 fromDataSource:arg4];
}

- (void)webView:(id)arg1 resource:(id)arg2 didReceiveAuthenticationChallenge:(id)arg3 fromDataSource:(id)arg4
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        NSLog(@"  * authenticationChallenge = %@", arg3);
        [self __logWebDataSource:arg4];
    }
    
    [super webView:arg1 resource:arg2 didReceiveAuthenticationChallenge:arg3 fromDataSource:arg4];
}

//- (void)webView:(id)arg1 resource:(id)arg2 didFailLoadingWithError:(id)arg3 fromDataSource:(id)arg4
//{
////    if (self.enableLog) {
////        NSLog(@"%s", __func__);
////        NSLog(@"  * resource = %@", arg2);
////        NSLog(@"  * error = %@", arg3);
//////        [self __logWebDataSource:arg4];
////    }
////    
////    [super webView:arg1 resource:arg2 didFailLoadingWithError:arg3 fromDataSource:arg4];
//}

- (void)webView:(id)arg1 resource:(id)arg2 didFinishLoadingFromDataSource:(id)arg3
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        [self __logWebDataSource:arg3];
    }
    
//    NSData *webViewData=[arg3 valueForKey:@"data"];
//    if (webViewData) {
//        NSString *htmlString= [[NSString alloc]initWithData:webViewData encoding:NSUTF8StringEncoding];
//        if ([htmlString rangeOfString:@"<video"].length>0&&[htmlString rangeOfString:@"</video>"].length>0) {

//        }
//    }
    
    [super webView:arg1 resource:arg2 didFinishLoadingFromDataSource:arg3];

}

- (id)webView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        NSLog(@"  * request = %@", arg3);
        NSLog(@"  * redirectResponse = %@", arg4);
        [self __logWebDataSource:arg5];
    }
    
    return [super webView:arg1 resource:arg2 willSendRequest:arg3 redirectResponse:arg4 fromDataSource:arg5];
}

-(BOOL)blockURL:(NSURL *)url{
    NSSet *set=[NSSet setWithObjects:
                @"baidu.com",
                @"cnzz.com",
                @"baosmx.com",
                @"qqee.org",
//                @"bdimg.com",
                @"mmstat.com",
                nil];
    
    for (NSString *item in set) {
        if([url.host hasSuffix:item])return YES;
    }
    
    return NO;
}

- (id)webThreadWebView:(id)arg1 resource:(id)arg2 willSendRequest:(id)arg3 redirectResponse:(id)arg4 fromDataSource:(id)arg5{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        NSLog(@"  * request = %@", arg3);
        NSLog(@"  * redirectResponse = %@", arg4);
        [self __logWebDataSource:arg5];
    }
    NSMutableURLRequest *request=arg3;
    if ([self blockURL:request.URL]) {
        return nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    
    if (self.webViewDelegate) {
        if ([self.webViewDelegate webView:arg1 willSendRequest:arg3]) {
            return [super webThreadWebView:arg1 resource:arg2 willSendRequest:arg3 redirectResponse:arg4 fromDataSource:arg5];
        }else{
            return nil;
        }
    }
    
    return [super webThreadWebView:arg1 resource:arg2 willSendRequest:arg3 redirectResponse:arg4 fromDataSource:arg5];
}

- (id)webView:(id)arg1 connectionPropertiesForResource:(id)arg2 dataSource:(id)arg3
{
    if (self.enableLog) {
        NSLog(@"%s", __func__);
        NSLog(@"  * resource = %@", arg2);
        [self __logWebDataSource:arg3];
    }
    
    return [super webView:arg1 connectionPropertiesForResource:arg2 dataSource:arg3];
}

@end
