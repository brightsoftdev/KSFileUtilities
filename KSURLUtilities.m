//
//  KSURLUtilities.m
//
//  Copyright (c) 2007-2012 Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSURLUtilities.h"

#import "KSPathUtilities.h"


@implementation NSURL (KSPathUtilities)

#pragma mark Scheme

- (NSURL *)ks_URLWithScheme:(NSString *)newScheme;
{
    NSString *scheme = [self scheme];
    if (!scheme) return nil;

    // -resourceSpecifier is supposed to give me everything after the scheme's colon, but for file:///path URLs, it just returns /path. Work around by deducing when resource specifier truly starts. Also found CFURLCopyResourceSpecifier() returns NULL for such URLs, against its documentation
    NSString *string = [[NSString alloc] initWithFormat:
                        @"%@:%@",
                        newScheme,
                        [[self absoluteString] substringFromIndex:[scheme length] + 1]];    // should be safe since a colon was needed to know scheme
    
    NSURL *result = [[self class] URLWithString:string];
    [string release];
    return result;
}

#pragma mark Host

- (NSURL *)ks_hostURL;		// returns a URL like "http://launch.karelia.com/"
{
	NSURL *result = [[NSURL URLWithString:@"/" relativeToURL:self] absoluteURL];
    return result;
}


- (NSArray *)ks_domains;
{
    NSArray *result = [[self host] componentsSeparatedByString:@"."];
    return result;
}

- (BOOL)ks_hasNetworkLocation
{
	NSString *resourceSpecifier = [self resourceSpecifier];
	
	BOOL result = (resourceSpecifier != nil &&
				   [resourceSpecifier length] > 2 &&
				   [[self ks_domains] count] >= 2);
	
	return result;
}

#pragma mark Paths

/*	These two methods operate very similarly to -initWithString:relativeToURL:
 *	However, they assume the string is a path and ensure it has a trailing slash to match isDirectory.
 */

+ (NSURL *)ks_URLWithPath:(NSString *)path relativeToURL:(NSURL *)baseURL isDirectory:(BOOL)isDirectory
{
	NSParameterAssert(path);
    
    NSString *URLString = path;
	if ([path hasSuffix:@"/"] != isDirectory)
	{
		if (isDirectory)
		{
			URLString = [path stringByAppendingString:@"/"];
		}
		else
		{
			URLString = [path substringToIndex:([path length] - 1)];
		}
	}
	
	return [self URLWithString:URLString relativeToURL:baseURL];
}


/*  Getting a file:// URL from a path and then turning it into a string is pretty common for us.
 *  This is a simple method to make it faster.
 */
+ (NSString *)ks_fileURLStringWithPath:(NSString *)path;
{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:path];
    NSString *result = [URL absoluteString];
    [URL release];
    
    return result;
}


#if !(defined MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
// already defined in Snow Leopard

/*	The CFURL APIs expose a bunch more path functionality than NSURL. You could of course use
 *	toll-free bridging, but it's more hassle and less readable. So these methods are here
 *	to simplify that.
 */

- (NSString *)ks_lastPathComponent
{
	NSString *result = NSMakeCollectable(CFURLCopyLastPathComponent((CFURLRef)[self absoluteURL]));
	return [result autorelease];
}

- (NSString *)ks_pathExtension
{
	NSString *result = NSMakeCollectable(CFURLCopyPathExtension((CFURLRef)[self absoluteURL]));
	return [result autorelease];
}

- (NSURL *)ks_URLByAppendingPathExtension:(NSString *)pathExtension
{
	NSURL *result = NSMakeCollectable(CFURLCreateCopyAppendingPathExtension(NULL,
                                                                            (CFURLRef)self,
                                                                            (CFStringRef)pathExtension));
	return [result autorelease];
}

- (NSURL *)ks_URLByDeletingLastPathComponent
{
    NSURL *result = self;
    if ([[self path] length])   // #74010
    {
        result = NSMakeCollectable(CFURLCreateCopyDeletingLastPathComponent(NULL, (CFURLRef)self));
        [result autorelease];
    }
    
    return result;
}

- (NSURL *)ks_URLByDeletingPathExtension
{
	NSURL *result = NSMakeCollectable(CFURLCreateCopyDeletingPathExtension(NULL, (CFURLRef)self));
	return [result autorelease];
}

#endif

- (BOOL)ks_hasDirectoryPath
{
    BOOL result = CFURLHasDirectoryPath((CFURLRef)[self absoluteURL]);
    return result;
}

- (NSURL *)ks_URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory
{
    NSParameterAssert(pathComponent);
    
	NSURL *result = NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL,
                                                                            (CFURLRef)self,
                                                                            (CFStringRef)pathComponent,
                                                                            isDirectory));
	return [result autorelease];
}

/*  e.g. http://example.com/foo/bar.html is a subpath of http://example.com/foo/
 *  The URLs should have the same scheme and host. After that, path comparison is used
 */
- (BOOL)ks_isSubpathOfURL:(NSURL *)aURL;
{
    BOOL result = NO;
    
    
    // File URLs are treated specially to handle 'localhost' versus '///' and symlinks
    if ([self isFileURL] && [aURL isFileURL])
    {
        // Resolve aliases for local paths
        NSString *myPath = [[self path] stringByResolvingSymlinksInPath];
        NSString *otherPath = [[aURL path] stringByResolvingSymlinksInPath];
        
        result = [myPath ks_isSubpathOfPath:otherPath];
    }
    else
    {
        NSString *scheme = [self scheme];
        NSString *otherScheme = [aURL scheme];
        if (scheme && otherScheme && [scheme isEqualToString:otherScheme])
        {
            NSString *myHost = [self host];
            NSString *otherHost = [aURL host];
            if (myHost && otherHost && [myHost isEqualToString:otherHost])
            {
                NSString *myPath = [[self standardizedURL] path];
                NSString *otherPath = [[aURL standardizedURL] path];
                
                if (myPath && otherPath)
                {
                    result = [myPath ks_isSubpathOfPath:otherPath];
                }
            }
        }
    }
    
    return result;
}

#pragma mark RFC 1808

- (BOOL)ks_canBeDecomposed { return CFURLCanBeDecomposed((CFURLRef)self); }

#pragma mark Relative URLs

- (NSString *)ks_stringRelativeToURL:(NSURL *)URL
{
    
#define BAIL return [self absoluteString];
    
    // If the base URL is nil then no comparison is needed
	if (!URL) BAIL;
	
	
	// URLs not compliant with RFC 1808 cannot be interpreted
	if (![self ks_canBeDecomposed] || ![URL ks_canBeDecomposed]) BAIL;
	
	
	// If the scheme, host or port differs, there is no possible relative path. Schemes and domains are considered to be case-insensitive. http://en.wikipedia.org/wiki/URL_normalization
    NSString *myHost = [self host];
    if (!myHost) BAIL;
    
    NSString *otherHost = [URL host];
    if (!otherHost) BAIL;
    
    if ([myHost caseInsensitiveCompare:otherHost] != NSOrderedSame) BAIL;
    
    NSString *myScheme = [self scheme];
    if (!myScheme) BAIL;
    
    NSString *otherScheme = [URL scheme];
    if (!otherScheme) BAIL;
    
    if ([myScheme caseInsensitiveCompare:otherScheme] != NSOrderedSame) BAIL;
    
    NSNumber *myPort = [self port];
    NSNumber *aPort = [URL port];
    if (aPort != myPort && ![myPort isEqual:aPort]) // -isEqualToNumber: throws when passed nil
    {
        BAIL;
    }
	
	
	// OK, to figure out, need my path...
    CFURLRef absoluteSelf = CFURLCopyAbsoluteURL((CFURLRef)self);
    CFStringRef myPath = CFURLCopyPath((CFURLRef)absoluteSelf);
    
    if (!CFStringGetLength(myPath))     // e.g. http://example.com
    {
        CFRelease(myPath); myPath = CFRetain(CFSTR("/"));
    }
    
    
    // ... and the other path
    CFURLRef absoluteURL = CFURLCopyAbsoluteURL((CFURLRef)URL);
    CFStringRef dirPath = CFURLCopyPath(absoluteURL);
    
    if (!CFStringGetLength(dirPath))     
    {
        // e.g. http://example.com
        CFRelease(dirPath); dirPath = CFRetain(CFSTR("/"));
    }
    else if (!CFURLHasDirectoryPath(absoluteURL))   // faster than -ks_hasDirectoryPath
    {
        NSString *shortenedPath = [(NSString *)dirPath stringByDeletingLastPathComponent];
        CFRelease(dirPath); dirPath = CFRetain(shortenedPath);
    }
    
    CFRelease(absoluteURL);
    
    
    // Let -ks_pathRelativeToDirectory: do the heavy lifting
    NSString *result = [(NSString *)myPath ks_pathRelativeToDirectory:(NSString *)dirPath];
    
    // But here's an odd edge case, http://example.com/foo relative to http://example.com/foo/ should be '../foo' which -ks_pathRelativeToDirectory returns '.' from; perfectly fine for posix, but not us!
    if ([result isEqualToString:@"."])
    {
        if ([[(NSString *)myPath stringByAppendingString:@"/"] isEqualToString:(NSString *)dirPath])
        {
            result = [@"../" stringByAppendingString:[(NSString *)myPath lastPathComponent]];
        }
    }
    
    
    // Need trailing slash?
    if (CFURLHasDirectoryPath(absoluteSelf) && ![result hasSuffix:@"/"])
    {
        result = [result stringByAppendingString:@"/"];
    }
    
    
    // Time for a little cleanup
    CFRelease(dirPath);
    CFRelease(myPath);
    CFRelease(absoluteSelf);
    
    
    // Re-build any non-path information
	NSString *parameters = [self parameterString];
	if (parameters)
	{
		result = [result stringByAppendingFormat:@";%@", parameters];
	}
	
	NSString *query = [self query];
	if (query)
	{
		result = [result stringByAppendingFormat:@"?%@", query];
	}
	
	NSString *fragment = [self fragment];
	if (fragment)
	{
		result = [result stringByAppendingFormat:@"#%@", fragment];
	}
	
	
	// Finish up
	return result;
}

/*	Builds on -ks_stringRelativeToURL: by wrapping it into an NSURL object.
 */
- (NSURL *)ks_URLRelativeToURL:(NSURL *)URL;
{
	NSURL *result = nil;
	
	NSString *relativeString = [self ks_stringRelativeToURL:URL];
	if (relativeString)
	{
		result = [NSURL URLWithString:relativeString relativeToURL:URL];
	}
	
	return result;
}

#pragma mark Comparison

- (BOOL)ks_isEqualToURL:(NSURL *)otherURL;
{
    BOOL result = [self isEqual:otherURL];
    
   // For file: URLs the default check might have failed because they reference the host differently. If so, fall back to checking paths
    if (!result && [self isFileURL] && [otherURL isFileURL])
    {
        result = [[self path] isEqualToString:[otherURL path]];
    }
    
    return result;
}

- (BOOL)ks_isEqualExceptFragmentToURL:(NSURL *)anotherURL
{
	// cover case where both are nil
	return	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	&& 
	( ([self scheme] == [anotherURL scheme]) || [[self scheme] isEqual:[anotherURL scheme]] )
	&& 
	( ([self host] == [anotherURL host]) || [[self host] isEqual:[anotherURL host]] )
	&& 
	( ([self path] == [anotherURL path]) || [[self path] isEqual:[anotherURL path]] )
	&& 
	
	// query == parameterString?
    
	( ([self query] == [anotherURL query]) || [[self query] isEqual:[anotherURL query]] )
	&& 
	( ([self parameterString] == [anotherURL parameterString]) || [[self parameterString] isEqual:[anotherURL parameterString]] )
	&& 
	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	
	// less common pieces, but we gotta be careful
	&& 
	( ([self baseURL] == [anotherURL baseURL]) || [[self baseURL] isEqual:[anotherURL baseURL]] )
	&& 
	( ([self port] == [anotherURL port]) || [[self port] isEqual:[anotherURL port]] )
	&& 
	( ([self password] == [anotherURL password]) || [[self password] isEqual:[anotherURL password]] )
	&& 
	( ([self user] == [anotherURL user]) || [[self user] isEqual:[anotherURL user]] )
	;
	
}

@end


#pragma mark -


@implementation NSString (KSURLUtilities)

- (NSString *)ks_stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding
                             charactersToLeaveUnescaped:(NSString *)unescapedCharacters
                          legalURLCharactersToBeEscaped:(NSString *)legalCharactersToEscape;
{
    NSString *result = NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 (CFStringRef)unescapedCharacters,
                                                                                 (CFStringRef)legalCharactersToEscape,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
    
    return [result autorelease];
}

- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters
{
	// Add the percent escapes. If encodeSpacesAsPlusCharacters has been requested, then don't both escaping them
    NSString *charactersToLeaveUnescaped = (encodeSpacesAsPlusCharacters) ? @" " : @"";
    
    NSString *result = [self ks_stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
                                            charactersToLeaveUnescaped:charactersToLeaveUnescaped
                                         legalURLCharactersToBeEscaped:@"&+%="];
    
    
    // If the user requested it, replace spaces with + signs
    if (encodeSpacesAsPlusCharacters)
    {
        NSMutableString *mutableResult = [result mutableCopy];
        [mutableResult replaceOccurrencesOfString:@" "
                                       withString:@"+"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableResult length])];
        
        result = [mutableResult autorelease];
    }
    
    
    return result;
}

// For more fine grain escaping.... we want to escape dashes when URLs are in comments.
- (NSString *)ks_stringByAddingPercentEscapesWithSpacesAsPlusCharacters:(BOOL)encodeSpacesAsPlusCharacters escape:(NSString *)toEscape;
{
	// Add the percent escapes. If encodeSpacesAsPlusCharacters has been requested, then don't both escaping them
    NSString *charactersToLeaveUnescaped = (encodeSpacesAsPlusCharacters) ? @" " : @"";
    
    NSString *result = [self ks_stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
                                            charactersToLeaveUnescaped:charactersToLeaveUnescaped
                                         legalURLCharactersToBeEscaped:toEscape];
    
    
    // If the user requested it, replace sapces with + signs
    if (encodeSpacesAsPlusCharacters)
    {
        NSMutableString *mutableResult = [result mutableCopy];
        [mutableResult replaceOccurrencesOfString:@" "
                                       withString:@"+"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableResult length])];
        
        result = [mutableResult autorelease];
    }
    
    
    return result;
}

/*	Turns a given path into a directory path suitable for HTML.
 *
 *		e.g.	/photo_album	->	/photo_album/
 *	
 *	Empty strings are ignored
 */
- (NSString *)ks_URLDirectoryPath
{
	NSString *result = self;
	
	if (![self isEqualToString:@""] && ![self hasSuffix:@"/"])
	{
		result = [self stringByAppendingString:@"/"];
	}
	
	return result;
}

@end
