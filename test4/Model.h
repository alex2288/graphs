//
//  Model.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "GraphNode.h"
#import "GraphEdge.h"
#import "TreeNode.h"
#import "Drawer.h"
#import <UIKit/UIKit.h>

@interface Model : NSObject

typedef NS_ENUM (NSInteger, WorkMode) {
    GraphMode,
    TreeMode
};

typedef NS_ENUM (NSInteger, TreeDrawingStrategy) {
    Graph,
    CustomStrategy,
    ClassicStrategy
};

typedef NS_ENUM (NSInteger, Traversal) {
    BreadthFirstSearch,
    DepthFirstSearch
};

#pragma mark - Common

+ (void) readData;
+ (void) writeData;
+ (id) findNodeinPoint:(CGPoint)point InWorkmode:(WorkMode)mode;
+ (void) deleteNodeinPoint:(CGPoint)point InWorkmode:(WorkMode)mode;
+ (BOOL) checkDrawingAvailabilityinPoint:(CGPoint)endpoint UsingStrategy:(TreeDrawingStrategy) strategy;
+ (void) changeNode:(TreeNode *)node Valueto:(NSString *)newValue;
+ (void) showAlert:(NSString *)message WithTitle:(NSString *)title InWorkmode:(WorkMode)mode;
+ (void) deleteAllInWorkmode:(WorkMode)mode;
+ (BOOL) isTestEnabled;
+ (void) newNodeinPoints:(CGPoint)startpoint endpoint:(CGPoint)endpoint WithValue:(NSString *)value WithParent:(TreeNode *)parent UsingStrategy:(TreeDrawingStrategy)strategy;

+ (void) restoreGraphView;//wtf

#pragma mark - Graphs

+ (UIView *) initiateGraphMode: (CGPoint) coordinate scrollview:(UIScrollView *)scview viewController: (UIViewController *)viewController;//ploho

+ (BOOL) isEndPointForShortestPathSet;
+ (void) setEndPointForShortestPathTest:(CGPoint)point;

+ (void) getstartNodeinPoint: (CGPoint)startpoint;//ploho
+ (BOOL) getendNodeinPoint: (CGPoint)endpoint;//ploho
+ (BOOL) checkPointsNodeBelongance: (CGPoint)startpoint point:(CGPoint)endpoint;//ploho
+ (void) connectNodes;//so vtorogo raza rabotaet
+ (GraphEdge *) findEdgeBetweenNodes: (GraphNode *)node1 node2:(GraphNode *)node2;
+ (void) selectNodeinPoint: (CGPoint)point;
+ (void) showConnectedComponents;
+ (void) GraphDFS: (GraphNode *)node NeedsVisualisation:(BOOL)visualisation VisualisationColor:(UIColor *)color;
+ (void) startTraversalFromPoint: (CGPoint)point UsingTraversal:(Traversal)traversal;
+ (void) showShortestPathToNode: (GraphNode *)endNode;
+ (void) prepareForShortestPathSearchFromPoint: (CGPoint)point Alternate: (BOOL)alt;
+ (CAShapeLayer *) drawEdge: (CGPoint)from to:(CGPoint)to;

+ (void) shortestPathTestWrapperToPoint:(CGPoint)point;
+ (void) shortestPathTestinPoint:(CGPoint)point;
+ (void) showAlternatePath;
+ (BOOL) alternateEnabled;
+ (void) disableAlternate;

#pragma mark - Trees

+ (UIView *) initiateTreeMode: (UIScrollView *)scrollview viewcontroller:(UIViewController *)viewcontroller;//??
+ (void) setNewTreeNodeParentInPoint: (CGPoint) point;
+ (TreeNode *) getNewTreeNodeParent;
+ (void) redrawTreeUsingStrategy: (TreeDrawingStrategy)strategy;//ploho
+ (void) setTreeDrawingStrategy: (TreeDrawingStrategy)newstrategy;

/////////////////

+ (TreeDrawingStrategy) getTreeDrawingStrategy;

+ (void) add:(TreeNode *)node;//ploho
+ (BOOL) checkExistenceOfNode: (TreeNode *) node;//ploho

+ (TreeNode *) getTreeRoot;
+ (void) initTreeTraversingVariables;//fortraversal засунь сюда енум
+ (void) TreeDFS:(TreeNode *) node;
+ (void) TreeBFS:(TreeNode *) node;
+ (void) rollUpWrapperForNode: (TreeNode *) node UsingStrategy:(TreeDrawingStrategy)strategy;

+ (BOOL) traversalTestinPoint: (CGPoint)point;//traversal
+ (void) prepareForTraversingTest;//traversal

@end
