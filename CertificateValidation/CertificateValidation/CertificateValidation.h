//
//  CertificateValidation.h
//  Certificate_Authentication_Demo
//
//  Created by EmmyXiao on 15/8/5.
//  Copyright (c) 2015年 capgemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CertificateValidation : NSObject
+(BOOL) verifyAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withURL:(NSURL *)url;

+(void)readLocalCertificate;
+(BOOL)generateKeyPairWithPublicKey:(SecKeyRef)publicKey privateKey:(SecKeyRef)privateKey;
+(void)encryptData:(NSData *)plainData publicKey:(SecKeyRef)publicKey;
+(void)decryptData:(NSData *)cipherData privateKey:(SecKeyRef)privateKey;

+(void)signData:(NSData *)plainData privateKey:(SecKeyRef)privateKey;
+(void)verifySignature:(NSData *)signature publicKey:(SecKeyRef)publicKey plainData:(NSData *)plainData;

@end
