#import "SCHAbstractSticker.h"


@interface SCHFibonacciFansSticker : SCHAbstractSticker

- (void)draw:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)info
      Point1:(CGPoint)p1 Point2:(CGPoint)p2;

@end