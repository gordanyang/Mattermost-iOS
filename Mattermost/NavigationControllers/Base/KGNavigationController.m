//
//  KGNavigationController.m
//  Mattermost
//
//  Created by Igor Vedeneev on 07.06.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "KGNavigationController.h"

@interface KGNavigationController ()

@end

@implementation KGNavigationController

#pragma mark - Interface orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
