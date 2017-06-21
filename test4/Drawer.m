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
    //hz
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
    CGFloat wmax = 0;
    CGFloat hmax = 0;
    CGFloat wmin = view.frame.origin.x;
    CGFloat hmin = view.frame.origin.y;
    for (CALayer * v in [view.layer sublayers]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        wmax = MAX(fw, wmax);
        hmax = MAX(fh, hmax);
        wmin = MIN(v.frame.origin.x, wmin);
        hmin = MIN(v.frame.origin.y, hmin);
    }
    /*ploho
     для того чтобы при добавлении узла с краю экрана увеличивался scrollview
     */
    if (wmin < 0 || hmin <0) {
        if (wmin < 0 && hmin <0)
            [view setFrame:CGRectMake(0-wmin, 0-hmin, wmax-wmin, hmax-hmin)];
        else if (hmin < 0)
            [view setFrame:CGRectMake(wmin, 0-hmin, wmax, hmax-hmin)];
        else if (wmin < 0)
            [view setFrame:CGRectMake(0-wmin, hmin, wmax-wmin, hmax)];
    }
    else
        [view setFrame:CGRectMake(wmin, hmin, wmax, hmax)];
}

@end
