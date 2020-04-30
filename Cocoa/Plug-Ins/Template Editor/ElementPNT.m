#import "ElementPNT.h"
#import "ElementRECT.h"

@implementation ElementPNT

- (NSView *)dataView:(NSOutlineView *)outlineView
{
    return [ElementRECT configureFields:@[@"h", @"v"] forElement:self];
}

- (void)readDataFrom:(ResourceStream *)stream
{
    SInt16 tmp = 0;
    [stream readAmount:2 toBuffer:&tmp];
    self.h = CFSwapInt16BigToHost(tmp);
    [stream readAmount:2 toBuffer:&tmp];
    self.v = CFSwapInt16BigToHost(tmp);
}

- (void)sizeOnDisk:(UInt32 *)size
{
    *size += 4;
}

- (void)writeDataTo:(ResourceStream *)stream
{
    SInt16 tmp = CFSwapInt16HostToBig(self.h);
    [stream writeAmount:2 fromBuffer:&tmp];
    tmp = CFSwapInt16HostToBig(self.v);
    [stream writeAmount:2 fromBuffer:&tmp];
}

@end
