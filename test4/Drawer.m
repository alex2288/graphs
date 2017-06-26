//
//  Drawer.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "Drawer.h"

const CGFloat NodeSize = 100.0;
const CGFloat NodePadding = 20.0;

@implementation Drawer

+ (void)drawNode:(UIView *)view node:(GraphNode *)node {
    [node _layer];
    [node _label];
    node.layer.position = CGPointMake(node.coordinates.x, node.coordinates.y);
    node.label.string = node.value;
    [node.layer addSublayer:node.label];
    [view.layer addSublayer: node.layer];
    [self adjustView:view];
}

+ (void)drawEdge:(UIView *)view edge:(GraphEdge *)edge {
    UIBezierPath * path = [UIBezierPath new];
    [path moveToPoint:edge.node1.coordinates];
    [path addLineToPoint:CGPointMake(edge.node2.coordinates.x - 1.0, edge.node2.coordinates.y)];
    [path addLineToPoint:CGPointMake(edge.node2.coordinates.x + 1.0, edge.node2.coordinates.y)];
    [path closePath];
    CAShapeLayer * pathLayer = [edge _path];
    pathLayer.path = path.CGPath;
    pathLayer.fillColor = [UIColor blackColor].CGColor;
    
    UIBezierPath * path1 = [UIBezierPath new];
    [path1 moveToPoint:edge.node2.coordinates];
    [path1 addLineToPoint:CGPointMake(edge.node1.coordinates.x - 1.0, edge.node1.coordinates.y)];
    [path1 addLineToPoint:CGPointMake(edge.node1.coordinates.x + 1.0, edge.node1.coordinates.y)];
    [path1 closePath];
    CAShapeLayer * pathLayer1 = [CAShapeLayer new];
    pathLayer1.path = path1.CGPath;
    pathLayer1.fillColor = [UIColor blackColor].CGColor;
    [edge.path addSublayer:pathLayer1];
    [view.layer addSublayer:edge.path];
}

+ (void)selectNode:(UIView *)view node:(GraphNode *)node {
    [node _layer];
    [node _label];
    node.layer.position = CGPointMake(node.coordinates.x, node.coordinates.y);
    node.label.string = node.value;
    node.layer.borderWidth = 4.0;
    node.layer.borderColor = [UIColor blueColor].CGColor;
    node.layer.backgroundColor = [UIColor redColor].CGColor;
    [node.layer addSublayer:node.label];
    [view.layer addSublayer: node.layer];
}

#pragma mark - Trees

+ (void)drawNode:(UIView *)view point:(CGPoint)point node:(TreeNode *)node {
    [node _layer];
    [node _label];
    node.layer.position = CGPointMake(point.x, point.y);
    node.coordinates1 = CGPointMake(point.x, point.y);
    if (![Model checkExistenceOfNode:node])
        [Model add:node];
    node.label.string = node.value;
    [node.layer addSublayer:node.label];
    [view.layer addSublayer: node.layer];
    
    NSUInteger childrenCount = node.children.count;
    CGFloat xOffset = 0.0;
    if (childrenCount > 0) {
        xOffset = - (childrenCount * (NodeSize + NodePadding)/4);
    }
    for (TreeNode * subnode in node.children) {
        CGPoint newPoint = CGPointMake(point.x + xOffset, point.y + NodeSize + NodePadding);
        subnode.path = [Model drawEdge:CGPointMake(point.x, point.y + NodeSize / 2.0) to:newPoint];
        [view.layer addSublayer: subnode.path];
        xOffset += NodeSize + NodePadding;
        [self drawNode:view point:newPoint node:subnode];
    }
    [view.layer addSublayer: node.layer];
    [self adjustView:view];
}

+ (void)drawnost:(UIView *)view point:(CGPoint)point node:(TreeNode *)node {
    [node _layer];
    [node _label];
    node.layer.position = CGPointMake(point.x, point.y);
    if (![Model checkExistenceOfNode:node])
        [Model add:node];
    node.label.string = node.value;
    [node.layer addSublayer:node.label];
    for (TreeNode * subnode in node.children) {
        subnode.path = [Model drawEdge:point to:subnode.coordinates];
        [view.layer addSublayer: subnode.path];
        [self drawnost:view point:CGPointMake(subnode.coordinates.x, subnode.coordinates.y) node:subnode];
    }
    [view.layer addSublayer: node.layer];
    [self adjustView:view];
}

+ (void) adjustView: (UIView *)view {
    CGFloat wMax = 0;
    CGFloat hMax = 0;
    CGFloat wMin = view.frame.origin.x;
    CGFloat hMin = view.frame.origin.y;
    for (CALayer * currentView in [view.layer sublayers]) {
        float currentWMax = currentView.frame.origin.x + currentView.frame.size.width;
        float currentHMax = currentView.frame.origin.y + currentView.frame.size.height;
        wMax = MAX(currentWMax, wMax);
        hMax = MAX(currentHMax, hMax);
        wMin = MIN(currentView.frame.origin.x, wMin);
        hMin = MIN(currentView.frame.origin.y, hMin);
    }
    //Scrollview enhancement.
    if (wMin < 0 || hMin <0) {
        if (wMin < 0 && hMin <0)
            [view setFrame:CGRectMake(0-wMin, 0-hMin, wMax-wMin, hMax-hMin)];
        else if (hMin < 0)
            [view setFrame:CGRectMake(wMin, 0-hMin, wMax, hMax-hMin)];
        else if (wMin < 0)
            [view setFrame:CGRectMake(0-wMin, hMin, wMax-wMin, hMax)];
    }
    else
        [view setFrame:CGRectMake(wMin, hMin, wMax, hMax)];
}

@end
