//
//  SurfaceImage.h
//  GeoCompass
//
//  Created by 何嘉 on 15/9/20.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SurfaceImage : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSData * imageS;

@end
