//
//  SampleExecutor.m
//  HttpCommunication
//
//  Created by Tae Hyun, Na on 2015. 2. 20..
//  Copyright (c) 2015년 TeamP9. All rights reserved.
//
//  Licensed under the MIT license.

#import "SampleExecutor.h"
#import "HJAsyncHttpDeliverer.h"

@interface SampleExecutor (SampleExecutorPrivate)

- (HYResult *)resultForQuery:(id)anQuery;
- (BOOL)storeFailedResultWithQuery:(id)anQuery;

@end

@implementation SampleExecutor

- (NSString *)name
{
	return SampleExecutorName;
}

- (BOOL)calledExecutingWithQuery:(id)anQuery
{
	if( [[anQuery parameterForKey:SampleExecutorParameterKeyCloseQueryCall] boolValue] == YES ) {
		
        // prepare result
        HYResult *result = [self resultForQuery:anQuery];
        
        // check the result status of HJAsyncHttpDeliverer, and if not succeed, then store failed result.
        if( [[anQuery parameterForKey:HJAsyncHttpDelivererParameterKeyFailed] boolValue] == YES ) {
            return [self storeFailedResultWithQuery:anQuery];
        }
        
        // check received data from the result and preprocess it.
        // in this case, get NSMutableDictionary object by parsing JSON format.
        NSData *receivedData = [result parameterForKey:HJAsyncHttpDelivererParameterKeyBody];
        if( [receivedData length] == 0 ) {
            return [self storeFailedResultWithQuery:anQuery];
        }
        NSMutableDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:nil];
        if( resultDict == nil ) {
            return [self storeFailedResultWithQuery:anQuery];
        }
        
        // set wanted data to result for its key.
        [result setParameter:resultDict forKey:SampleExecutorParameterKeyResultDict];
		
		// stored result will notify by name 'SampleExecutorName'
		[self storeResult:result];
		
	} else {
		
		// check parameter
		id urlString = [anQuery parameterForKey:SampleExecutorParameterKeyUrlString];
		if( [urlString isKindOfClass:[NSString class]] == NO ) {
            return [self storeFailedResultWithQuery:anQuery];
		}
		
		// mark 'close query call' for distinguish query from 'HJAsyncHttpDeliverer'
		[anQuery setParameter:@"Y" forKey:SampleExecutorParameterKeyCloseQueryCall];
		
		// prepare HJAsyncHttpDeliverer object
        HJAsyncHttpDeliverer *asyncHttpDeliverer = [[HJAsyncHttpDeliverer alloc] initWithCloseQuery:anQuery];
        if( asyncHttpDeliverer == nil ) {
            return [self storeFailedResultWithQuery:anQuery];
        }
        // set trust host if you deal with server by HTTPS
        // and if you consider that support iOS 9 over then check 'NSAppTransportSecurity' key at Info.plist.
        // you can handle these information from some global values or parameters from query object, and so on. it's up to you.
        // in this case, just hard coding. :)
        [asyncHttpDeliverer setTrustedHosts:@[@"ec2-54-186-207-227.us-west-2.compute.amazonaws.com", @"www.p9soft.com"]];
        
        // read parameter values from query object.
        SampleExecutorOperation operaiton = (SampleExecutorOperation)[[anQuery parameterForKey:SampleExecutorParameterKeyOperation] integerValue];
        NSDictionary *requestDict = [anQuery parameterForKey:SampleExecutorParameterKeyRequestDict];
        NSString *filePath = [anQuery parameterForKey:SampleExecutorParameterKeyFilePath];
        NSString *formDataFieldName = [anQuery parameterForKey:SampleExecutorParameterKeyFormDataFieldName];
        NSString *fileName = [anQuery parameterForKey:SampleExecutorParameterKeyFileName];
        NSString *contentType = [anQuery parameterForKey:SampleExecutorParameterKeyContentType];
        
        // set HJAsyncHttpDeliverer for each case.
        switch( operaiton ) {
            case SampleExecutorOperationGet :
                [asyncHttpDeliverer setGetWithUrlString:(NSString *)urlString queryStringDict:requestDict];
                break;
            case SampleExecutorOperationPost :
                [asyncHttpDeliverer setPostWithUrlString:(NSString *)urlString formDataDict:requestDict contentType:HJAsyncHttpDelivererPostContentTypeUrlEncoded];
                break;
            case SampleExecutorOperationDownloadFile :
                [asyncHttpDeliverer setGetWithUrlString:(NSString *)urlString queryStringDict:requestDict toFilePath:filePath];
                break;
            case SampleExecutorOperationUploadFile :
                [asyncHttpDeliverer setPostUploadWithUrlString:(NSString *)urlString formDataField:formDataFieldName fileName:fileName fileContentType:contentType filePath:filePath];
                break;
            default :
                return [self storeFailedResultWithQuery:anQuery];
        }
        
		// bind it
		[self bindAsyncTask:asyncHttpDeliverer];
		
	}
	
	return YES;
}

- (HYResult *)resultForQuery:(id)anQuery
{
    HYResult *result = [HYResult resultWithName:self.name];
    [result setParametersFromDictionary:[anQuery paramDict]];
    
    return result;
}

- (BOOL)storeFailedResultWithQuery:(id)anQuery
{
    HYResult *result = [self resultForQuery:anQuery];
    if( result == nil ) {
        return NO;
    }
    [result setParameter:@"Y" forKey:SampleExecutorParameterKeyFailedFlag];
    [self storeResult:result];
    
    return YES;
}

@end