//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelEmailValidator.h"
#import "FXModelUrlValidator.h"

@implementation FXModelEmailValidator
-(instancetype)init {
	if((self = [super init])) {
		_checkDNS = NO;
		_enableIDN = YES;
	}

	return  self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} is not a valid email address.");
}

-(NSError *)validateValue:(id)value {
	BOOL valid = NO;
	NSArray *parts;
	if(value && [value isKindOfClass:[NSString class]] && (parts = [self parseEmail:value])) {
		value = [parts componentsJoinedByString:@"."];

		if (_enableIDN)
			value = [FXModelUrlValidator encodeIDN:value];

		if(_checkDNS) {
			NSString *error = [self resolveDomain:value];
			if(error) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: @"{attribute} domain can't be resolved.",
											   @"Reason": error,
									   }];
			}
		}

		valid = YES;
	}

	return (valid ? nil : [NSError errorWithDomain:FXFormValidatorErrorDomain
							   code:0
						   userInfo:@{
								   NSLocalizedDescriptionKey: self.message,
						   }]);
}

-(NSString *)resolveDomain:(NSString *)domain {
	CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)domain);
	CFStreamError error;
	NSString *message;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat"
	if (hostRef) {
		if (!(CFHostStartInfoResolution(hostRef, kCFHostAddresses, &error))) {
			if (error.error != 0) {
				if (error.domain == kCFStreamErrorDomainPOSIX) {
					message = @"POSIX error domain";
				} else if (error.domain == kCFStreamErrorDomainMacOSStatus) {
					OSStatus macError = (OSStatus) error.error;
					message = [NSString stringWithFormat:@"OS error: %d", macError];
				} else if (error.domain == kCFStreamErrorDomainHTTP) {
					message = @"HTTP error domain";
				} else if (error.domain == kCFStreamErrorDomainMach) {
					message = @"Mach error domain";
				} else if (error.domain == kCFStreamErrorDomainNetDB) {
					message = @"NetDB error domain";
				} else if (error.domain == kCFStreamErrorDomainCustom) {
					message = @"Custom error domain";
				} else if (error.domain == kCFStreamErrorDomainSystemConfiguration) {
					message = @"System Configuration error domain";
				} else {
					message = [NSString stringWithFormat:@"Unknown error %d domain %d", error.error, error.domain];
				}
			}
		}

		CFRelease(hostRef);
	}
#pragma clang diagnostic pop

	return message;
}

///based on: http://simianzombie.com/posts/2012/05/01/email-address-validation-for-ios
-(NSArray *)parseEmail:(NSString *)candidate {
	unsigned int domainPartStart = 0;
	unsigned int commentDepth = 0;

	BOOL state_dot = NO;
	BOOL state_quoted = NO;
	BOOL state_escaped = NO;
	BOOL state_followingQuoteBlock = NO;
	BOOL state_domain = NO;

	for (unsigned int i = 0; i < candidate.length; ++i) {
		unichar character = [candidate characterAtIndex:i];

		if (!state_domain) {
			// Do not allow characters beyond the ASCII set in the username
			if (character > 126 && !(_enableIDN))
				return nil;

			// Do not allow NULL
			if (character == 0)
				return nil;

			// Do not allow LF
			if (character == 10)
				return nil;
		}

		// Do not allow more than 254 characters in the entire address
		if (i > 253)
			return nil;

		// The only characters that can follow a quote block are @ and period.
		if (state_followingQuoteBlock) {
			if (character != '@' && character != '.')
				return nil;

			state_followingQuoteBlock = NO;
		}

		switch (character) {
			case '@':
				// @ not allowed in the domain portion of the address
				if (state_domain) {
					return nil;
				} else if (state_quoted) {
					// Ignore @ signs when quoted
				} else if (state_dot) {
					// Dots are not allowed as the final character in the local part
					return nil;
				} else {
					// Swapping to the domain portion of the address
					state_domain = YES;
					domainPartStart = i + 1;

					// Do not allow more than 63 characters in the local part
					if (i > 64)
						return nil;
				}

				// No longer in dot/escape mode
				state_dot = NO;
				state_escaped = NO;
				break;

			case '(':
				// Comments only activate when not quoted or escaped
				if (!state_quoted && !state_escaped)
					++commentDepth;

				break;

			case ')':
				// Comments only activate when not quoted or escaped
				if (!state_quoted && !state_escaped) {
					if (commentDepth == 0)
						return nil;

					--commentDepth;
				}
				break;

			case '\\':

				// Backslash isn't allowed outside of quote/comment mode
				if (!state_quoted && commentDepth == 0)
					return nil;

				// Flip the escape bit to enter/exit escape mode
				state_escaped = !state_escaped;
				// No longer in dot mode
				state_dot = NO;
				break;

			case '"':
				// quote not allowed in the domain portion of the address outside of a comment
				if (state_domain && commentDepth == 0)
					return nil;

				if (!state_escaped) {
					// Quotes are only allowed at the start of the local part, after a dot or to close an existing quote part
					if (i == 0 || state_dot || state_quoted) {
						// Remember that we just left a quote block
						if (state_quoted)
							state_followingQuoteBlock = YES;

						// Flip the quote bit to enter/exit quote mode
						state_quoted = !state_quoted;
					} else
						return nil;
				}

				// No longer in dot/escape mode
				state_dot = NO;
				state_escaped = NO;
				break;

			case '.':
				// Dots are not allowed as the first character of the local part
				if (i == 0) {
					return nil;
				} else if (i == domainPartStart) {
					// Dots are not allowed as the first character of the domain part
					return nil;
				} else if (i == candidate.length - 1) {
					// Dots are not allowed as the last character of the domain part
					return nil;
				}

				if (!state_quoted) {
					if (state_dot) {
						// Cannot allow adjacent dots
						return nil;
					} else {
						// Entering dot mode
						state_dot = YES;
					}
				}

				// No longer in escape mode
				state_escaped = NO;
				break;
			case ' ':
			case ',':
			case '[':
			case ']':
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 11:
			case 13:
			case 15:
				// These characters can only appear when quoted
				if (!state_quoted)
					return nil;
			default:
				// No longer in dot/escape mode
				state_dot = NO;
				state_escaped = NO;

				// Do not allow characters outside of unicode, numerals, hyphens
				// and periods in the domain part.  We use letterCharacterSet
				// because we're supporting internationalised domain names.
				// We don't have to do anything special with the name; that's up
				// to the email client/server to handle.
				if (state_domain) {
					if (![[NSCharacterSet letterCharacterSet] characterIsMember:character] &&
							![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:character] &&
							character != '-') {

						return nil;
					}
				}

				break;
		}
	}

	// Do not allow unclosed comments
	if (commentDepth > 0)
		return nil;

	// If we didn't identify a local and a domain part the address isn't valid
	if (!state_domain)
		return nil;

	if (candidate.length == domainPartStart)
		return nil;

	if (domainPartStart == 1)
		return nil;

	// Validate domain name components
	NSArray *components = [[candidate substringFromIndex:domainPartStart] componentsSeparatedByString:@"."];
	for (NSString *item in components) {
		// We can't allow a hyphen as the first or last char in a domain name component
		if ([item characterAtIndex:0] == '-' || [item characterAtIndex:item.length - 1] == '-')
			return nil;

		// Items must not be longer than 63 chars
		if (item.length > 63)
			return nil;
	}

	return components;
}
@end