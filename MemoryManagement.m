//
//  MemoryManagement.m
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "MemoryManagement.h"

@implementation MemoryManagement

+(void) removeFilesInFolderWithName:(NSString*)folderName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path =[documentsDirectory stringByAppendingPathComponent:folderName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

+(id) getObjectFromMemoryInFolder:(NSString*)folderName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:folderName];
    
    NSData *dataObject = [NSData dataWithContentsOfFile:imagePath];
    NSLog(@"data to retrieve : %@", dataObject);
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:dataObject];
}

+(BOOL)saveObjectInMemory:(id)objectToStore toFolder:(NSString*)folderName{
    //transform "application" to a savable file
    NSData *dataToStore = [NSKeyedArchiver archivedDataWithRootObject:objectToStore];
    //save it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:folderName];
    
    if([dataToStore writeToFile:imagePath atomically:NO]){
        NSLog(@"datas well saved ! ");
        return YES;
    }else{
        NSLog(@"error saving file  ");
        return NO;
    }
}


@end