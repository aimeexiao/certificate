//
//  ViewController.m
//  CertificateValidation
//
//  Created by Emmy Xiao on 8/5/15.
//  Copyright (c) 2015 Emmy Xiao. All rights reserved.
//

#import "ViewController.h"
#import "CertificateValidation.h"

#define TEST_URL @"https://DWSRTB01GSHK:Pr0tectDWSRTB01GSHK@services.qualityassurance.mobile.hsbc.com:30001/app/EntityList-1.5.11-ios-test.xml"
#define TEST_URL_00 @"http://www.baidu.com"
#define TEST_URL_01 @"https://services.qualityassurance.mobile.hsbc.com:30001/app/EntityList-1.5.11-ios-test.xml"

@interface ViewController ()

@property (nonatomic, strong, nullable) NSData *receivedData;
@property (nonatomic, strong, nullable) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self createConnection];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createConnection{
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURL *url = [[NSURL alloc] initWithString:TEST_URL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
    
}

- (void)loadWebViewContent{
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    NSURL *url = [[NSURL alloc] initWithString:TEST_URL_01];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    WKNavigation *navigation = [self.webView loadRequest:request];
    
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
    NSLog(@"authentication.");
    
    [CertificateValidation verifyAuthenticationChallenge:challenge withURL:webView.URL];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"DWSRTB01GSHK" password:@"Pr0tectDWSRTB01GSHK" persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSLog(@"authentication.");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"DWSRTB01GSHK" password:@"Pr0tectDWSRTB01GSHK" persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSLog(@"task authentication.");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"DWSRTB01GSHK" password:@"Pr0tectDWSRTB01GSHK" persistence:NSURLCredentialPersistenceNone];

//    NSURLCredential *credential =[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    self.receivedData = data;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"complete.");
}

//Not Invoked.
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
//    NSLog(@"finish.");
//}
@end
