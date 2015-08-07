//
//  CertificateValidation.m
//  Certificate_Authentication_Demo
//
//  Created by EmmyXiao on 15/8/5.
//  Copyright (c) 2015年 capgemini. All rights reserved.
//

#import "CertificateValidation.h"

#define publicKeyTag @"com.test.own.publickey"
#define privateKeyTag @"com.test.own.privatekey"

@implementation CertificateValidation
+(BOOL)verifyAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withURL:(NSURL *)url
{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;
//    OSStatus status = SecTrustEvaluate(trust, &result);
//    if (status != kSecTrustResultUnspecified) {
//        return NO;
//    }
//    NSURLAuthenticationMethodDefault
    CFIndex count = SecTrustGetCertificateCount(trust);
    if (count <= 0) {
        return NO;
    }
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(trust, 0);
    CFStringRef domain = SecCertificateCopySubjectSummary(certificate);
    CFDataRef data = SecCertificateCopyData(certificate);
    NSLog(@"%@",domain);
    return YES;
    
}


+(void)readLocalCertificate{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"server_certificate" ofType:@"der"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    SecCertificateRef certificate = SecCertificateCreateWithData(CFAllocatorGetDefault(), (__bridge_retained CFDataRef)data);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    OSStatus status = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (status != errSecSuccess) {
        NSLog(@"trust create fail.");
        return;
    }
    SecTrustResultType result;
    status = SecTrustEvaluate(trust, &result);
    if (status != errSecSuccess) {
        NSLog(@"trust evaluate fail.");
        return;
    }
    SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
    CFStringRef subjectSummary = SecCertificateCopySubjectSummary(certificate);
    
    CFRelease(certificate);
    CFRelease(policy);
    CFRelease(trust);
    CFRelease(publicKey);
    CFRelease(subjectSummary);
}

//generate key pair
+(void)generateKeyPair{
    
    NSMutableDictionary *publicKeyAttrs = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *privateKeyAttrs = [[NSMutableDictionary alloc] init];
    [publicKeyAttrs setObject:[publicKeyTag dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id<NSCopying>)(kSecAttrApplicationTag)];
    [privateKeyAttrs setObject:[privateKeyTag dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id<NSCopying>)(kSecAttrApplicationTag)];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:(__bridge id)(kSecAttrKeyTypeRSA) forKey:(__bridge id)kSecAttrKeyType];
    [parameters setObject:[NSNumber numberWithInt:1024] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [parameters setObject:publicKeyAttrs forKey:(__bridge id<NSCopying>)(kSecPublicKeyAttrs)];
    [parameters setObject:privateKeyAttrs forKey:(__bridge id<NSCopying>)(kSecPrivateKeyAttrs)];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)(parameters), &publicKey, &privateKey);
    
    if (status != errSecSuccess) {
        NSLog(@"key pair generate fail");
    }
}

//encrypt with public key

//decrypt with private key

//sign with private key

//verify with public key

@end
