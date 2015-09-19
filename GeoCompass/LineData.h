//
//  LineData.h
//  GeoCompass
//
//  Created by 何嘉 on 15/9/17.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LineData : NSManagedObject

@property (nonatomic, retain) NSString * adrS;
@property (nonatomic, retain) NSNumber * hightErrorS;
@property (nonatomic, retain) NSNumber * hightS;
@property (nonatomic, retain) NSData * imageS;
@property (nonatomic, retain) NSNumber * latS;
@property (nonatomic, retain) NSNumber * locErrorS;
@property (nonatomic, retain) NSNumber * lonS;
@property (nonatomic, retain) NSNumber * magErrorS;
@property (nonatomic, retain) NSNumber * pitchS;
@property (nonatomic, retain) NSNumber * pluangS;
@property (nonatomic, retain) NSNumber * plusynS;
@property (nonatomic, retain) NSNumber * strikeS;
@property (nonatomic, retain) NSDate * timeS;

@end
