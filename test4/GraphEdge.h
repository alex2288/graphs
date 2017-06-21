//
//  GraphEdge.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphNode.h"

@interface GraphEdge : NSObject <NSCoding>

@property CAShapeLayer * path;
@property GraphNode * node1;
@property GraphNode * node2;

- (CAShapeLayer *) _path;
- (id) initWithNodes: (GraphNode *)node1 node2:(GraphNode *)node2;

@end
