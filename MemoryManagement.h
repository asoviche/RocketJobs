//
//  MemoryManagement.h
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryManagement : NSObject


+(void) removeFilesInFolderWithName:(NSString*)folderName;
+(id) getObjectFromMemoryInFolder:(NSString*)folderName;
+(BOOL)saveObjectInMemory:(id)objectToStore toFolder:(NSString*)folderName;


@end
