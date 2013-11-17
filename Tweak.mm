#import <UIKit/UIKit.h>

@interface SBAppSliderController : UIViewController
	
- (NSArray *)applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (UIScrollView *)pageForDisplayIdentifier:(id)arg1;
- (void)forceDismissAnimated:(BOOL)arg1;
	
@end

@interface SBAppSliderScrollingViewController : UIViewController

- (void)animateView:(UIView *)view withTransform:(CATransform3D)transform duration:(float)duration;
	
@end

%hook SBAppSliderController

- (BOOL)sliderScroller:(id)arg1 isIndexRemovable:(unsigned int)arg2 {
	return YES;
}

- (void)_quitAppAtIndex:(unsigned int)arg1 {
	if (arg1 == 0) {
		if ([[self applicationList] count] == 1)
			system("killall -9 SpringBoard backboard");
		else {
			for (NSString *appID in [self applicationList]) {
				if (![appID isEqualToString:@"com.apple.springboard"])
					[self _quitAppAtIndex:[[self applicationList] indexOfObject:appID]];
			}
			
			UIScrollView *SpringBoardPage = (UIScrollView *)[[self pageForDisplayIdentifier:@"com.apple.springboard"] superview];
			[SpringBoardPage setContentOffset:CGPointMake(0, -self.view.frame.size.height) animated:NO];
			
			[UIView animateWithDuration:0.3
								  delay:0.0
								options:UIViewAnimationCurveEaseInOut
							 animations:^{
								 [SpringBoardPage setContentOffset:CGPointMake(0, 0.f) animated:NO];
							 }
							 completion:^(BOOL finished){
								 [self forceDismissAnimated:YES];
							 }
			 ];
			
		}
	}
	else
		%orig;
}
%end

%hook SBAppSliderScrollingViewController

- (void)scrollViewDidScroll:(UIScrollView *)arg1 {
	if ([arg1.superview.subviews objectAtIndex:0] == arg1) {
		for (unsigned int i = 0; i < [arg1.superview.subviews count]; i++) {
			UIScrollView *view = [arg1.superview.subviews objectAtIndex:i];
			if (i != 0 && arg1 != view) {
				[view setContentOffset:arg1.contentOffset animated:NO];
			}
		}
	}
	
	%orig;
}

- (void)scrollViewWillBeginDragging:(UIView *)arg1 {
    
	CATransform3D transform = CATransform3DIdentity;
	transform.m24 = -1/2000.f;
	transform.m34 = 1/500.f;
	transform = CATransform3DRotate(transform, -M_PI * 0.1f, 1, 0, 0);
	
	if (arg1 != [arg1.superview.subviews objectAtIndex:0])
		[self animateView:arg1 withTransform:transform duration:0.2];
	else {
		for (UIView *view in arg1.superview.subviews) {
			[self animateView:view withTransform:transform duration:0.2];
			
		}
	}
	
	%orig;
}

- (void)scrollViewWillEndDragging:(UIView *)arg1 withVelocity:(CGPoint)arg2 targetContentOffset:(CGPoint)arg3 {
	
	CATransform3D transform = CATransform3DIdentity;
	
	if (arg1 != [arg1.superview.subviews objectAtIndex:0])
		[self animateView:arg1 withTransform:transform duration:0.2];
	else {
		for (UIView *view in arg1.superview.subviews) {
			[self animateView:view withTransform:transform duration:0.2];
			
		}
	}
	
	%orig;
}

%new
- (void)animateView:(UIView *)view withTransform:(CATransform3D)transform duration:(float)duration {
	[UIView animateWithDuration:duration
						  delay:0.0
						options:UIViewAnimationCurveEaseInOut
					 animations:^{
						 view.layer.transform = transform;
					 }
					 completion:nil
	 ];
}

%end
