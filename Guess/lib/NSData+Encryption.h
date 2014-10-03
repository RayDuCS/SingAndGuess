//
//  NSData+Encryption.h
//  Guess
//
//  Created by Rui Du on 11/18/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)AES256Encrypt; // use default key
- (NSData *)AES256Decrypt; // use default key
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
