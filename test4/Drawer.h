//
//  Drawer.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphNode.h"
#import "GraphEdge.h"
#import "TreeNode.h"
#import <QuartzCore/QuartzCore.h>
#import "Model.h"//get rid of

@interface Drawer : NSObject

+ (void)drawNode:(UIView *)view node:(GraphNode *)node;
+ (void)drawEdge:(UIView *)view edge:(GraphEdge *)edge;
+ (void)selectNode:(UIView *)view node:(GraphNode *)node;

+ (void)drawNode:(UIView *)view point:(CGPoint)point node:(TreeNode *)node;
+ (void)drawnost:(UIView *)view point:(CGPoint)point node:(TreeNode *)node;

@end
