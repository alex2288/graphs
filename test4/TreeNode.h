//
//  TreeNode.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphNode.h"

@interface TreeNode : GraphNode

@property NSMutableArray * children;
@property CGPoint coordinates1;
@property CAShapeLayer * path;
- (id) initWithCoordinates: (CGPoint)coordinates value:(NSString *)value;
- (id) copyWithZone: (NSZone *)zone;
@end
