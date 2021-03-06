//
//  OEXRouter.m
//  edXVideoLocker
//
//  Created by Akiva Leffert on 1/29/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXRouter.h"

#import "OEXCustomTabBarViewViewController.h"
#import "OEXLoginViewController.h"
#import "OEXPushSettingsManager.h"
#import "OEXRegistrationViewController.h"

static OEXRouter* sSharedRouter;

@implementation OEXRouterEnvironment


- (id)initWithAnalytics:(OEXAnalytics*)analytics
                 config:(OEXConfig*)config
    pushSettingsManager:(OEXPushSettingsManager*)pushSettingsManager
                 styles:(OEXStyles*)styles {
    self = [super init];
    if(self != nil) {
        _analytics = analytics;
        _config = config;
        _pushSettingsManager = pushSettingsManager;
        _styles = styles;
    }
    return self;
}
@end

@interface OEXRouter ()

@property (strong, nonatomic) UIStoryboard* mainStoryboard;
@property (strong, nonatomic) OEXRouterEnvironment* environment;

@end

@implementation OEXRouter

+ (void)setSharedRouter:(OEXRouter*)router {
    sSharedRouter = router;
}

+ (instancetype)sharedRouter {
    return sSharedRouter;
}

- (id)initWithEnvironment:(OEXRouterEnvironment *)environment {
    self = [super init];
    if(self != nil) {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.environment = environment;
    }
    return self;
}

- (void)pushAnimationFromBottomfromController:(UIViewController*)fromController toController:(UIViewController*)toController {
    CATransition* transition = [CATransition animation];
    transition.duration = ANIMATION_DURATION;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [fromController.navigationController.view.layer addAnimation:transition forKey:nil];
    [[fromController navigationController] pushViewController:toController animated:NO];
}

- (void)popAnimationFromBottomFromController:(UIViewController*)fromController {
    CATransition* transition = [CATransition animation];
    transition.duration = ANIMATION_DURATION;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [fromController.navigationController.view.layer addAnimation:transition forKey:nil];
    [[fromController navigationController] popToRootViewControllerAnimated:NO];
}

- (void)showCourse:(OEXCourse*)course fromController:(UIViewController*)controller {
    OEXCustomTabBarViewViewController* courseController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"CustomTabBarView"];
    courseController.course = course;
    courseController.environment = [[OEXCustomTabBarViewViewControllerEnvironment alloc]
                                    initWithAnalytics:self.environment.analytics
                                    config:self.environment.config
                                    pushSettingsManager:self.environment.pushSettingsManager
                                    styles:self.environment.styles];
    [controller.navigationController pushViewController:courseController animated:YES];
}

- (void)showLoginScreenFromController:(UIViewController*)controller animated:(BOOL)animated {
    OEXLoginViewController* loginController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];

    if(animated) {
        [self pushAnimationFromBottomfromController:controller toController:loginController];
    }
    else {
        [controller.navigationController pushViewController:loginController animated:NO];
    }
}

- (void)showSignUpScreenFromController:(UIViewController*)controller animated:(BOOL)animated {
    OEXRegistrationViewController* registrationViewcontroller = [[OEXRegistrationViewController alloc] initWithDefaultRegistrationDescription];
    [self pushAnimationFromBottomfromController:controller toController:registrationViewcontroller];
}

- (void)presentViewController:(UIViewController*)controller fromController:(UIViewController*)presenter {
    [presenter presentViewController:controller animated:YES completion:nil];
}

@end
