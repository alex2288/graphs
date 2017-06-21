//
//  Model.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "Model.h"

@implementation Model

static NSMutableArray * trees;
static int del = 0;
static int counter = 0;
static UIView * treeview;
static UIScrollView * scrview;
static UIViewController * tviewcontroller;
static BOOL treeVisualisation;
static TreeNode * parent;
static TreeDrawingStrategy strategy = CustomStrategy;

static UIView * graphview;
static UIViewController * gviewcontroller;
static UIScrollView * scrollview;
static NSMutableArray * nodes;
static NSMutableArray * edges;
static GraphNode * cnd;
static GraphNode * end;
static GraphNode * selected;
static GraphNode * selected_t;
static GraphNode * shortestPathStart = nil;
static GraphNode * shortestPathEnd = nil;
static BOOL inTest;

#pragma mark - Common

+ (void)readData {
    NSData * data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"nodes"];
    nodes = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    NSData * data2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"edges"];
    edges = [NSKeyedUnarchiver unarchiveObjectWithData:data2];
    NSData * data3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"trees"];
    trees = [NSKeyedUnarchiver unarchiveObjectWithData:data3];
    [self renameNodes];
}

+ (void)writeData {
    NSData * data1 = [NSKeyedArchiver archivedDataWithRootObject:nodes];
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:@"nodes"];
    NSData * data2 = [NSKeyedArchiver archivedDataWithRootObject:edges];
    [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:@"edges"];
    NSData * data3 = [NSKeyedArchiver archivedDataWithRootObject:trees];
    [[NSUserDefaults standardUserDefaults] setObject:data3 forKey:@"trees"];
}

+ (id) findNodeinPoint: (CGPoint)point InWorkmode:(WorkMode)mode {
    switch (mode) {
        case GraphMode:
            for (GraphNode * temp in nodes) {
                if (CGRectContainsPoint(temp.layer.frame, point)) {
                    return (TreeNode *)temp;
                }
            }
            break;
        case TreeMode:
            for (TreeNode * temp in trees) {
                if (CGRectContainsPoint(temp.layer.frame, point)) {
                    return temp;
                }
            }
            break;
    }
    return nil;
}

+ (void) deleteNodeinPoint: (CGPoint)point InWorkmode:(WorkMode)mode {
    TreeNode * temp = [self findNodeinPoint:point InWorkmode:mode];
    [temp.layer removeFromSuperlayer];
    if ([temp isMemberOfClass:[GraphNode class]]) {
        [self deleteEdgesConnectedWithNode:temp];
        [nodes removeObject:temp];
        //resize
    }
    else {
        //Finds node's parent children and rewrites them removing the node
        [self rollUpChildrenOfNode:temp UsingStrategy:CustomStrategy];//ploho
        for (TreeNode * parent in trees) {
            for (TreeNode * child in parent.children) {
                if (child == temp) {
                    NSMutableArray * newChildrenArray = [NSMutableArray new];
                    [newChildrenArray addObjectsFromArray:parent.children];
                    [newChildrenArray removeObject:temp];
                    parent.children = [[NSMutableArray alloc] initWithArray:newChildrenArray];
                    break;
                    }
                }
            }
            [self removeChildrenFromNode:temp];
            [trees removeObject:temp];
            [self redrawTreeUsingStrategy:strategy];
            scrview.contentSize = treeview.frame.size;
        }
    [self writeData];
}

#pragma mark - Graphs

+ (UIView *) initiateGraphMode: (CGPoint) coordinate scrollview:(UIScrollView *)scview viewController: (UIViewController *)viewController {
    graphview = [[UIView alloc] init];
    gviewcontroller = viewController;
    scrollview = scview;
    [self readData];
    if (!nodes || !edges) {
        nodes = [[NSMutableArray alloc] init];
        edges = [[NSMutableArray alloc] init];
    }
    if (nodes.count == 0) {
        GraphNode * root = [[GraphNode alloc] initWithCoordinates:coordinate value:@"root"];
        GraphNode * root1 = [[GraphNode alloc] initWithCoordinates:CGPointMake(100, 100) value:@"node"];
        GraphEdge * edge = [[GraphEdge alloc] initWithNodes:root node2:root1];
        edge.node1 = root;
        edge.node2 = root1;
        [nodes addObject:root];
        [nodes addObject:root1];
        [edges addObject:edge];
        [Drawer drawEdge:graphview edge:edge];
        [Drawer drawNode:graphview node:root];
        [Drawer drawNode:graphview node:root1];
    }
    else {
        for (GraphEdge * edge in edges) {
            [Drawer drawEdge:graphview edge:edge];
        }
        for (GraphNode * node in nodes) {
            [Drawer drawNode:graphview node:node];
        }
    }
    return graphview;
}

+ (void) newNodeinPoints:(CGPoint)startpoint endpoint:(CGPoint)endpoint WithValue:(NSString *)value WithParent:(TreeNode *)parent UsingStrategy:(TreeDrawingStrategy)strategy {
    if (strategy == Graph) {
        //ploho
        if (cnd != nil) {
            GraphNode * found = [self findNodeinPoint: startpoint InWorkmode:GraphMode];
            if (found != nil) {
                [found.layer removeFromSuperlayer];
                GraphNode * tempnode = [[GraphNode alloc] initWithCoordinates:endpoint value:value];
                GraphEdge * tempedge = [[GraphEdge alloc] initWithNodes:tempnode node2:found];
                [Drawer drawEdge:graphview edge:tempedge];
                [Drawer drawNode:graphview node:tempnode];
                [Drawer drawNode:graphview node:found];
                [nodes addObject:tempnode];
                [edges addObject:tempedge];
            }
        }
        else {
            GraphNode * temp = [[GraphNode alloc] initWithCoordinates:endpoint value:value];
            [Drawer drawNode: graphview node:temp];
            [nodes addObject:temp];
        }
    }
    else {
        TreeNode * newNode = [[TreeNode alloc] init];
        newNode.value = value;
        newNode.coordinates = endpoint;
        if (parent.children == nil) {
            parent.children = [NSMutableArray new];
        }
        [parent.children addObject:newNode];
        [Model rollUpWrapperForNode:[Model getTreeRoot] UsingStrategy:strategy];
        if(parent != [self getTreeRoot]) {
            [self redrawTreeUsingStrategy:strategy];
        }
    }
    [self writeData];
}

+ (void) getstartNodeinPoint: (CGPoint)startpoint {
    cnd = [self findNodeinPoint:startpoint InWorkmode:GraphMode];
}

+ (BOOL) getendNodeinPoint: (CGPoint)endpoint {
    end = [self findNodeinPoint:endpoint InWorkmode:GraphMode];
    //Yes, it has to be like this.
    return !(end == nil);
}

//ploho
+ (BOOL) checkPointsNodeBelongance: (CGPoint)startpoint point:(CGPoint)endpoint {
    return (CGRectContainsPoint(cnd.layer.frame, startpoint) && CGRectContainsPoint(cnd.layer.frame, endpoint));
}

+ (void) deleteEdgesConnectedWithNode: (GraphNode *)node {
    NSMutableArray * deletion = [NSMutableArray new];
    for (GraphEdge * edge in edges) {
        if (((edge.node1.coordinates.x == node.coordinates.x) && (edge.node1.coordinates.y == node.coordinates.y)) || ((edge.node2.coordinates.x == node.coordinates.x) && (edge.node2.coordinates.y == node.coordinates.y))) {
            [edge.path removeFromSuperlayer];
            [deletion addObject:edge];
        }
    }
    [edges removeObjectsInArray:deletion];
    [self writeData];
}

+ (void) connectNodes {
    GraphEdge * newEdge = [self findEdgeBetweenNodes:cnd node2:end];
    if (newEdge) {
        [newEdge.path removeFromSuperlayer];
        [edges removeObject:newEdge];
    }
    else {
        newEdge = [[GraphEdge alloc] initWithNodes:cnd node2:end];
        [cnd.layer removeFromSuperlayer];
        [end.layer removeFromSuperlayer];
        [Drawer drawEdge:graphview edge:newEdge];
        [Drawer drawNode:graphview node:cnd];
        [Drawer drawNode:graphview node:end];
        [edges addObject:newEdge];
    }
    [self writeData];
}

+ (BOOL) checkDrawingAvailabilityinPoint: (CGPoint)endpoint UsingStrategy:(TreeDrawingStrategy)strategy {
    switch (strategy) {
        case Graph:
            for (GraphNode * node in nodes) {
                double x = pow((endpoint.x - node.coordinates.x), 2);
                double y = pow((endpoint.y - node.coordinates.y), 2);
                double f = x + y;
                double d = pow(node.layer.frame.size.width * 1.25, 2);
                if (f < d)
                    return NO;
            }
            return YES;
        case ClassicStrategy:
            for (TreeNode * node in trees) {
                double x = pow((endpoint.x - node.coordinates1.x), 2);
                double y = pow((endpoint.y - node.coordinates1.y), 2);
                double f = x + y;
                double d = pow(node.layer.frame.size.width * 1.25, 2);
                if (f < d)
                    return NO;
            }
            return YES;
        case CustomStrategy:
            for (TreeNode * node in trees) {
                double x = pow((endpoint.x - node.coordinates.x), 2);
                double y = pow((endpoint.y - node.coordinates.y), 2);
                double f = x + y;
                double d = pow(node.layer.frame.size.width * 1.25, 2);
                if (f < d)
                    return NO;
            }
            return YES;
    }
    return NO;
}

+ (void) changeNode:(TreeNode *)temp Valueto:(NSString *)newValue {
    if ([temp isMemberOfClass:[GraphNode class]]) {
        for (GraphNode * node in nodes) {
            if (node == cnd) {
                node.label.string = newValue;
                node.value = newValue;
                [node.layer replaceSublayer:node.label with:node.label];
                break;
            }
        }
    }
    else {
        for (TreeNode * node in trees) {
            if (node == temp) {
                node.label.string = newValue;
                node.value = newValue;
                [node.layer replaceSublayer:node.label with:node.label];
                break;
                }
            }
    }
    [self writeData];
}

+ (GraphEdge *) findEdgeBetweenNodes: (GraphNode *)node1 node2:(GraphNode *)node2 {
    for (GraphEdge * edge in edges) {
        if ((edge.node1.coordinates.x == node1.coordinates.x && edge.node1.coordinates.y == node1.coordinates.y) || (edge.node1.coordinates.x == node2.coordinates.x && edge.node1.coordinates.y == node2.coordinates.y)) {
            if ((edge.node2.coordinates.x == node1.coordinates.x && edge.node2.coordinates.y == node1.coordinates.y) || (edge.node2.coordinates.x == node2.coordinates.x && edge.node2.coordinates.y == node2.coordinates.y))
                return edge;
        }
    }
    return nil;
}

+ (void) selectNodeinPoint: (CGPoint)point {
    if (shortestPathStart) {
        if (!alternate) {
            [self setEndPointForShortestPathTest:point];
            [self showShortestPathToNode:shortestPathEnd];
        }
        else {
            [self disableAlternate];
            alternate = NO;
            shortestPathStart = nil;
            shortestPathEnd = nil;
        }
    }
    else {
        if (selected) {
            cnd = selected;
            GraphNode * endNode = [self findNodeinPoint:point InWorkmode:GraphMode];
            if (endNode) {
                end = endNode;
                [self connectNodes];
            }
            else {
                if ([self checkDrawingAvailabilityinPoint:point UsingStrategy:Graph]) {
                    //[self newNodeinPoints:selected.coordinates endpoint:point scroll:scrollview];
                }
                else {
                    [self showAlert:@"You can't place nodes here." WithTitle:@"Error" InWorkmode:GraphMode];
                }
            }
            [selected_t.layer removeFromSuperlayer];
            selected_t = nil;
            [graphview.layer addSublayer:selected.layer];
            selected = nil;
        }
        else {
            selected = [self findNodeinPoint:point InWorkmode:GraphMode];
            selected_t = [selected copy];
            [selected.layer removeFromSuperlayer];
            [Drawer selectNode:graphview node:selected_t];
        }
    }
}

+ (void)showAlert: (NSString *)message WithTitle:(NSString *)title InWorkmode:(WorkMode)mode {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self restoreGraphView];
        [self redrawTreeUsingStrategy:strategy];
        [alert dismissViewControllerAnimated:YES completion:nil];}];
    [alert addAction:cancelaction];
    switch (mode) {
        case GraphMode:
            [gviewcontroller presentViewController:alert animated:YES completion:nil];
            break;
        case TreeMode:
            [tviewcontroller presentViewController:alert animated:YES completion:nil];
            break;
    }
}

+ (void) deleteAllInWorkmode:(WorkMode)mode {
    switch (mode) {
        case GraphMode:
            [[graphview.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            [nodes removeAllObjects];
            [edges removeAllObjects];
            [graphview setFrame:[UIScreen mainScreen].bounds];
            scrollview.contentSize = graphview.frame.size;
            scrollview.zoomScale = 1;
            break;
        case TreeMode:
            [self rollUpChildrenOfNode:[self getTreeRoot] UsingStrategy:CustomStrategy];
            trees = [NSMutableArray arrayWithObject:[self getTreeRoot]];
            [self getTreeRoot].children = nil;
            [self redrawTreeUsingStrategy:CustomStrategy];
            scrview.contentSize = treeview.frame.size;
            break;
    }
    [self writeData];
}

+ (NSMutableArray *) getNodesConnectedWith: (GraphNode *) node {
    NSMutableArray * connections = [NSMutableArray new];
    for (GraphEdge * edge in edges) {
        if (edge.node1.coordinates.x == node.coordinates.x && edge.node1.coordinates.y == node.coordinates.y)
            for (GraphNode * nd in nodes) {
                if (nd.coordinates.x == edge.node2.coordinates.x && nd.coordinates.y == edge.node2.coordinates.y)
                    [connections addObject:nd];
            }
        else if (edge.node2.coordinates.x == node.coordinates.x && edge.node2.coordinates.y == node.coordinates.y)
            for (GraphNode * nd in nodes) {
                if (nd.coordinates.x == edge.node1.coordinates.x && nd.coordinates.y == edge.node1.coordinates.y)
                    [connections addObject:nd];
            }
    }
    return connections;
}

+ (void) GraphDFS: (GraphNode *)node NeedsVisualisation:(BOOL)visualisation VisualisationColor:(UIColor *)color {
    if (visualisation) {
        counter++;
        node.label.string = [NSString stringWithFormat:@"%i", counter];
    }
    if (color) {
        node.color2 = color;
        node.layer.backgroundColor = node.color2.CGColor;
    }
    node.visited = YES;
    NSMutableArray * connections = [self getNodesConnectedWith:node];
    for (GraphNode * next in connections) {
        if (!next.visited)
            [self GraphDFS:next NeedsVisualisation:visualisation VisualisationColor:color];
    }
}

+ (void) showConnectedComponents {
    [self initGraphTraversingVariables];
    while ([self findUnvisitedNodes]) {
        [self GraphDFS:[self findUnvisitedNodes] NeedsVisualisation:NO VisualisationColor:[UIColor colorWithRed:0.3 + arc4random_uniform(255) / 255.0 green:0.3 + arc4random_uniform(255) / 255.0 blue:0.3 + arc4random_uniform(255) / 255.0 alpha:1.0]];
    }
}

+ (void) initGraphTraversingVariables {
    counter = 1;
    for (GraphNode * node in nodes) {
        node.visited = NO;
    }
}

+ (GraphNode *) findUnvisitedNodes {
    for (GraphNode * node in nodes) {
        if (!node.visited) {
            return node;
        }
    }
    return nil;
}

+ (void) startTraversalFromPoint: (CGPoint)point UsingTraversal:(Traversal)traversal {
    [self initGraphTraversingVariables];
    switch (traversal) {
        case DepthFirstSearch:
            [self GraphDFS:[self findNodeinPoint:point InWorkmode:GraphMode] NeedsVisualisation:YES VisualisationColor:nil];
            break;
        case BreadthFirstSearch:
            [self GraphBFS:[self findNodeinPoint:point InWorkmode:GraphMode] NeedsVisualisation:YES];
            break;
    }
}

+ (void) restoreGraphView {
    for (GraphNode * node in nodes) {
        node.layer.backgroundColor = node.color1.CGColor;
        node.label.string = node.value;
    }
    for (TreeNode * node in trees) {
        node.layer.backgroundColor = node.color1.CGColor;
        node.label.string = node.value;
    }
}

+ (void) GraphBFS: (GraphNode *)node NeedsVisualisation:(BOOL)visualisation {
    if (visualisation) {
        node.label.string = [NSString stringWithFormat:@"%i", counter];
        node.visited = YES;
        [self BFS:[self getNodesConnectedWith:node] NeedsVisualisation:visualisation];
    }
    else {
        node.number = counter;
        node.visited = YES;
        [self BFS:[self getNodesConnectedWith:node] NeedsVisualisation:visualisation];
    }
}

+ (void) BFS:(NSMutableArray *)input NeedsVisualisation:(BOOL)visualisation {
    if (input.count > 0) {
        if (shortestPathStart)
            counter++;
        NSMutableArray * output = [NSMutableArray new];
        for (GraphNode * node in input) {
            if (!node.visited) {
                if (!shortestPathStart)
                    counter++;
                if (visualisation)
                    node.label.string = [NSString stringWithFormat:@"%i", counter];
                else
                    node.number = counter;
            }
            node.visited = YES;
            NSMutableArray * children = [self getNodesConnectedWith:node];
            NSMutableArray * visited = [NSMutableArray new];
            for (GraphNode * temp in children) {
                if (temp.visited) {
                    [visited addObject:temp];
                }
            }
            [children removeObjectsInArray:visited];
            [output addObjectsFromArray:children];
        }
        [self BFS:output NeedsVisualisation:visualisation];
    }
}

+ (void) showShortestPathToNode: (GraphNode *)endNode {
    enableAlternate = YES;
    if (!alternate) {
        endNode.number = 0;
        [self initGraphTraversingVariables];
    }
    [self GraphBFS:shortestPathStart NeedsVisualisation:NO];
    BOOL alternativeFound = NO;
    if (endNode.number!=0) { //Checks if nodes are connected.
        NSArray * connections;
        for (NSInteger i = endNode.number; i > 0; i--) {
            endNode.layer.backgroundColor = [UIColor redColor].CGColor;
            endNode.label.string = [NSString stringWithFormat:@"%li", (long)endNode.number];
            connections = [self getNodesConnectedWith:endNode];
            BOOL done = NO;
            for (GraphNode * node in connections) {
                if (node.coordinates.x == shortestPathStart.coordinates.x && node.coordinates.y == shortestPathStart.coordinates.y) {
                    //Checks if node is connected with the last node.
                    node.layer.backgroundColor = [UIColor redColor].CGColor;
                    node.label.string = [NSString stringWithFormat:@"%li", (long)node.number];
                    done = YES;
                    break;
                }
            }
            if (!done) {
                i--;
                if (alternate) {
                    BOOL currentAlternative = NO;
                    for (GraphNode * node in connections) {
                        if (node.number == i && !node.visited2) {
                            node.visited2 = YES;
                            alternativeFound = YES;
                            currentAlternative = YES;
                            endNode = node;
                            break;
                        }
                    }
                    if (!currentAlternative) {
                        for (GraphNode * node in connections) {
                            if (node.number == i) {
                                node.visited2 = YES;
                                endNode = node;
                                break;
                            }
                        }
                    }
                }
                else {
                    for (GraphNode * node in connections) {
                        if (node.number == i) {
                            node.visited2 = YES;
                            endNode = node;
                            break;
                        }
                    }
                }
                i++; //Don't ask.
            }
        }
        shortestPathStart.layer.backgroundColor = [UIColor redColor].CGColor;
        shortestPathStart.label.string = [NSString stringWithFormat:@"%i", 1];
        if (alternate) {
            if (!alternativeFound) {
                [self restoreGraphView];
                shortestPathEnd = nil;
                shortestPathStart = nil;
                enableAlternate = NO;
                [self showAlert:@"Alternate path not found!" WithTitle:@"Error" InWorkmode:GraphMode];
            }
        }
    }
    else {
        [self showAlert:@"Nodes are not connected!" WithTitle:@"Error" InWorkmode:GraphMode];
    }
    //shortestPathStart = nil;
}

BOOL enableAlternate = NO;
BOOL alternate = NO;

+ (BOOL) alternateEnabled {
    return enableAlternate;
}

+ (void) disableAlternate {
    ////ploho?
    ///shortestPathEnd = nil;
    //shortestPathStart = nil;
    enableAlternate  = NO;
}

+ (void) prepareForShortestPathSearchFromPoint: (CGPoint)point Alternate: (BOOL)alt {
    shortestPathStart = [self findNodeinPoint:point InWorkmode:GraphMode];
    alternate = alt;
}

+ (void) shortestPathTestWrapperToPoint:(CGPoint)point {
    shortestPathEnd = nil;
    shortestPathStart = [self findNodeinPoint:point InWorkmode:GraphMode];
    [self initGraphTraversingVariables];
    [self GraphBFS:shortestPathStart NeedsVisualisation:NO];
    counter = 0;
    inTest = YES;
}

+ (BOOL) isTestEnabled {
    return inTest;
}

+ (BOOL) isEndPointForShortestPathSet {
    return shortestPathEnd != nil;
}

+ (void) setEndPointForShortestPathTest:(CGPoint)point {
    shortestPathEnd = [self findNodeinPoint:point InWorkmode:GraphMode];
}

+ (void) shortestPathTestinPoint:(CGPoint)point {
    GraphNode * node = [self findNodeinPoint:point InWorkmode:GraphMode];
    if (node) {
        counter ++;
        if (counter != node.number) {
            inTest = NO;
            [self showAlert:@"Wrong node!" WithTitle:@"Error" InWorkmode:GraphMode];
            shortestPathStart = nil;
            shortestPathEnd = nil;
            node.label.string = @"WRONG";
            node.layer.backgroundColor = [UIColor redColor].CGColor;

        }
        else {
            node.label.string = [NSString stringWithFormat:@"%i", counter];
            node.layer.backgroundColor = [UIColor redColor].CGColor;
        }
    }
    if ((node.coordinates.x == shortestPathEnd.coordinates.x && shortestPathEnd.coordinates.y == node.coordinates.y)  && counter == node.number) {
        inTest = NO;
        [self showAlert:@"Correct short path!" WithTitle:@"Success" InWorkmode:GraphMode];
        //[self restoreGraphView];
        shortestPathEnd = nil;
        shortestPathStart = nil;
    }
}

+ (void) showAlternatePath {
    alternate = YES;
    [self showShortestPathToNode:shortestPathEnd];
}

#pragma mark - Trees

//add settings bundle
//неправильно работает бфс, нода не удаляется из классик вью, нет бфс теста, по нажатию ок при вронг ноде нет перерисовки дерева, неправильно работает дфс тест?
+ (UIView *) initiateTreeMode: (UIScrollView *)scrollView viewcontroller: (UIViewController *)viewController {
    tviewcontroller = viewController;
    treeview = [UIView new];
    scrview = scrollView;
    trees = [NSMutableArray new];
    [self readData];
    if (trees.count == 0) {
        trees = [NSMutableArray new];
        TreeNode * root = [[TreeNode alloc] initWithCoordinates:CGPointMake(200, 100) value:@"root"];
        [trees addObject:root];
    }
    [Drawer drawnost:treeview point:[self getTreeRoot].coordinates node:trees[0]];
    scrview.contentSize = treeview.frame.size;
    return treeview;
}

+ (BOOL) checkExistenceOfNode: (TreeNode *) node {
    return [trees containsObject:node];
}

+ (CAShapeLayer *) drawEdge: (CGPoint) from to:(CGPoint) to {
    UIBezierPath * path = [UIBezierPath new];
    [path moveToPoint:from];
    [path addLineToPoint:CGPointMake(to.x - 1.0, to.y)];
    [path addLineToPoint:CGPointMake(to.x + 1.0, to.y)];
    [path closePath];
    CAShapeLayer * pathLayer = [CAShapeLayer new];
    pathLayer.path = path.CGPath;
    pathLayer.fillColor = [UIColor blackColor].CGColor;
    return pathLayer;
}

+ (void) removeChildrenFromNode: (TreeNode *) node {
    if (node.children.count != 0) {
        for (TreeNode * child in node.children) {
            [self removeChildrenFromNode:child];
            [trees removeObject:child];
        }
    }
}

+ (TreeNode *) getTreeRoot {
    return [trees firstObject];
}

+ (void) initTreeTraversingVariables {
    counter = 0;
    del = 0;
    treeVisualisation = YES;
    ntb = [NSMutableArray new];
    [ntb addObject:[self getTreeRoot]];
    
}

+ (void) prepareForTraversingTest {
    [self initTreeTraversingVariables];
    treeVisualisation = NO;
    counter = 0;
    for (TreeNode * node in trees) {
        node.number = 0;
    }
}

////////
NSMutableArray * ntb;

+ (void) TreeBFS:(TreeNode *) node {
    if (treeVisualisation)
        node.label.string = [NSString stringWithFormat:@"%u", [ntb indexOfObject:node]+1];
    else
        node.number = [ntb indexOfObject:node]+1;
    for (TreeNode * child in node.children)
        [ntb addObject:child];
    if (ntb.count != [ntb indexOfObject:node]+1)
        [self TreeBFS:ntb [[ntb indexOfObject:node]+1]];
}

+ (void) TreeDFS:(TreeNode *) node {
    ++del;
    if (treeVisualisation)
        node.label.string = [NSString stringWithFormat:@"%i", del];
    else node.number = del;
    for (TreeNode * child in node.children) {
        [self TreeDFS:child];
    }
}

+ (void) rollUpWrapperForNode: (TreeNode *) node UsingStrategy:(TreeDrawingStrategy)strategy {
    for (TreeNode * child in node.children) {
        if (child.layer.superlayer == nil) {
            [self redrawTreeUsingStrategy:strategy];
            break;
        }
        else {
            [self rollUpChildrenOfNode:child UsingStrategy:strategy];
            }
    }
    scrview.contentSize = treeview.frame.size;
}

+ (void) rollUpChildrenOfNode: (TreeNode *) node UsingStrategy:(TreeDrawingStrategy)strategy {
    if (node.children.count != 0) {
        for (TreeNode * child in node.children) {
            [self rollUpChildrenOfNode:child UsingStrategy:strategy];
            [child.layer removeFromSuperlayer];
            [child.path removeFromSuperlayer];
        }
        [node.layer removeFromSuperlayer];
        [node.path removeFromSuperlayer];
    }
    else {
        [node.layer removeFromSuperlayer];
        [node.path removeFromSuperlayer];
    }
}

+ (void) redrawTreeUsingStrategy: (TreeDrawingStrategy)strategy {
    [self rollUpChildrenOfNode:[self getTreeRoot] UsingStrategy:strategy];
    [[self getTreeRoot].layer removeFromSuperlayer];
    switch (strategy) {
        case ClassicStrategy:
            [Drawer drawNode:treeview point:CGPointMake([self getTreeRoot].coordinates1.x, [self getTreeRoot].coordinates1.y) node:[self getTreeRoot]];
            break;
        case Graph:
            break;
        case CustomStrategy:
            [Drawer drawnost:treeview point:[self getTreeRoot].coordinates node:[self getTreeRoot]];
            break;
    }
    scrview.contentSize = treeview.frame.size;
}

+ (void) add:(TreeNode *)node {
    [trees addObject:node];
}

+ (BOOL) traversalTestinPoint: (CGPoint)point {
    TreeNode * node = (TreeNode *)[self findNodeinPoint:point InWorkmode:TreeMode];
    if (node) {
        counter++;
        node.label.string = [NSString stringWithFormat:@"%i", counter];
        node.layer.backgroundColor = [UIColor redColor].CGColor;
        if (counter != node.number) {
            [self showAlert:@"Wrong node!" WithTitle:@"Error" InWorkmode:TreeMode];
            node.label.string = @"WRONG";
            node.layer.backgroundColor = [UIColor redColor].CGColor;
            return YES;
        }
    }
    if (counter == trees.count && counter == node.number) {
        [self showAlert:@"Correct traversal!" WithTitle:@"Success" InWorkmode:TreeMode];
        //[self redrawTreeUsingStrategy:strategy];
        return YES;
    }
    return NO;
}

+ (void) setNewTreeNodeParentInPoint: (CGPoint) point {
    parent = [self findNodeinPoint:point InWorkmode:TreeMode];
}

+ (TreeNode *) getNewTreeNodeParent {
    return parent;
}

+ (void) setTreeDrawingStrategy: (TreeDrawingStrategy)newstrategy {
    strategy = newstrategy;
}

+ (TreeDrawingStrategy) getTreeDrawingStrategy {
    return strategy;
}

+ (void) renameNodes {
    for (GraphNode * node in nodes) {
        node.value = [NSString stringWithFormat:@"node%u", [nodes indexOfObject:node]+1];
    }
    for (TreeNode * node in trees) {
        node.value = [NSString stringWithFormat:@"node%u", [trees indexOfObject:node]+1];
    }
}

@end
