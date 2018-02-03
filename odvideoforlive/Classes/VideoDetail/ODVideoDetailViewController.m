//
//  ODVideoDetailViewController.m
//  视频详情页
//
//  Created by 罗飞 on 23/09/2017.
//Copyright © 2017 one. All rights reserved.
//

#import "ODVideoDetailViewController.h"
#import <Masonry/Masonry.h>
#import <ZFPlayer/ZFPlayer.h>
#import "OCGumbo+Query.h"
#import <WebKit/WebKit.h>
#import "ODNetworking.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "EHRWebView.h"
#import "CLUPnPServer.h"
#import "CLUPnPRenderer.h"
#import "CLUPnPDevice.h"

@interface VideoDetailItem:NSObject

@property(nonatomic,strong) NSString * title;

@property(nonatomic,assign) NSInteger  index;

@property(nonatomic,strong) NSString * serverUri;

@end

@implementation VideoDetailItem

@end

@interface ODVideoDetailViewController ()<WKNavigationDelegate,EHRWebViewDelegate,UIWebViewDelegate,CLUPnPServerDelegate>

#pragma mark - --- 属性定义 ---

@property(nonatomic,strong) ZFPlayerView * playerView;

@property(nonatomic,strong) WKWebView * wkWebView;

@property(nonatomic,strong) EHRWebView * webView;

@property(nonatomic,strong) ZFPlayerModel *playerModel;

@property(nonatomic,strong) NSArray<VideoDetailItem *> * data;

@property(nonatomic,strong) UIView * playerContentView;

@property(nonatomic,strong) UIScrollView * itemsView;

@property(nonatomic,strong) MBProgressHUD *hud;

@property(nonatomic,assign) BOOL  originPlayer;

@property(nonatomic,strong) UIBarButtonItem *dlnaButton;

@property(nonatomic,strong) UIBarButtonItem *playerButton;

//TODO DLNA TV 视频投放 后期优化
@property(nonatomic,strong) CLUPnPRenderer *renderer;

@property(nonatomic,strong) CLUPnPServer *server;


@end

@implementation ODVideoDetailViewController

#pragma mark - --- 生命周期 ---

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewLayout];
    
    [self initViewEvents];
    
    [self initViewDataSource];
}

#pragma mark - --- 初始化事件 ---

-(void)initViewLayout{
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.playerView = [[ZFPlayerView alloc] init];
    self.playerView.hasDownload=YES;
    
    
    self.itemsView=[[UIScrollView alloc]init];
    self.itemsView.bounces=NO;
    

    self.playerContentView=[[UIView alloc]init];
    
    [self.playerContentView addSubview:self.playerView];
    
    [self.view addSubview:self.itemsView];
    [self.view addSubview:self.playerContentView];
    
    [self.playerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth);
        make.height.mas_equalTo(ScreenWidth*9.0/16);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.itemsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((ScreenWidth*9.0/16+64));
        make.left.right.bottom.mas_equalTo(0);
    }];
    
}

-(void)initViewEvents{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedVideoUrlString:) name:@"VideoUrlString" object:nil];
    
    UIBarButtonItem *playerButton=[[UIBarButtonItem alloc]initWithTitle:@"播放器2" style:UIBarButtonItemStylePlain target:self action:@selector(switchPlayer)];
    UIBarButtonItem *dlnaButton=[[UIBarButtonItem alloc]initWithTitle:@"TV 关" style:UIBarButtonItemStylePlain target:self action:@selector(switchDLNA)];
    self.playerButton=playerButton;
    self.dlnaButton=dlnaButton;
    self.navigationItem.rightBarButtonItems=@[playerButton,dlnaButton];
    
    CLUPnPServer *server=[CLUPnPServer shareServer];
    server.delegate=self;
    [server start];
    self.server=server;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)initViewDataSource{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"加载中...";
    self.hud=hud;
//    NSString *htmlString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"detail.html" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    [ODNetworking GET:self.targerUri complete:^(NSData *data, NSError *error) {
        hud.label.text=@"解析中...";
        if(data){
            [self parseHtmlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }else{
            [hud hideAnimated:YES];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [SVProgressHUD dismissWithDelay:2];
        }
    }];
}

#pragma mark - --- dataSource ---

-(void)parseHtmlString:(NSString *)htmlString{
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
    NSArray<OCGumboElement *> *menus= document.Query(@"div.article-paging").find(@"a");
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:menus.count];
    for (OCGumboElement *element in menus) {
        NSString *title= element.text();
        NSString *itemId= element.attr(@"id");
        NSRange underlineRange=[itemId rangeOfString:@"_"];
        NSInteger itemIndex=underlineRange.length>0?[[itemId substringFromIndex:underlineRange.location+1] integerValue]:0;
        
        VideoDetailItem *item=[[VideoDetailItem alloc]init];
        item.index=itemIndex;
        item.title=title;
        
        [array addObject:item];
        
    }
    if(!array.count){
        VideoDetailItem *item=[[VideoDetailItem alloc]init];
        item.index=0;
        item.title=@"默认";
        [array addObject:item];
    }
    
    self.data=[array copy];
    
    __block NSRange startRange=[htmlString rangeOfString:@"var videoarr = new Array();"];
    __block NSRange endRange=[htmlString rangeOfString:@"function playvideo(n)"];
    if (startRange.length>0&&endRange.length>0) {
        NSString *target=[htmlString substringWithRange:NSMakeRange(startRange.location+startRange.length+1, endRange.location-startRange.location-startRange.length-1)];
        NSArray<NSString *> * items= [target componentsSeparatedByString:@";"];
        [items enumerateObjectsUsingBlock:^(NSString *  item, NSUInteger idx, BOOL * _Nonnull stop) {
            startRange=[item rangeOfString:@"'"];
            endRange=[item rangeOfString:@"'" options:NSBackwardsSearch];
            if (startRange.length>0&&endRange.length>0&&startRange.location!=endRange.location) {
                if (idx<self.data.count) {
                    VideoDetailItem *model=self.data[idx];
                    model.serverUri=[item substringWithRange:NSMakeRange(startRange.location+1, endRange.location-startRange.location-1)];
                }
            }
        }];
    }
    
    self.hud.label.text=@"解析完成";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hud hideAnimated:YES];
    });
    [self reloadItemView];
}

#pragma mark - --- override ---

#pragma mark - --- api event ---

#pragma mark - --- model event ---

-(NSString *)getUrlPrefix:(NSString *)path{
    if ([path hasPrefix:@"YKYun"] ) {
        return @"http://vipwobuka.xlxba.com/ckplayer/";
    }else if ([path hasPrefix:@"iQIYI"] ) {
        return @"http://vipwobuka.xlxba.com/ckplayer/";
    }else if ([path hasPrefix:@"Youku"] ) {
        return @"http://vipwobuka.xlxba.com/o0Oo0o/";
    }else if ([path hasPrefix:@"pptv.php"] ) {
        return @"https://vipwobuka.xlxba.com/o0Oo0o/";
    }else{
        return @"https://vipwobuka.xlxba.com/ckplayer/";
    }
}

-(void)urlToVideoUrl:(NSString *)urlString{
    [self.playerView resetPlayer];
    
    [self.webView removeFromSuperview];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth);
        make.height.mas_equalTo(ScreenWidth*9.0/16);
    }];

    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
  [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.3 Mobile/14E277 Safari/603.1.30" forHTTPHeaderField:@"User-Agent"];
    [self.webView loadRequest:request];
}

-(void)receivedVideoUrlString:(NSNotification *)notification{
    NSString *urlString=notification.object;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self player:urlString];
    });
}
-(void)player:(NSString *)videoUri{
    
    if (self.originPlayer) {
        return;
    }
    
    if ([self.dlnaButton.title hasSuffix:@"开"]&&self.renderer) {
        [self.renderer stop];
        [self.renderer setAVTransportURL:videoUri];
        [self.renderer play];
        return;
    }
    
    [self.view bringSubviewToFront:self.playerView];
    [self.webView removeFromSuperview];
    
    if (!self.playerModel) {
        
        ZFPlayerControlView *controlView=[[ZFPlayerControlView alloc]init];
        ZFPlayerModel *playerModel = [[ZFPlayerModel alloc]init];
        playerModel.fatherView = self.playerContentView;
        playerModel.videoURL =[NSURL URLWithString:videoUri];
        //    playerModel.title = @"";
        [self.playerView playerControlView:controlView playerModel:playerModel];
        [self.playerView playerModel:playerModel];
        self.playerModel=playerModel;
        [self.playerView autoPlayTheVideo];
    }else{
        self.playerModel.videoURL=[NSURL URLWithString:videoUri];
        [self.playerView resetToPlayNewVideo:self.playerModel];
    }
    
    
}

#pragma mark - --- view event ---

-(void)switchPlayer{
    self.originPlayer=!self.originPlayer;
    self.playerButton.title=self.originPlayer?@"播放器1":@"播放器2";
}

-(void)switchDLNA{
    if ([self.dlnaButton.title hasSuffix:@"关"]) {
        self.dlnaButton.title=@"TV 开";
    }else{
        self.dlnaButton.title=@"TV 关";
    }
}

-(void)reloadItemView{
    [self.itemsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block UIView *lastView;
    CGFloat width = (ScreenWidth - 50)/4;
    [self.data enumerateObjectsUsingBlock:^(VideoDetailItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont systemFontOfSize:13];
        button.layer.borderWidth=0.5f;
        button.tag=idx;
        [button addTarget:self action:@selector(switchVideoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemsView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (idx%4==0) {
                make.left.mas_equalTo(15);
                if (!lastView) {
                    make.top.mas_equalTo(15);
                }else{
                    make.top.equalTo(lastView.mas_bottom).offset(15);
                }
            }else{
                make.left.equalTo(lastView.mas_right).offset(10);
                make.top.equalTo(lastView);
            }
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(44);
        }];
        lastView=button;
    }];
    
    if (lastView) {
        [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15);
        }];
    }
}

-(void)switchVideoButton:(UIButton *)sender{
    [self.view bringSubviewToFront:self.wkWebView];
    [self switchVideo:sender.tag];
}

-(void)switchVideo:(NSInteger)idx{
    VideoDetailItem *item=self.data[idx];
    self.title=item.title;
    [self urlToVideoUrl:[NSString stringWithFormat:@"%@%@",[self getUrlPrefix:item.serverUri],item.serverUri]];
}

#pragma mark - --- delegate ---

- (void)upnpSearchChangeWithResults:(NSArray <CLUPnPDevice *>*)devices{
    for (CLUPnPDevice *device in devices) {
        
        if ([device.friendlyName hasPrefix:@"LED"]) {
            self.renderer=[[CLUPnPRenderer alloc]initWithModel:device];
            [self.server stop];
            
//            self.dlnaButton.title=device.friendlyName;
            return;
        }
    }
}

-(BOOL)webView:(UIWebView *)webView willSendRequest:(NSURLRequest *)request{
    if([request.URL.path.lowercaseString hasSuffix:@"m3u8"]||[request.URL.path.lowercaseString hasSuffix:@"mp4"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self player:request.URL.absoluteString];
        });
        return NO;
    }
    return YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([navigationAction.request.URL.host hasSuffix:@"baosmx.com"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *src= [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].src"];
        if (src.length) {
            [self player:src];
        }
    });
}

#pragma mark - --- observer ---

#pragma mark - --- private ---

#pragma mark - --- getter / setter ---

-(WKWebView *)wkWebView{
    if(_wkWebView)return _wkWebView;
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    WKPreferences *preferences = [WKPreferences new];
//    preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    preferences.minimumFontSize = 30.0;
    
    configuration.preferences = preferences;
    
    WKWebView *view=[[WKWebView alloc]initWithFrame:CGRectNull configuration:configuration];
    view.layer.borderWidth=0.5;
    view.navigationDelegate=self;
    
    _wkWebView=view;
    
    return _wkWebView;
}

-(EHRWebView *)webView{
    if(_webView)return _webView;

    EHRWebView *webView=[[EHRWebView alloc]init];
    webView.allowsLinkPreview=YES;
    webView.mediaPlaybackAllowsAirPlay=YES;
    webView.allowsInlineMediaPlayback=YES;
    webView.mediaPlaybackRequiresUserAction=NO;
    webView.delegate=self;
//    webView.enableLog=YES;
    webView.webViewDelegate=self;
    
    _webView=webView;

    return _webView;
}

@end

