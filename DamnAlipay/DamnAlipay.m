//
//  DamnAlipay.m
//  DamnAlipay
//
//  Created by BlueCocoa on 14-4-5.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "DamnAlipay.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

IMP ori_getPasswd_IMP = NULL;
IMP ori_gesture_IMP = NULL;

@implementation NSObject (HackPortal)

+ (id)getPassword
{
    NSString *passwd = ori_getPasswd_IMP(self, @selector(getPassword));
    return passwd;
}

- (void)gestureInputView:(id)view didFinishWithPassword:(id)password
{
    password = ori_getPasswd_IMP(self, @selector(getPassword));
    ori_gesture_IMP(self, @selector(gestureInputView:didFinishWithPassword:), view, password);
}


@end

@interface PortalListener : NSObject

@end

@implementation PortalListener

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(appLaunched:)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    }
    return self;
}

- (void)appLaunched:(NSNotification *)notification
{
    Class class_GestureUtil = NSClassFromString(@"GestureUtil");
    Class class_PortalListener = NSClassFromString(@"PortalListener");
    Method ori_Method = class_getClassMethod(class_GestureUtil, @selector(getPassword));
    ori_getPasswd_IMP = method_getImplementation(ori_Method);
    Method my_Method = class_getClassMethod(class_PortalListener, @selector(getPassword));
    method_exchangeImplementations(ori_Method, my_Method);
    
    Class class_Gesture = NSClassFromString(@"GestureUnlockViewController");
    Method ori_Method1 = class_getInstanceMethod(class_Gesture,
                                                 @selector(gestureInputView:didFinishWithPassword:));
    ori_gesture_IMP = method_getImplementation(ori_Method1);
    Method my_Method1 = class_getInstanceMethod(class_PortalListener,
                                                @selector(gestureInputView:didFinishWithPassword:));
    method_exchangeImplementations(ori_Method1, my_Method1);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}

@end

static void __attribute__((constructor)) initialize(void)
{
    static PortalListener *entrance;
    entrance = [[PortalListener alloc]init];
}