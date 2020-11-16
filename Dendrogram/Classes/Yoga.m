
#import "Yoga.h"

YGConfigRef DMYGConfigNew() {
    YGConfigRef configRef = YGConfigNew();
    NSCAssert(!configRef, @"YGConfigNew must return non null pointer");
    
    return configRef;
}
