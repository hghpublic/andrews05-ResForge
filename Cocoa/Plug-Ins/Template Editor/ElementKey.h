#import "Element.h"
#import "ElementKEYB.h"

@interface ElementKey : Element
@property BOOL isKey;
@property BOOL observing;
@property (strong) NSMutableDictionary *keyedSections;
@property (strong) ElementKEYB *currentSection;

@end
