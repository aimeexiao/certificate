//
//  CertificateValidation.m
//  Certificate_Authentication_Demo
//
//  Created by EmmyXiao on 15/8/5.
//  Copyright (c) 2015年 capgemini. All rights reserved.
//

#import "CertificateValidation.h"
#import <Security/SecBase.h>

#define publicKeyTag @"com.test.own.publickey"
#define privateKeyTag @"com.test.own.privatekey"
#define CC_SHA256_DIGEST_LENGTH 256

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
+(BOOL)generateKeyPairWithPublicKey:(SecKeyRef)publicKey privateKey:(SecKeyRef)privateKey{
    
    NSMutableDictionary *publicKeyAttrs = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *privateKeyAttrs = [[NSMutableDictionary alloc] init];
    [publicKeyAttrs setObject:[publicKeyTag dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id<NSCopying>)(kSecAttrApplicationTag)];
    [privateKeyAttrs setObject:[privateKeyTag dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id<NSCopying>)(kSecAttrApplicationTag)];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:(__bridge id)(kSecAttrKeyTypeRSA) forKey:(__bridge id)kSecAttrKeyType];
    [parameters setObject:[NSNumber numberWithInt:1024] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [parameters setObject:publicKeyAttrs forKey:(__bridge id<NSCopying>)(kSecPublicKeyAttrs)];
    [parameters setObject:privateKeyAttrs forKey:(__bridge id<NSCopying>)(kSecPrivateKeyAttrs)];
    
//    SecKeyRef publicKey = NULL;
//    SecKeyRef privateKey = NULL;
    
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)(parameters), &publicKey, &privateKey);
    
    if (status != errSecSuccess) {
        NSLog(@"key pair generate fail");
        return NO;
    }
    NSLog(@"Public key: %@",privateKey);
    NSLog(@"Private key:%@",publicKey);
    return YES;
}

//encrypt with public key
+(void)encryptData:(NSData *)plainData publicKey:(SecKeyRef)publicKey
{
    const uint8_t *plainText = [plainData bytes];
    size_t plainTextLen = sizeof(plainText);
    if (plainTextLen > (SecKeyGetBlockSize(publicKey) - 11)) {
        NSLog(@"Could not encrypt. Data length is %zu.",plainTextLen);
    }
    uint8_t cipherText;
    size_t cipherTextLen;
    OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plainText, plainTextLen, &cipherText, &cipherTextLen);
    if (status != errSecSuccess) {
        NSLog(@"Data encrypt fail.");
    }
    NSLog(@"Encrypted data: %hhu",cipherText);
}


//decrypt with private key
+(void)decryptData:(NSData *)cipherData privateKey:(SecKeyRef)privateKey{
    const uint8_t *cipherText = [cipherData bytes];
    size_t cipherTextLen = sizeof(cipherText);
    uint8_t plainText;
    size_t plainTextLen;
    OSStatus status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, cipherText, cipherTextLen, &plainText, &plainTextLen);
    if (status != errSecSuccess) {
        NSLog(@"Data decrypt fail.");
    }
    NSLog(@"Decrypted data: %hhu",plainText);
}

//sign with private key
+(void)signData:(NSData *)plainData privateKey:(SecKeyRef)privateKey{
    const uint8_t *hashData;
    size_t hashDataLen = sizeof(hashData);
    uint8_t signature;
    size_t signatureLen;
    OSStatus status = SecKeyRawSign(privateKey, kSecPaddingPKCS1SHA256, hashData, hashDataLen, &signature, &signatureLen);
    if (status != errSecSuccess) {
        NSLog(@"Data sign fail.");

    }
    NSLog(@"Signature data: %hhu",signature);
}

//verify with public key
+(void)verifySignature:(NSData *)signature publicKey:(SecKeyRef)publicKey plainData:(NSData *)plainData{
//    SecKeyRef publicKey = [self getPublicKeyFromBase64String:public_key_verify_signature];
//    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
//    NSData* signature = [NSData dataFromBase64String:signatureString];
//    const void* signedHashBytes = [signature bytes];
//    
//    size_t hashBytesSize = kChosenDigestLength;
//    uint8_t* hashBytes = malloc(hashBytesSize);
//    NSData* generateData = [checkSumGenerateByPlainData dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* generateHashData = [HashUtility getSHA256Hash:generateData];
//    memcpy(hashBytes, [generateHashData UTF8String], [generateHashData length]+1);
//    
//    OSStatus status = SecKeyRawVerify(publicKey,
//                                      kSecPaddingPKCS1SHA256,
//                                      hashBytes,
//                                      hashBytesSize,
//                                      signedHashBytes,
//                                      signedHashBytesSize);
    
  
    
    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    uint8_t *signedData = malloc(signedHashBytesSize);
    memcpy(signedData, [plainData bytes], sizeof(signedData) + 1);
    
    size_t signedDataLen = sizeof(signedData);
    const uint8_t *sig = [signature bytes];
    size_t sigLen = sizeof(sig);
    OSStatus status = SecKeyRawVerify(publicKey, kSecPaddingPKCS1SHA256, signedData, signedDataLen, sig, sigLen);
    if (status != errSecSuccess) {
        NSLog(@"Signature verify fail.");
    }
}
@end
