//
//  TreeNode.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "TreeNode.h"

@interface TreeNode ()

@end

NSString * const tnchildren = @"ch";
NSString * const tncoordinates1 = @"c1";
NSString * const tnpath = @"pt";

@implementation TreeNode

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.children forKey:tnchildren];
    [aCoder encodeCGPoint:self.coordinates1 forKey:tncoordinates1];
    [aCoder encodeObject:self.path forKey:tnpath];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _children = [coder decodeObjectForKey:tnchildren];
        _coordinates1 = [coder decodeCGPointForKey:tncoordinates1];
        _path = [coder decodeObjectForKey:tnpath];
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
    TreeNode * another = [[TreeNode alloc] initWithCoordinates:self.coordinates value:self.value];
    another.children = self.children;
    return another;
}

@end
