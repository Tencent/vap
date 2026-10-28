//
//  TCEPLightGameListener.h
//  TCEffectPlayer
//

#import <Foundation/Foundation.h>

@protocol TCEPLightGameDelegate <NSObject>

- (void)onEvent:(int)eventCode eventMsg:(NSString*)eventMsg;

@end

