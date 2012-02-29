
#import <SenTestingKit/SenTestingKit.h>
#import "KSURLNormalization.h"
#import "KSURLNormalizationPrivate.h"


@interface TestKSURLNormalization : SenTestCase
@end


@implementation TestKSURLNormalization

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)test_ks_URLByNormalizingURL
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox/page.html;parameter1=arg1;parameter2=arg2?queryparm1=%aa%bb%cc%dd&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.KARELIA.com///sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"HTTPS://username:password@www.karelia.com:443/sandvox///default.htm;parameter1=arg1;parameter2=arg2?queryparm1=%11%22%33%44&queryparm2=queryarg2#anchor1"];
    NSURL *in4 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *in5 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=%aa%bb%cc%dd&queryparm2=queryarg2"];
    NSURL *in6 = [NSURL URLWithString:@"http://username:password@WWW.karelia.COM:8888/level1/level2/level3/../..//;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/page.html;parameter1=arg1;parameter2=arg2?queryparm1=%AA%BB%CC%DD&queryparm2=queryarg2"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can3 = [NSURL URLWithString:@"https://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=%11%22%33%44&queryparm2=queryarg2"];
    NSURL *can4 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can5 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=%AA%BB%CC%DD&queryparm2=queryarg2"];
    NSURL *can6 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];

    NSURL *out1 = [in1 ks_normalizedURL];
    NSURL *out2 = [in2 ks_normalizedURL];
    NSURL *out3 = [in3 ks_normalizedURL];
    NSURL *out4 = [in4 ks_normalizedURL];
    NSURL *out5 = [in5 ks_normalizedURL];
    NSURL *out6 = [in6 ks_normalizedURL];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    STAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
    STAssertTrue([[out6 absoluteString] isEqualToString:[can6 absoluteString]], @"out6 failed");
}


- (void)test_ks_ReplacementRangeOfURLPart
{
    NSURL *theWorks = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];

    NSRange rScheme          = [theWorks ks_replacementRangeOfURLPart:ks_URLPartScheme];
    NSRange rSchemePart      = [theWorks ks_replacementRangeOfURLPart:ks_URLPartSchemePart];
    NSRange rUserAndPassword = [theWorks ks_replacementRangeOfURLPart:ks_URLPartUserAndPassword];
    NSRange rHost            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartHost];
    NSRange rPort            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartPort];
    NSRange rPath            = [theWorks ks_replacementRangeOfURLPart:ks_URLPartPath];
    NSRange rParameterString = [theWorks ks_replacementRangeOfURLPart:ks_URLPartParameterString];
    NSRange rQuery           = [theWorks ks_replacementRangeOfURLPart:ks_URLPartQuery];
    NSRange rFragment        = [theWorks ks_replacementRangeOfURLPart:ks_URLPartFragment];
//                                                                                                    1         1         1         1         1         1
//0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5    
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSRange ckrScheme          = (NSRange){0,4};
    NSRange ckrSchemePart      = (NSRange){4,3};
    NSRange ckrUserAndPassword = (NSRange){7,18};
    NSRange ckrHost            = (NSRange){25,15};
    NSRange ckrPort            = (NSRange){40,5};
    NSRange ckrPath            = (NSRange){45,19};
    NSRange ckrParameterString = (NSRange){64,32};
    NSRange ckrQuery           = (NSRange){96,42};
    NSRange ckrFragment        = (NSRange){138,8};

    STAssertTrue(rScheme.location == ckrScheme.location && rScheme.length == ckrScheme.length, @"rScheme failed.");
    STAssertTrue(rSchemePart.location == ckrSchemePart.location && rSchemePart.length == ckrSchemePart.length, @"rSchemePart failed.");
    STAssertTrue(rUserAndPassword.location == ckrUserAndPassword.location && rUserAndPassword.length == ckrUserAndPassword.length, @"rUserAndPassword failed.");
    STAssertTrue(rHost.location == ckrHost.location && rHost.length == ckrHost.length, @"rHost failed.");
    STAssertTrue(rPort.location == ckrPort.location && rPort.length == ckrPort.length, @"rPort failed.");
    STAssertTrue(rPath.location == ckrPath.location && rPath.length == ckrPath.length, @"rPath failed.");
    STAssertTrue(rParameterString.location == ckrParameterString.location && rParameterString.length == ckrParameterString.length, @"rParameterString failed.");
    STAssertTrue(rQuery.location == ckrQuery.location && rQuery.length == ckrQuery.length, @"rQuery failed.");
    STAssertTrue(rFragment.location == ckrFragment.location && rFragment.length == ckrFragment.length, @"rFragment failed.");
}


- (void)test_ks_URLByLowercasingSchemeAndHost
{
    NSURL *in1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in2 = [NSURL URLWithString:@"HTTP://www.karelia.com/index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://WWW.KARELIA.COM/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"HTTP://WWW.KARELIA.COM/index.html"];
    NSURL *in5 = [NSURL URLWithString:@"HttP://wWW.KAReliA.cOM/index.html"];
    
    NSURL *canonical = [NSURL URLWithString:@"http://www.karelia.com/index.html"];

    STAssertTrue([[[in1 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in1 failed");
    STAssertTrue([[[in2 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in2 failed");
    STAssertTrue([[[in3 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in3 failed");
    STAssertTrue([[[in4 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in4 failed");
    STAssertTrue([[[in5 ks_URLByLowercasingSchemeAndHost] absoluteString] isEqualToString:[canonical absoluteString]], @"in5 failed");
}


- (void)test_ks_URLByUppercasingEscapes
{
    NSURL *in1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2bone%3dtwo/index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/%5bobjectivec%5d/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/index%aa%bb%cc/index.html"];
    NSURL *in5 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];
    NSURL *can1 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/folder%20one%2Bone%3Dtwo/index.html"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/%5Bobjectivec%5D/index.html"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];
    NSURL *can5 = [NSURL URLWithString:@"http://www.karelia.com/index%AA%BB%CC/index.html"];

    NSURL *out1 = [in1 ks_URLByUppercasingEscapes];
    NSURL *out2 = [in2 ks_URLByUppercasingEscapes];
    NSURL *out3 = [in3 ks_URLByUppercasingEscapes];
    NSURL *out4 = [in4 ks_URLByUppercasingEscapes];
    NSURL *out5 = [in5 ks_URLByUppercasingEscapes];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
    STAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out5 failed");
}


- (void)test_ks_URLByAddingTrailingSlashToDirectory
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/sandvox"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/folder1/folder2/folder3/folder4/folder5/folder6"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/sandvox/folder1/folder2/folder3/folder4/folder5/folder6/"];
    
    NSURL *out1 = [in1 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out2 = [in2 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out3 = [in3 ks_URLByAddingTrailingSlashToDirectory];
    NSURL *out4 = [in4 ks_URLByAddingTrailingSlashToDirectory];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
}


- (void)test_ks_URLByRemovingDefaultPort
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:80"];
    NSURL *in4 = [NSURL URLWithString:@"https://username:password@www.karelia.com:443/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://username:password@www.karelia.com"];
    NSURL *can4 = [NSURL URLWithString:@"https://username:password@www.karelia.com/sandvox;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    
    NSURL *out1 = [in1 ks_URLByRemovingDefaultPort];
    NSURL *out2 = [in2 ks_URLByRemovingDefaultPort];
    NSURL *out3 = [in3 ks_URLByRemovingDefaultPort];
    NSURL *out4 = [in4 ks_URLByRemovingDefaultPort];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
}


- (void)test_ks_URLByRemovingDotSegments
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/level3/../../level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/././level2/././level3/../.././././././level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/level1/././level2/././level3/../.././././././level2"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/level1/level2"];

    NSURL *out1 = [in1 ks_URLByRemovingDotSegments];
    NSURL *out2 = [in2 ks_URLByRemovingDotSegments];
    NSURL *out3 = [in3 ks_URLByRemovingDotSegments];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
}


- (void)test_ks_URLByRemovingDirectoryIndex
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    
    NSURL *out1 = [in1 ks_URLByRemovingDirectoryIndex];
    NSURL *out2 = [in2 ks_URLByRemovingDirectoryIndex];
    NSURL *out3 = [in3 ks_URLByRemovingDirectoryIndex];
    NSURL *out4 = [in4 ks_URLByRemovingDirectoryIndex];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out4 failed");
}


- (void)test_ks_URLByRemovingFragment
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *in4 = [NSURL URLWithString:@"http://www.karelia.com/index.html#anchor1"];
    NSURL *in5 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/sandvox/;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can4 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can5 = [NSURL URLWithString:@"http://www.karelia.com/default.aspx?queryparm1=queryarg1&queryparm2=queryarg2"];
    
    NSURL *out1 = [in1 ks_URLByRemovingFragment];
    NSURL *out2 = [in2 ks_URLByRemovingFragment];
    NSURL *out3 = [in3 ks_URLByRemovingFragment];
    NSURL *out4 = [in4 ks_URLByRemovingFragment];
    NSURL *out5 = [in5 ks_URLByRemovingFragment];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out1 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out1 failed");
    STAssertTrue([[out4 absoluteString] isEqualToString:[can4 absoluteString]], @"out1 failed");
    STAssertTrue([[out5 absoluteString] isEqualToString:[can5 absoluteString]], @"out1 failed");    
}


- (void)test_ks_URLByRemovingDuplicateSlashes
{
    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1//level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *in2 = [NSURL URLWithString:@"http://www.karelia.com/////////////index.html"];
    NSURL *in3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
    NSURL *can2 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    NSURL *can3 = [NSURL URLWithString:@"http://www.karelia.com/index.html"];
    
    NSURL *out1 = [in1 ks_URLByRemovingDuplicateSlashes];
    NSURL *out2 = [in2 ks_URLByRemovingDuplicateSlashes];
    NSURL *out3 = [in3 ks_URLByRemovingDuplicateSlashes];
    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");
}


//- (void)test_ks_URLByRemovingEmptyQuery
//{
//    NSURL *in1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
//    NSURL *in2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?#anchor1"];
//    NSURL *in3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?"];
//    NSURL *can1 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2?queryparm1=queryarg1&queryparm2=queryarg2#anchor1"];
//    NSURL *can2 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2#anchor1"];
//    NSURL *can3 = [NSURL URLWithString:@"http://username:password@www.karelia.com:8888/level1/level2/index.html;parameter1=arg1;parameter2=arg2"];
//    
//    NSURL *out1 = [in1 ks_URLByRemovingEmptyQuery];
//    NSURL *out2 = [in2 ks_URLByRemovingEmptyQuery];
//    NSURL *out3 = [in3 ks_URLByRemovingEmptyQuery];
//    STAssertTrue([[out1 absoluteString] isEqualToString:[can1 absoluteString]], @"out1 failed");
//    STAssertTrue([[out2 absoluteString] isEqualToString:[can2 absoluteString]], @"out2 failed");
//    STAssertTrue([[out3 absoluteString] isEqualToString:[can3 absoluteString]], @"out3 failed");    
//}









@end
