//
//  GraphEdge.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "GraphEdge.h"

@implementation GraphEdge

NSString * const tnpath1  = @"pt";
NSString * const tnnode1 = @"n1";
NSString * const tnnode2 = @"n2";

- (CAShapeLayer *) _path {
    if (!_path) {
        _path = [[CAShapeLayer alloc] init];
    }
    return _path;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.path forKey:tnpath1];
    [aCoder encodeObject:self.node1 forKey:tnnode1];
    [aCoder encodeObject:self.node2 forKey:tnnode2];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _path =  [coder decodeObjectForKey:tnpath1];
        _node1 = [coder decodeObjectForKey:tnnode1];
        _node2 = [coder decodeObjectForKey:tnnode2];
    }
    return self;
}

- (id) initWithNodes: (GraphNode *)node1 node2:(GraphNode *)node2 {
    self = [super init];
    if (self) {
        _node1 = [GraphNode new];
        _node1 = node1;
        _node2 = [GraphNode new];
        _node2 = node2;
    }
    return self;
}

@end
