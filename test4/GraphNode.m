//
//  GraphNode.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "GraphNode.h"

NSString * const gnvalue = @"vl";
NSString * const gncoordinates = @"cd";
NSString * const gncolor = @"cr";
NSString * const gnlayer = @"ly";
NSString * const gnlabel = @"lb";

@implementation GraphNode

CGFloat const NodeSize15 = 100.0;

- (CALayer *) _layer {
    if (!self.layer) {
        self.layer = [[CALayer alloc] init];
        self.layer.frame = CGRectMake(0, 0, NodeSize15, NodeSize15);
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.cornerRadius = NodeSize15 / 2.0;
        self.color1 = [UIColor colorWithRed:0.3 + arc4random_uniform(255) / 255.0 green:0.3 + arc4random_uniform(255) / 255.0 blue:0.3 + arc4random_uniform(255) / 255.0 alpha:1.0];
        self.layer.backgroundColor = self.color1.CGColor;
    }
    return self.layer;
}
- (CATextLayer *) _label {
    if (!self.label) {
        self.label = [[CATextLayer alloc] init];
        [self.label setFrame:CGRectMake(0, NodeSize15/2-10, NodeSize15, NodeSize15)];
        [self.label setForegroundColor:[[UIColor blackColor] CGColor]];
        [self.label setFontSize:18.0];
        [self.label setAlignmentMode:kCAAlignmentCenter];
    }
    return self.label;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:gnvalue];
    [aCoder encodeCGPoint:self.coordinates forKey:gncoordinates];
    [aCoder encodeObject:self.color1 forKey:gncolor];
    [aCoder encodeObject:self.layer forKey:gnlayer];
    [aCoder encodeObject:self.label forKey:gnlabel];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.value = [coder decodeObjectForKey:gnvalue];
        self.coordinates = [coder decodeCGPointForKey:gncoordinates];
        self.color1 = [coder decodeObjectForKey:gncolor];
        self.layer = [coder decodeObjectForKey:gnlayer];
        self.label = [coder decodeObjectForKey:gnlabel];
    }
    return self;
}

- (id) initWithCoordinates: (CGPoint)coordinates value:(NSString *)value {
    self = [super init];
    if (self) {
        self.value = value;
        self.coordinates = coordinates;
    }
    return self;
}

- (id)copyWithZone: (NSZone *)zone {
    GraphNode * another = [[GraphNode alloc] initWithCoordinates:self.coordinates value:self.value];
    return another;
}

@end
