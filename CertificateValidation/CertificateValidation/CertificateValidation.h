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
+(void)generateKeyPair;
+(void)encryptWithPublicKey;
+(void)decryptWithPrivateKey;
+(void)signWithPrivateKey;
+(void)verifyWithPublicKey;
@end
