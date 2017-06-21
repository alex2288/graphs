//
//  GraphNode.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphNode : NSObject <NSCoding>

@property NSString * value;
@property NSInteger number;
@property CGPoint coordinates;
@property CALayer * layer;
@property UIColor * color1;
@property UIColor * color2;
@property CATextLayer * label;
@property BOOL visited;
@property BOOL visited2;

- (CALayer *) _layer;
- (CATextLayer *) _label;
- (id) initWithCoordinates: (CGPoint)coordinates value:(NSString *)value;

@end
