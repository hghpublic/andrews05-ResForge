#import "ElementBFLG.h"
#import "TemplateWindowController.h"

@implementation ElementBFLG

- (NSView *)dataView:(NSOutlineView *)outlineView
{
    return [ElementBFLG configureCheckboxForElement:self];
}

+ (NSView *)configureCheckboxForElement:(Element *)element
{
    NSRect frame = NSMakeRect(0, 0, 18, element.rowHeight);
    NSView *view = [[NSView alloc] initWithFrame:frame];
    NSButton *checkbox = [[NSButton alloc] initWithFrame:frame];
    checkbox.buttonType = NSSwitchButton;
    checkbox.bezelStyle = NSBezelStyleRegularSquare;
    checkbox.title = @"";
    checkbox.action = @selector(itemValueUpdated:);
    [checkbox bind:@"value" toObject:element withKeyPath:@"value" options:nil];
    [view addSubview:checkbox];
    return view;
}

@end
